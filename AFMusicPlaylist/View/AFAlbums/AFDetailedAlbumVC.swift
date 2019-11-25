

import UIKit


class AFDetailedAlbumVC: AFDynamicCellTableViewVC {
    private let albumUtility = AFAlbumUtility()
    private let provider = APIActionProvider<AFMusicPlaylistAPIAction>()
    
    
    override var navigationBarTitle: String? {
        return "Album"
    }
    
    private let name: String
    private let artist: String
    private let defaultImageUrl: String?
    private var album: AFAlbum?
    
    
    init(name: String, artist: String, imageUrl: String?) {
        self.name = name
        self.artist = artist
        self.defaultImageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        name = ""
        artist = ""
        defaultImageUrl = nil
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultRows()
        
        view.showLoader()
        provider.request(action: .albumDetailed(name: name, artist: artist)) { [weak self] result in
            guard let `self` = self else { return }
            self.view.removeLoader()
            
            switch result {
            case .success(_, let data):
                if let detailedAlbum = try? JSONDecoder().decode(AFAlbumDetailed.self, from: data),
                    let fetchedAlbum = detailedAlbum.album {
                    self.album = fetchedAlbum
                    self.setupRowsForLoadedAlbum()
                }
            default:
                break
            }
        }
    }
    
    
    private func setupDefaultRows() {
        let templateSongs = [AFSong(duration: 0, name: nil, artist: nil)]
        let templateAlbum = AFAlbum(name: name, artist: AFArtist(name: artist, images: [], listeners: 0),
                               listeners: 0, releaseDate: nil, songs: templateSongs,
                               images: [AFImage(url: defaultImageUrl, size: "large")])
        
        data = [[AFAlbumEntryData(album: templateAlbum)]]
        for _ in 0..<5 {
            data[0].append(AFButtonData(type: .action(title: ""), didSelect: { }))
        }
        
        data.append([AFButtonData(type: .action(title: ""), didSelect: { })])
    }
    
    
    private func setupRowsForLoadedAlbum() {
        guard let nAlbum = self.album else { return }
        
        data = [[AFAlbumEntryData(album: nAlbum)]]
        
        var songRows = [AFButtonData]()
        for song in nAlbum.songList?.tracks ?? [] {
            songRows.append(AFButtonData(type: .list(title: song.name ?? "")) { [weak self] in
                self?.playSong(name: song.name ?? "")
            })
        }
        
        data[0] += songRows
        data.append(getValidStorageButtonSection())
        
        tableView.reloadData()
    }
    
    
    private func playSong(name: String) {
        showAlert("Just Imagine", message: "Imagination is the true source of an art. \(name)")
    }
    
    
    private func removeAlbumFromTheLocalStorage() {
        if let nAlbum = self.album {
            albumUtility.removeFromDatabase(album: nAlbum)
            updateLocalStorageButton()
        }
    }
    
    
    private func addAlbumToTheLocalStorage() {
        if let nAlbum = self.album {
            albumUtility.storeInDatabase(album: nAlbum)
            updateLocalStorageButton()
        }
    }
    
    
    private func updateLocalStorageButton() {
        data[data.count - 1] = getValidStorageButtonSection()
        tableView.reloadSections(IndexSet(arrayLiteral: data.count - 1), with: .fade)
    }
    
    
    private func getValidStorageButtonSection() -> [AFCellData] {
        var storageSection = [AFCellData]()
        
        if albumUtility.getFromDatabaseBy(name: name, artist: artist) != nil {
            let deleteFromStorageRow = AFButtonData(type: .action(title: "Remove from the local storage"),
                                                    textColor: AFColors.deleteButton)
            { [weak self] in
                self?.removeAlbumFromTheLocalStorage()
            }
            
            storageSection.append(deleteFromStorageRow)
        } else {
            let addAlbumToStorageRow = AFButtonData(type: .action(title: "Add to the local storage"),
                                                    textColor: AFColors.headerText)
            { [weak self] in
                self?.addAlbumToTheLocalStorage()
            }
            
            storageSection.append(addAlbumToStorageRow)
        }
        
        return storageSection
    }
}
