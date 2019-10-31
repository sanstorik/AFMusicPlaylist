

import UIKit


class AFAlbumCell: UICollectionViewCell {
    static let identifier = "AFAlbumCell"
    
    
    var albumUpdater: AFAlbumViewUpdater? {
        didSet {
            nameLabel.text = albumUpdater?.topText
            artistLabel.text = albumUpdater?.bottomText
            
            if let url = albumUpdater?.imageUrl {
                albumImageView.setImageAsyncFrom(url: url)
            }
        }
    }

    private lazy var nameLabel = spawnNameLabel()
    private lazy var albumImageView = spawnAlbumImage()
    private lazy var artistLabel = spawnArtistLabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    
    private func commonInit() {
        backgroundColor = .clear
        contentView.addSubview(nameLabel)
        contentView.addSubview(albumImageView)
        contentView.addSubview(artistLabel)
        
        let constraints = [
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            albumImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -10),
            
            nameLabel.leadingAnchor.constraint(equalTo: albumImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: albumImageView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: artistLabel.topAnchor),
            
            artistLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}


extension AFAlbumCell {
    private func spawnNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = AFColors.headerText
        label.font = UIFont.systemFont(ofSize: 21.ifIpad(23))
        return label
    }
    
    
    private func spawnAlbumImage() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }
    
    
    private func spawnArtistLabel() -> UILabel {
        let label = spawnNameLabel()
        label.textColor = AFColors.textColor
        return label
    }
}
