
import UIKit


protocol AFReloadableAlbumList {
    var view: UIView! { get }
    func updateSources(with albums: [AFAlbum])
}

class AFAlbumsVC: CommonViewController {
    private lazy var searchData = AFArtistSearchDataVC(searchNavigationDelegate: self)
    private lazy var search = ShowableObjectSearchController(searchResultsController: searchData, presenter: self)
    private lazy var collectionView = spawnCollectionView()
    private var albums = [AFAlbum]()
    private let updater: (AFAlbum) -> AFAlbumViewUpdater
    private let fetcher: (AFReloadableAlbumList) -> Void
    private let isSearchAvailable: Bool
    
    
    init(isSearchAvailable: Bool = true, updater: @escaping (AFAlbum) -> AFAlbumViewUpdater,
         fetcher: @escaping (AFReloadableAlbumList) -> Void) {
        self.fetcher = fetcher
        self.updater = updater
        self.isSearchAvailable = isSearchAvailable
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetcher(self)
        collectionView.reloadData()
    }
    
    
    required init?(coder: NSCoder) {
        updater = { AFStoredAlbumsUpdater(album: $0) }
        fetcher = { _ in }
        isSearchAvailable = true
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Albums")
        setupBackground(AFColors.background)
        setupViews()
        additionalSetup()
        showIcons()
    }
    
    
    @objc private func startSearch() {
        search.showSearchBar()
    }
}


extension AFAlbumsVC: SearchNavigationDelegate, NavigationBarIconsHandler, AFReloadableAlbumList {
    func updateSources(with albums: [AFAlbum]) {
        self.albums = albums
        self.collectionView.reloadData()
        
        if isSearchAvailable {
            if albums.count == 0 {
                view.showMessageWithNoContentAvailable(message: "You haven't stored any albums yet. Go fetch some using the search.")
            } else {
                view.hideNoContentMessage()
            }
        }
    }
    
    func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showIcons() {
        if isSearchAvailable {
            let searchIcon = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(startSearch))
            navigationItem.rightBarButtonItem = searchIcon
            navigationItem.title = "Albums"
        }
    }
    
    
    func hideIcons() {
        if isSearchAvailable {
            navigationItem.title = "Artists"
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = nil
            navigationItem.hidesBackButton = true
        }
    }
}


extension AFAlbumsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AFAlbumCell = collectionView.smartDequeue(for: indexPath)
        cell.albumUpdater = updater(albums[indexPath.row])
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAlbum = albums[indexPath.row]
        if let name = selectedAlbum.name, let artist = selectedAlbum.artist?.name ?? selectedAlbum.artistName {
            let detailedVC = AFDetailedAlbumVC(name: name, artist: artist, imageUrl: selectedAlbum.largeImage?.url)
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = view.frame.width / 2 - 45
        
        if traitCollection.horizontalSizeClass == .regular {
            size = view.frame.width / 4
        }
        
        return CGSize(width: size, height: size + 65)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 10)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    
    private func setupViews() {
        view.addSubview(collectionView)
        
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 15, left: 25, bottom: 0, right: 25)
        cv.insetsLayoutMarginsFromSafeArea = true
        cv.smartRegister(AFAlbumCell.self)
        return cv
    }
}


extension UICollectionView  {
    func smartDequeue<T: AFSmartDequeueCell & UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    
    
    func smartRegister<T: AFSmartDequeueCell & UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: cell.identifier)
    }
}

protocol AFSmartDequeueCell {
    static var identifier: String { get }
}


extension AFSmartDequeueCell {
    static var identifier: String {
        return String(describing: self)
    }
}
