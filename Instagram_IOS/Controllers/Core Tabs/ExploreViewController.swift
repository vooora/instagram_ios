//
//  ExploreViewController.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 12/30/25.
//

import UIKit
import AVKit
import AVFoundation

class ExploreViewController: UIViewController {

    let scrollView = UIScrollView()
    private var reels: [Reel] = []
    private let offlineIndicator = UILabel()
    private var isOffline = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupOfflineIndicator()
        
        // Load from Core Data first (offline support)
        loadReelsFromCoreData()
        
        // Then try to fetch from API
        fetchReels()
    }
    
    private func setupOfflineIndicator() {
        offlineIndicator.text = "No network connection - Showing offline data"
        offlineIndicator.textColor = .systemOrange
        offlineIndicator.font = .systemFont(ofSize: 12)
        offlineIndicator.textAlignment = .center
        offlineIndicator.backgroundColor = .systemGray6
        offlineIndicator.isHidden = true
        view.addSubview(offlineIndicator)
    }
    
    private func loadReelsFromCoreData() {
        let cachedReels = CoreDataManager.shared.fetchReels()
        if !cachedReels.isEmpty {
            self.reels = cachedReels
            DispatchQueue.main.async {
                self.setupReels()
                print("Loaded \(cachedReels.count) reels from Core Data")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        offlineIndicator.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: 30
        )
    }

    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
    }
    
    private func fetchReels() {
        NetworkManager.shared.fetchReels { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let fetchedReels):
                self.reels = fetchedReels
                DispatchQueue.main.async {
                    self.isOffline = false
                    self.offlineIndicator.isHidden = true
                    self.setupReels()
                }
            case .failure(let error):
                print("Error fetching reels: \(error.localizedDescription)")
                
                // Check if we have offline data
                let hasOfflineData = !self.reels.isEmpty
                
                DispatchQueue.main.async {
                    // Show offline indicator if we have offline data
                    if hasOfflineData {
                        self.isOffline = true
                        self.offlineIndicator.isHidden = false
                    } else {
                        // No offline data, show error alert
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Failed to load reels. Please try again later.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    private func setupReels() {
        // Clear existing subviews
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        guard !reels.isEmpty else {
            print("No reels to display")
            return
        }
        
        let reelHeight = view.bounds.height
        let reelWidth = view.bounds.width

        for (index, reel) in reels.enumerated() {
            let reelView = UIView()
            reelView.frame = CGRect(
                x: 0,
                y: CGFloat(index) * reelHeight,
                width: reelWidth,
                height: reelHeight
            )
            reelView.backgroundColor = .black

            // Username label
            let usernameLabel = UILabel()
            usernameLabel.text = reel.userName
            usernameLabel.textColor = .white
            usernameLabel.font = .boldSystemFont(ofSize: 16)
            usernameLabel.frame = CGRect(
                x: 16,
                y: view.safeAreaInsets.top + 20,
                width: reelWidth - 32,
                height: 24
            )
            reelView.addSubview(usernameLabel)
            
            // Like count label
            let likeLabel = UILabel()
            likeLabel.text = "\(reel.likeCount) likes"
            likeLabel.textColor = .white
            likeLabel.font = .systemFont(ofSize: 14)
            likeLabel.frame = CGRect(
                x: 16,
                y: reelHeight - view.safeAreaInsets.bottom - 60,
                width: reelWidth - 32,
                height: 20
            )
            reelView.addSubview(likeLabel)
            
            // Video player view placeholder (for now, just show a label)
            // In a full implementation, you would use AVPlayerViewController here
            let videoLabel = UILabel()
            videoLabel.text = "Video: \(reel.reelVideo)"
            videoLabel.textColor = .white
            videoLabel.font = .systemFont(ofSize: 12)
            videoLabel.numberOfLines = 0
            videoLabel.textAlignment = .center
            videoLabel.frame = CGRect(
                x: 16,
                y: usernameLabel.frame.maxY + 20,
                width: reelWidth - 32,
                height: 100
            )
            reelView.addSubview(videoLabel)
            
            // Reel ID label
            let reelIdLabel = UILabel()
            reelIdLabel.text = "Reel ID: \(reel.reelId)"
            reelIdLabel.textColor = .lightGray
            reelIdLabel.font = .systemFont(ofSize: 12)
            reelIdLabel.frame = CGRect(
                x: 16,
                y: videoLabel.frame.maxY + 10,
                width: reelWidth - 32,
                height: 16
            )
            reelView.addSubview(reelIdLabel)

            scrollView.addSubview(reelView)
        }

        scrollView.contentSize = CGSize(
            width: reelWidth,
            height: reelHeight * CGFloat(reels.count)
        )
    }
}
