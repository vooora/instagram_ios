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
    
    private var data: [Item] = [
        Item(name: "Apple", id: 1, imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwtuz_CBrB2lHQS1j3lGlSliN-i5SI-Sh8eQ&s", username: "i_love_apples", isLiked: true),
        Item(name: "Banana", id: 2, imageURL: "https://www.southernliving.com/thmb/EM-f8L_T36WluwBtBkhD4gnCKg8=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/How_To_Freeze_Bananas_023-71e81efacb6a4d87a3596b8c2c519884.jpg", username: "user2", isLiked: false),
        Item(name: "Orange", id: 3, imageURL: "https://upload.wikimedia.org/wikipedia/commons/e/e3/Oranges_-_whole-halved-segment.jpg", username: "i_love_oranges", isLiked: false),
        Item(name: "Mango", id: 4, imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwtuz_CBrB2lHQS1j3lGlSliN-i5SI-Sh8eQ&s", username: "user4", isLiked: false)
    ]


    
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
        
        
        username.frame = CGRect(x: 16, y: 8, width: contentView.frame.width, height: 16)
        urlImage.frame = CGRect(x:16, y:username.bottom, width: contentView.frame.width, height: 200)
        likeButton.frame = CGRect(x:16, y:urlImage.bottom + 10, width: 20, height: 20)
        likeLabel.frame = CGRect(x:likeButton.right + 8, y:urlImage.bottom + 10, width: contentView.frame.width - 32, height: 22)
        caption.frame = CGRect(x:16, y:likeLabel.bottom, width: contentView.frame.width - 32, height: 22)
    }
    
    func configureImage(urlString: String) {
        guard let url = URL(string: urlString) else {
            urlImage.image = nil
            return
        }

        // Clear old image first (important for reuse)
        urlImage.image = nil

        // Fetch image asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.urlImage.image = image
                }
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



