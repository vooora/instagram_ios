import UIKit
import FirebaseDatabase

final class HomeViewController: UIViewController {

    private let tableView = UITableView()
    private var posts: [Post] = []

    private let database = Database.database(
        url: "https://instagram-ios-2c294-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Instagram"
        view.backgroundColor = .systemBackground

        configureTableView()
        fetchPosts()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds

        tableView.register(PostTableViewCell.self,
                           forCellReuseIdentifier: PostTableViewCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.separatorStyle = .none
    }

    private func fetchPosts() {
        database.child("posts").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }

            var fetchedPosts: [Post] = []

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let post = Post(id: snapshot.key, dictionary: dict) {
                    fetchedPosts.append(post)
                }
            }

            self.posts = fetchedPosts.reversed()
            self.tableView.reloadData()
        }
    }
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.identifier,
            for: indexPath
        ) as? PostTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }
}


import UIKit

final class PostTableViewCell: UITableViewCell {

    static let identifier = "PostTableViewCell"

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()

    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let likeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🤍", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.tintColor = .systemRed
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(likeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let padding: CGFloat = 12
        let contentWidth = contentView.frame.width - 2 * padding

        usernameLabel.frame = CGRect(x: padding, y: padding,
                                     width: contentWidth, height: 20)

        postImageView.frame = CGRect(x: 0, y: usernameLabel.bottom + 8,
                                     width: contentView.frame.width, height: 300)

        captionLabel.frame = CGRect(x: padding, y: postImageView.bottom + 8,
                                    width: contentWidth, height: 8)

        likeButton.frame = CGRect(x: padding, y: captionLabel.bottom + 8, width: 30, height: 30)

        likeLabel.frame = CGRect(x: likeButton.frame.maxX + 6, y: captionLabel.frame.maxY + 12, width: 100, height: 20)
    }

    func configure(with post: Post) {
        usernameLabel.text = post.username
        captionLabel.text = post.caption
        likeLabel.text = "\(post.likeCount) likes"
    }

}
