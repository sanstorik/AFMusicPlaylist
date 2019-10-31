

import UIKit


class AFAlbumEntryData: AFCellData {
    override var identifier: String { return AFAlbumEntryCell.identifier }
    override var rowHeightMultiplier: CGFloat { return 0.19 }
    
    let album: AFAlbum
    
    init(album: AFAlbum) {
        self.album = album
    }
}


class AFAlbumEntryCell: AFTemplateCell {
    override class var identifier: String { return "AFAlbumEntryCell" }
    override var canBecomeHighlighted: Bool { return false }
    
    private lazy var albumImageView = spawnAlbumImage()
    private lazy var nameLabel = spawnNameLabel()
    private lazy var artistLabel = spawnArtistLabel()
    private lazy var listenersCounter = spawnListenersLabel()

    
    override func setupFrom(data: AFCellData) {
        guard let entryData = data as? AFAlbumEntryData else { return }
        
        if let imageUrl = entryData.album.largeImage?.url {
            albumImageView.setImageAsyncFrom(url: imageUrl)
        }
        
        nameLabel.text = entryData.album.name
        artistLabel.text = entryData.album.artist?.name ?? entryData.album.artistName
        
        let fans = entryData.album.listeners
        let updater = AFArtistsAlbumsUpdater(album: entryData.album)
        listenersCounter.text = "\(fans) \(updater.peoplePluralForm(count: fans)) to it with you."
    }
    
    
    override func setupViews() {
        contentView.addSubview(albumImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(listenersCounter)
        
        let constraints = [
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            albumImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            albumImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            albumImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: albumImageView.topAnchor),
            
            artistLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 20),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            artistLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            
            listenersCounter.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 20),
            listenersCounter.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            listenersCounter.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 3)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}


extension AFAlbumEntryCell {
    private func spawnNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = AFColors.headerText
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 23.ifIpad(25))
        return label
    }
    
    
    private func spawnAlbumImage() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }
    
    
    private func spawnArtistLabel() -> UILabel {
        let label = spawnNameLabel()
        label.textColor = AFColors.deleteButton
        label.font = UIFont.systemFont(ofSize: 18.ifIpad(21))
        return label
    }
    
    
    private func spawnListenersLabel() -> UILabel {
        let label = spawnNameLabel()
        label.textColor = AFColors.textColor
        label.font = UIFont.systemFont(ofSize: 18.ifIpad(21))
        return label
    }
}
