//
//  AddMovieViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 23/8/25.
//

import UIKit
import FirebaseAuth

enum StatusMovie {
  case add
  case update
}

class AddMovieViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var titleTextField: UITextField!
  @IBOutlet private weak var descriptionTextView: UITextView!
  @IBOutlet private weak var durationTextField: UITextField!
  @IBOutlet private weak var releaseYearTextField: UITextField!
  @IBOutlet private weak var userScoreTextField: UITextField!
  @IBOutlet private weak var budgetTextField: UITextField!
  @IBOutlet private weak var revenueTextField: UITextField!
  @IBOutlet private weak var pdfURLTextField: UITextField!
  @IBOutlet private weak var videoURLsTextField: UITextField!
  @IBOutlet private weak var genreTextField: UITextField!
  @IBOutlet private weak var genresButton: UIButton!
  @IBOutlet private weak var saveButton: UIButton!
  
  private var availableGenres = ["Action", "Comedy", "Drama", "Sci-Fi", "Horror", "Romance", "Thriller"]
  private var selectedGenres: [String] = []
  var movie: MovieModel?
  var status: StatusMovie = .add
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    populateFieldsForEditing()
  }
  
  private func setupView() {
    CAGradientLayer().gradientButton(btn: saveButton)
    saveButton.setTitle(status == .add ? "Save" : "Update", for: .normal)
    descriptionTextView.delegate = self
    descriptionTextView.text = "Description".localized()
  }
  
  private func populateFieldsForEditing() {
    guard status == .update, let movie = movie else { return }
    
    titleTextField.text = movie.title
    descriptionTextView.text = movie.describe
    durationTextField.text = "\(movie.duration)"
    releaseYearTextField.text = movie.releaseYear != nil ? "\(Date().getYear(date: movie.releaseYear!))" : ""
    userScoreTextField.text = "\(movie.userScore)"
    budgetTextField.text = movie.budget != 0.0 ? "\(movie.budget)" : ""
    revenueTextField.text = movie.revenue != 0.0 ? "\(movie.revenue)" : ""
    pdfURLTextField.text = movie.imageURL
    videoURLsTextField.text = movie.videoURLs.joined(separator: ", ")
    
    selectedGenres = movie.genres.map { $0.title }
    genreTextField.text =  selectedGenres.isEmpty ? "" : selectedGenres.joined(separator: ", ")
  }
  
  // MARK: - Actions
  @IBAction func showGenresPicker(_ sender: Any) {
    let genresVC = GenresPickerViewController()
    genresVC.availableGenres = availableGenres
    genresVC.selectedGenres = selectedGenres
    genresVC.onSelectionChanged = { [weak self] selected in
      self?.selectedGenres = selected
      self?.genreTextField.text = selected.isEmpty ? "": selected.joined(separator: ", ")
    }
    let navController = UINavigationController(rootViewController: genresVC)
    navController.modalPresentationStyle = .formSheet
    present(navController, animated: true)
  }
  
  @IBAction func saveButtonTapped(_ sender: Any) {
    saveMovie()
  }
  
  private func saveMovie() {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "User not logged in", onAction: {})
      return
    }
    
    // Validate inputs
    guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty,
          let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty,
          description != "Description".localized(),
          let durationText = durationTextField.text, let duration = Int(durationText),
          let userScoreText = userScoreTextField.text, let userScore = Double(userScoreText) else {
      showAlert(title: "Error", message: "Please fill in all required fields", onAction: {})
      return
    }
    
    // Optional fields
    let releaseYearText = releaseYearTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    var releaseYear: Date?
    if let yearText = releaseYearText, !yearText.isEmpty, let year = Int(yearText) {
      let calendar = Calendar.current
      releaseYear = calendar.date(from: DateComponents(year: year))
    }
    
    let budget = budgetTextField.text?.isEmpty == false ? Double(budgetTextField.text!) : 0.0
    let revenue = revenueTextField.text?.isEmpty == false ? Double(revenueTextField.text!) : 0.0
    let pdfURL = pdfURLTextField.text?.isEmpty == false ? pdfURLTextField.text : nil
    // Parse videoURLs
    let videoURLsText = videoURLsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let videoURLs = videoURLsText.isEmpty ? [] : videoURLsText.split(separator: ",").map {
      String($0).trimmingCharacters(in: .whitespaces)
    }
    
    // Create genres from selectedGenres
    let genres = selectedGenres.map { GenersModel(id: UUID().uuidString, title: $0) }
    
    let movie = MovieModel(
      id: self.movie?.id ?? UUID().uuidString,
      title: title,
      describe: description,
      duration: duration,
      releaseYear: releaseYear,
      genres: genres,
      userScore: userScore,
      budget: budget ?? 0.0,
      revenue: revenue ?? 0.0,
      imageURL: pdfURL,
      comments: self.movie?.comments ?? [],
      videoURLs: videoURLs
    )
    
    showLoadingIndicator()
    FirebaseManager.shared.getUserRole { [weak self] role in
      guard let self = self else { return }
      guard role == 1 else {
        self.hideLoadingIndicator()
        self.showAlert(title: "Error", message: "Only admins can add movies", onAction: {})
        return
      }
      
      FirebaseManager.shared.saveMovie(movie: movie) { error in
        self.hideLoadingIndicator()
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        } else {
          let actionTitle = self.status == .add ? "added" : "updated"
          self.showAlert(title: "Success", message: "Movie \(actionTitle) successfully", onAction: {
            self.navigationController?.popViewController(animated: true)
          })
        }
      }
    }
  }
}

// MARK: - UITextViewDelegate
extension AddMovieViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Description".localized() {
      textView.text = ""
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Description".localized()
    }
  }
}

// MARK: - GenresPickerViewController
class GenresPickerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
  var availableGenres: [String] = []
  var selectedGenres: [String] = []
  var onSelectionChanged: (([String]) -> Void)?
  
  private let tableView = UITableView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
  }
  
  private func setupView() {
    title = "Select Genres".localized()
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenreCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  @objc private func doneTapped() {
    onSelectionChanged?(selectedGenres)
    dismiss(animated: true)
  }
  
  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return availableGenres.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)
    let genre = availableGenres[indexPath.row]
    cell.textLabel?.text = genre
    cell.accessoryType = selectedGenres.contains(genre) ? .checkmark : .none
    return cell
  }
  
  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let genre = availableGenres[indexPath.row]
    if selectedGenres.contains(genre) {
      selectedGenres.removeAll { $0 == genre }
    } else {
      selectedGenres.append(genre)
    }
    tableView.reloadData()
  }
}
