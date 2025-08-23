//
//  PlayVideoViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 25/3/25.
//
import UIKit
import AVKit
import AVFoundation

class PlayVideoViewController: BaseViewController {
  // MARK: - Properties
  private var player: AVPlayer?
  private var playerViewController: AVPlayerViewController?
  private var currentVideoIndex = 0
  private var currentObserver: NSObjectProtocol?
  
  private let telegramBotToken = "7786183797:AAGlyWA199w9V0A_4jkURem8Eyk-BPw30ec"
  private let session = URLSession.shared
  
  var movie: MovieModel? {
    didSet {
      guard isViewLoaded else { return }
      resetPlayback()
    }
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPlayer()
    resetPlayback()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cleanup()
  }
  
  deinit {
    cleanup()
  }
  
  // MARK: - Setup
  private func setupPlayer() {
    playerViewController = AVPlayerViewController()
    guard let playerVC = playerViewController else { return }
    
    playerVC.showsPlaybackControls = true
    addChild(playerVC)
    view.addSubview(playerVC.view)
    playerVC.view.frame = view.bounds
    playerVC.didMove(toParent: self)
  }
  
  // MARK: - Playback Control
  private func resetPlayback() {
    currentVideoIndex = 0
    playNextVideo()
  }
  
  private func playNextVideo() {
    guard let movie = movie, !movie.videoURLs.isEmpty else {
      playbackFinished("No videos available to play.")
      return
    }
    
    guard currentVideoIndex < movie.videoURLs.count else {
      playbackFinished("All videos have been played.")
      return
    }
    
    let fileID = movie.videoURLs[currentVideoIndex]
    fetchVideoURL(fileID: fileID)
  }
  
  private func fetchVideoURL(fileID: String) {
    let urlString = "https://api.telegram.org/bot\(telegramBotToken)/getFile?file_id=\(fileID)"
    guard let url = URL(string: urlString) else {
      handleError("Invalid Telegram API URL for fileID: \(fileID)")
      return
    }
    
    let task = session.dataTask(with: url) { [weak self] data, _, error in
      guard let self else { return }
      
      if let error {
        self.handleError("Telegram API error: \(error.localizedDescription)")
        return
      }
      
      guard let data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let result = json["result"] as? [String: Any],
            let filePath = result["file_path"] as? String else {
        self.handleError("Failed to parse Telegram API response for fileID: \(fileID)")
        return
      }
      
      let trailerURL = URL(string: "https://api.telegram.org/file/bot\(self.telegramBotToken)/\(filePath)")!
      DispatchQueue.main.async {
        self.playVideo(url: trailerURL)
      }
    }
    task.resume()
  }
  
  private func playVideo(url: URL) {
    cleanupPlayer()
    
    let playerItem = AVPlayerItem(url: url)
    player = AVPlayer(playerItem: playerItem)
    playerViewController?.player = player
    
    currentObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: playerItem,
      queue: .main) { [weak self] _ in
        self?.videoDidFinishPlaying()
      }
    
    player?.play()
  }
  
  private func videoDidFinishPlaying() {
    currentVideoIndex += 1
    playNextVideo()
  }
  
  private func playbackFinished(_ message: String) {
    print(message)
    dismiss(animated: true, completion: nil)
  }
  
  private func handleError(_ message: String) {
    print(message)
    currentVideoIndex += 1
    DispatchQueue.main.async {
      self.playNextVideo()
    }
  }
  
  // MARK: - Cleanup
  private func cleanupPlayer() {
    player?.pause()
    player?.replaceCurrentItem(with: nil)
    player = nil
    
    if let observer = currentObserver {
      NotificationCenter.default.removeObserver(observer)
      currentObserver = nil
    }
  }
  
  private func cleanup() {
    cleanupPlayer()
    playerViewController?.willMove(toParent: nil)
    playerViewController?.view.removeFromSuperview()
    playerViewController?.removeFromParent()
    playerViewController = nil
  }
}
