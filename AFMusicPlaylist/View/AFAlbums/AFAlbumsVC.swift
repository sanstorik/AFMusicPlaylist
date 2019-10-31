
import UIKit


class AFAlbumsVC: CommonViewController {
    private lazy var collectionView = spawnCollectionView()
    private let albums: [AFAlbum]
    private let updater: (AFAlbum) -> AFAlbumViewUpdater
    
    
    init(albums: [AFAlbum], updater: @escaping (AFAlbum) -> AFAlbumViewUpdater) {
        self.albums = albums
        self.updater = updater
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        updater = { AFStoredAlbumsUpdater(album: $0) }
        albums = []
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Albums")
        setupBackground(AFColors.background)
        setupViews()
        additionalSetup()
    }
}


extension AFAlbumsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AFAlbumCell.identifier, for: indexPath)
            as? AFAlbumCell else {
            fatalError()
        }
        
        cell.albumUpdater = updater(albums[indexPath.row])
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = AFColors.highlightColor
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if traitCollection.horizontalSizeClass == .regular {
            return CGSize(width: view.frame.width / 2.7, height: 200)
        }
        
        return CGSize(width: view.frame.width / 2 - 50, height: 250)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    
    private func setupViews() {
        view.addSubview(collectionView)
        
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    private func additionalSetup() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    
    private func spawnCollectionView() -> UICollectionView {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.allowsSelection = false
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(AFAlbumCell.self, forCellWithReuseIdentifier: AFAlbumCell.identifier)
        return cv
    }
}
