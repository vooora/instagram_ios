//
//  ProfileViewController.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 12/30/25.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Log Out",
            style: .done,
            target: self,
            action: #selector(didTapLogout)
        )
    }
    
    @objc private func didTapLogout() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.logoutUser()
        })

        present(alert, animated: true)
    }

    private func logoutUser() {
        do {
            try Auth.auth().signOut()

            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            navVC.modalPresentationStyle = .fullScreen

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = navVC
                window.makeKeyAndVisible()
            }

        } catch {
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to log out. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

}
