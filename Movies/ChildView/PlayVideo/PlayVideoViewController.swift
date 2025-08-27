//
//  PlayVideoViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 25/3/25.
//

import UIKit
import AVKit
import AVFoundation

class PlayVideoViewController: BaseViewController {
  private var queuePlayer: AVQueuePlayer?
  private var playerViewController: AVPlayerViewController?
  private var playerItems: [AVPlayerItem] = []
  private var currentObserver: NSObjectProtocol?
  private let telegramBotToken = "7786183797:AAGlyWA199w9V0A_4jkURem8Eyk-BPw30ec"
  
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
    cleanupPlayer()
    playerItems.removeAll()
    
    guard let movie = movie, !movie.videoURLs.isEmpty else {
      DispatchQueue.main.async { [weak self] in
        self?.showAlert(title: "Error", message: "No videos available", onAction: { [weak self] in
          self?.dismiss(animated: true)
        })
      }
      return
    }
    
    // Tải URL video trong background thread
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self else { return }
      let dispatchGroup = DispatchGroup()
      var tempURLs: [URL?] = Array(repeating: nil, count: movie.videoURLs.count)
      
      for (index, fileID) in movie.videoURLs.enumerated() {
        dispatchGroup.enter()
        self.fetchVideoURL(fileID: fileID) { url in
          tempURLs[index] = url
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main) { [weak self] in
        guard let self else { return }
        self.playerItems = tempURLs.compactMap { $0 }.map { AVPlayerItem(url: $0) }
        self.startPlayback()
      }
    }
  }
  
  private func fetchVideoURL(fileID: String, completion: @escaping (URL?) -> Void) {
    let urlString = "https://api.telegram.org/bot\(telegramBotToken)/getFile?file_id=\(fileID)"
    guard let url = URL(string: urlString) else {
      completion(nil)
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data, error == nil,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let result = json["result"] as? [String: Any],
            let filePath = result["file_path"] as? String,
            let videoURL = URL(string: "https://api.telegram.org/file/bot\(self.telegramBotToken)/\(filePath)") else {
        completion(nil)
        return
      }
      completion(videoURL)
    }
    task.resume()
  }
  
  private func startPlayback() {
    guard !playerItems.isEmpty else {
      DispatchQueue.main.async { [weak self] in
        self?.playbackFinished("No valid videos to play")
      }
      return
    }
    
    queuePlayer = AVQueuePlayer(items: playerItems)
    playerViewController?.player = queuePlayer
    
    // Preload video tiếp theo
    for (index, item) in playerItems.enumerated() where index > 0 {
      item.asset.loadValuesAsynchronously(forKeys: ["playable"]) {
        DispatchQueue.main.async {
          guard self.playerItems.contains(item) else { return }
        }
      }
    }
    
    currentObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: queuePlayer?.currentItem,
      queue: .main
    ) { [weak self] _ in
      self?.videoDidFinishPlaying()
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.queuePlayer?.play()
    }
  }
  
  private func videoDidFinishPlaying() {
    guard let queuePlayer else { return }
    if queuePlayer.items().isEmpty {
      DispatchQueue.main.async { [weak self] in
        self?.playbackFinished("All videos played")
      }
    } else {
      currentObserver = NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime,
        object: queuePlayer.currentItem,
        queue: .main
      ) { [weak self] _ in
        self?.videoDidFinishPlaying()
      }
    }
  }
  
  private func playbackFinished(_ message: String) {
    showAlert(title: "Playback Finished", message: message, onAction: { [weak self] in
      self?.dismiss(animated: true)
    })
  }
  
  // MARK: - Cleanup
  private func cleanupPlayer() {
    queuePlayer?.pause()
    queuePlayer?.removeAllItems()
    queuePlayer = nil
    
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
