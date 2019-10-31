

import UIKit



class AFArtistCell: UITableViewCell {
    static let identifier = "AFArtistCell"
    
    
    var artist: AFArtist? {
        didSet {
            nameLabel.text = artist?.name
            
            if let imageUrl = artist?.smallImage?.url {
                avatarImage.setImageAsyncFrom(url: imageUrl)
            }
        }
    }
    
    
    private lazy var nameLabel = spawnNameLabel()
    private lazy var avatarImage = spawnAvatarImage()
    private lazy var actionImage = spawnActionImage()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    
    private func commonInit() {
        backgroundColor = AFColors.header
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatarImage)
        contentView.addSubview(actionImage)
        
        let constraints = [
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            
            avatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            avatarImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            avatarImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            avatarImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            actionImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.16),
            actionImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.16),
            actionImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}


extension AFArtistCell {
    private func spawnNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = AFColors.headerText
        label.font = UIFont.systemFont(ofSize: 19.ifIpad(22))
        return label
    }
    
    
    private func spawnAvatarImage() -> UIImageView {
        let iv = CorneredUIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 0.1
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }
    
    
    private func spawnActionImage() -> UIImageView {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "action_icon")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = AFColors.textColor
        return iv
    }
}
