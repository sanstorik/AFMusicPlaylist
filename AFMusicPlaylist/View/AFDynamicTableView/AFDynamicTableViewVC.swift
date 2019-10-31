
import UIKit


class AFDynamicCellTableViewVC: CommonViewController {
    private(set) var tableView: UITableView!
    var data = [[AFCellData]]()
    var navigationBarTitle: String? { return nil }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AFColors.background)
        setupNavigationBar(title: navigationBarTitle ?? "", bgColor: AFColors.header)
        setupViews()
    }
    
    
    private func setupViews() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .lightGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.insetsContentViewsToSafeArea = true
        
        let customCells = [AFButtonCell.self, AFAlbumEntryCell.self]
        customCells.forEach {
            tableView.register($0.self, forCellReuseIdentifier: $0.identifier)
        }
    }
}


extension AFDynamicCellTableViewVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataForRow = data[indexPath.section][indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: dataForRow.identifier, for: indexPath) as? AFTemplateCell else {
                fatalError()
        }
        
        cell.data = dataForRow
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.deviceHeight * data[indexPath.section][indexPath.row].rowHeightMultiplier
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AFTemplateCell {
            cell.didSelect()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AFTemplateCell {
            cell.didUnhighlight()
        }
    }
}
