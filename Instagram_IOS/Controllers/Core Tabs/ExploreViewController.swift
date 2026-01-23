//
//  ExploreViewController.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 12/30/25.
//

import UIKit

class ExploreViewController: UIViewController {

    let scrollView = UIScrollView()
    let numberOfReels = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupReels()
    }
    

    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
    }
    
    private func setupReels() {

        let reelHeight = view.bounds.height
        let reelWidth = view.bounds.width

        for i in 0..<numberOfReels {

            let reelView = UIView()
            reelView.frame = CGRect(
                x: 0,
                y: CGFloat(i) * reelHeight,
                width: reelWidth,
                height: reelHeight
            )

            reelView.backgroundColor = randomColor()

            // Label (just to see which reel it is)
            let label = UILabel()
            label.text = "Reel \(i + 1)"
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 32)
            label.textAlignment = .center
            label.frame = reelView.bounds

            reelView.addSubview(label)
            scrollView.addSubview(reelView)
        }

        scrollView.contentSize = CGSize(
            width: reelWidth,
            height: reelHeight * CGFloat(numberOfReels)
        )
    }
    
    
    
    private func randomColor() -> UIColor {
        return UIColor(
            red: .random(in: 0.2...0.8),
            green: .random(in: 0.2...0.8),
            blue: .random(in: 0.2...0.8),
            alpha: 1
        )
    }





}
