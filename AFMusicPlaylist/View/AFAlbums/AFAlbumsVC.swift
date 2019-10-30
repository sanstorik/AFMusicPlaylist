
import UIKit


class AFAlbumsVC: CommonViewController {
    private lazy var searchData = AFArtistSearchDataVC(searchNavigationDelegate: self)
    private lazy var search = ShowableObjectSearchController(searchResultsController: searchData, presenter: self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showIcons()
        setupNavigationBar(title: "Albums")
        setupBackground(AFColors.background)
    }
    
    
    @objc private func searchButtonOnClick() {
        search.showSearchBar()
    }
}


extension AFAlbumsVC: SearchNavigationDelegate, NavigationBarIconsHandler {
    func pushViewController(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showIcons() {
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonOnClick))
        navigationItem.rightBarButtonItems = [search]
    }
}
