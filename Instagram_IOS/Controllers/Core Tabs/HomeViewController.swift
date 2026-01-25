import UIKit
import FirebaseDatabase

struct Item {
    let name: String
    var id: Int
    let imageURL: String
    let username: String
    var isLiked: Bool
}


final class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate { //provides data, handles interactions
    
    private let tableView = UITableView()//property of the view controller
    private let headerView = UIView()
    private let headerTitle = UILabel()
    private let offlineIndicator = UILabel()
    
    private var data: [Item] = []
    private var isOffline = false


    
    override func viewDidLoad() { //add all things you want seen on the main page
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: SimpleTableViewCell.identifier)
        tableView.rowHeight = 330
        
        headerView.backgroundColor = .systemBackground
        view.addSubview(headerView)
        headerView.addSubview(headerTitle)
        headerTitle.text = "Instagram"
        headerTitle.font = .boldSystemFont(ofSize: 24)
        
        setupOfflineIndicator()
        
        // Load from Core Data first (offline support)
        loadPostsFromCoreData()
        
        // Then try to fetch from API
        fetchPosts()

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
    
    private func loadPostsFromCoreData() {
        let feedPosts = CoreDataManager.shared.fetchFeedPosts()
        if !feedPosts.isEmpty {
            self.data = feedPosts.map { feedPost in
                Item(
                    name: "",
                    id: feedPost.likeCount,
                    imageURL: feedPost.postImage,
                    username: feedPost.userName,
                    isLiked: feedPost.likedByUser
                )
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("Loaded \(feedPosts.count) posts from Core Data")
            }
        }
    }
    
    private func fetchPosts() {
        NetworkManager.shared.fetchUserFeed { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let feedPosts):
                // Convert FeedPost to Item
                self.data = feedPosts.map { feedPost in
                    Item(
                        name: "", // No caption in API response, using empty string
                        id: feedPost.likeCount,
                        imageURL: feedPost.postImage,
                        username: feedPost.userName,
                        isLiked: feedPost.likedByUser
                    )
                }
                DispatchQueue.main.async {
                    self.isOffline = false
                    self.offlineIndicator.isHidden = true
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching posts: \(error.localizedDescription)")
                print("Full error: \(error)")
                
                // Check if we have offline data
                let hasOfflineData = !self.data.isEmpty
                
                DispatchQueue.main.async {
                    // Show offline indicator if we have offline data
                    if hasOfflineData {
                        self.isOffline = true
                        self.offlineIndicator.isHidden = false
                    } else {
                        // No offline data, show error alert
                        let errorMessage: String
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet:
                                errorMessage = "No internet connection. Please check your network settings."
                            case .timedOut:
                                errorMessage = "Request timed out. Please try again."
                            case .cannotFindHost:
                                errorMessage = "Cannot reach server. Please check your connection."
                            default:
                                errorMessage = "Network error: \(urlError.localizedDescription)"
                            }
                        } else {
                            errorMessage = "Failed to load posts: \(error.localizedDescription)"
                        }
                        
                        let alert = UIAlertController(
                            title: "Error",
                            message: errorMessage,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        headerTitle.frame = CGRect(
                x: 16,
                y: 0,
                width: headerView.frame.width - 32,
                height: 40
            )
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: 60)
        
        offlineIndicator.frame = CGRect(
            x: 0,
            y: headerView.frame.maxY,
            width: view.frame.width,
            height: 30
        )
    }
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    


    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: SimpleTableViewCell.identifier,
                for: indexPath
            ) as! SimpleTableViewCell
        
        var item = data[indexPath.row]
        cell.caption.text = item.name
        cell.likeLabel.text = "\(item.id) likes"
        print("Loading image for row \(indexPath.row): \(item.imageURL)")
        cell.configureImage(urlString: item.imageURL)
        cell.username.text = item.username
        

        cell.configure(with: item)
        
        cell.onLikeTapped = { [weak self] in
            guard let self = self else { return }

            item.isLiked.toggle()

            if item.isLiked {
                item.id += 1
            } else {
                item.id -= 1
            }

            cell.configure(with: item)
            data[indexPath.row] = item
            //tableView.reloadRows](at: [indexPath], with: .none)
        }

        
        
        return cell
    }
    

    
    

    
}


class SimpleTableViewCell: UITableViewCell { //visual representation of a single row in a table view
    
    static let identifier = "SimpleTableViewCell"
    
    let caption = UILabel()
    let likeLabel = UILabel()
    let likeButton = UIButton(type: .system)
    let urlImage = UIImageView()
    let username = UILabel()


    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ){
        super.init(style: style, reuseIdentifier: reuseIdentifier) //called on all paths before returning from initialiser
        
        contentView.addSubview(username)
        contentView.addSubview(likeLabel)
        contentView.addSubview(caption)
        contentView.addSubview(urlImage)
        contentView.addSubview(likeButton)
        contentView.bringSubviewToFront(likeButton)

        
        caption.font = .systemFont(ofSize: 16, weight: .medium)
        likeLabel.font = .systemFont(ofSize: 14)
        username.font = .systemFont(ofSize: 14)
        likeLabel.textColor = .secondaryLabel
        username.textColor = .label
        urlImage.contentMode = .scaleAspectFill
        urlImage.clipsToBounds = true
        urlImage.backgroundColor = .systemGray6 // Temporary: to see if image view is visible
//        likeButton.addTarget(self,
//                             action: #selector(didTapLike),
//                             for: .touchUpInside)

        

        
        likeButton.tintColor = .systemRed
        likeButton.contentMode = .scaleAspectFit
        likeButton.addTarget(self,
                                 action: #selector(didTapLike),
                                 for: .touchUpInside)
        
        caption.isUserInteractionEnabled = false
        likeLabel.isUserInteractionEnabled = false


        selectionStyle = .none

    }
    required init?(coder: NSCoder) { // see purpose
            fatalError("init(coder:) has not been implemented")
        }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        
        username.frame = CGRect(x: 16, y: 8, width: contentView.frame.width - 32, height: 16)
        urlImage.frame = CGRect(x: 0, y: username.bottom + 8, width: contentView.frame.width, height: 200)
        likeButton.frame = CGRect(x:16, y:urlImage.bottom + 10, width: 20, height: 20)
        likeLabel.frame = CGRect(x:likeButton.right + 8, y:urlImage.bottom + 10, width: contentView.frame.width - 32, height: 22)
        caption.frame = CGRect(x:16, y:likeLabel.bottom, width: contentView.frame.width - 32, height: 22)
    }
    
    func configureImage(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            urlImage.image = nil
            return
        }

        // Clear old image first (important for reuse)
        urlImage.image = nil

        // Fetch image asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image from \(urlString): \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received for image: \(urlString)")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data for URL: \(urlString)")
                return
            }
            
            DispatchQueue.main.async {
                self.urlImage.image = image
                print("Successfully loaded image from: \(urlString)")
            }
        }.resume()
    }
    
    func configure(with post: Item) {

        likeLabel.text = "\(post.id)"

        let heartImageName = post.isLiked ? "heart.fill" : "heart"

        let heartImage = UIImage(systemName: heartImageName)?
            .withRenderingMode(.alwaysTemplate)

        likeButton.setImage(heartImage, for: .normal)
        likeButton.tintColor = post.isLiked ? .systemRed : .label
    }

    var onLikeTapped: (() -> Void)?
    
    @objc private func didTapLike() {
        onLikeTapped?()
        print("HEART TAPPED")
    }

}



