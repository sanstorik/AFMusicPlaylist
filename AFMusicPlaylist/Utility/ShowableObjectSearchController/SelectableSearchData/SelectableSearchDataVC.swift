
import UIKit

enum SelectionMode {
    case single, multiple, manual
}

protocol SearchSelectedObjectHandler: class {
    var selectionMode: SelectionMode { get }
    func selectedIDs() -> [Int64]
    func didSelect(_ ids: [Int64])
}

class SelectableSearchDataVC<T: UpdatableEntity & SettableID>: RefreshableSortedSearchDataVC<T> {
    var selectableObjects = [Int64: Bool]()
    private weak var selectionHandler: SearchSelectedObjectHandler?
    private lazy var longTouchDelegate = LongPressTouchDelegate<T>(searchTableView: searchTableView)
    
    
    init(_ searchNavigationDelegate: SearchNavigationDelegate?,
         selectionHandler: SearchSelectedObjectHandler) {
        self.selectionHandler = selectionHandler
        super.init(searchNavigationDelegate: searchNavigationDelegate)
    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectableObjects.removeAll()
        
        selectionHandler?.selectedIDs().forEach {
            selectableObjects[$0] = true
        }
        
        searchTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:
            #selector(longPress(longPressGestureRecognizer:)))
        longPressRecognizer.minimumPressDuration = 0.3
        longPressRecognizer.delegate = longTouchDelegate
        
        longTouchDelegate.selectionHandler = selectionHandler
        longTouchDelegate.getSection = { [unowned self] in
            self.sections[$0.section]
        }
        
        view.addGestureRecognizer(longPressRecognizer)
    }
    
    
    final func isSelected(id: Int64) -> Bool {
        return self.selectableObjects[id] ?? false
    }
    
    
    final func selectedIDList() -> [Int64] {
        return self.selectableObjects.filter { $0.value }.map { $0.key }
    }
    
    
    final func notifyDidSelect() {
        self.selectionHandler?.didSelect(selectedIDList())
    }
    
    
    @objc private func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: searchTableView)
            if let indexPath = searchTableView.indexPathForRow(at: touchPoint) {
                onLongPress(at: indexPath)
            }
        }
    }
    
    
    private func onLongPress(at indexPath: IndexPath) {
        guard let dataSection = sections[indexPath.section] as Any as? SearchDataSection<T> else { return }
        let object = dataSection.resultingList[indexPath.row]
        
        var toReload = [indexPath]
        let selectionMode = self.selectionHandler?.selectionMode ?? .single
        
        switch selectionMode {
        case .single:
            if let previouslySelected = selectableObjects.first(where: { $0.value && $0.key != object.id }) {
                let previousId = previouslySelected.key
                selectableObjects[previousId] = false
                
                if let previousSelectedRow = dataSection.resultingList.firstIndex(where: { $0.id == previousId }) {
                    toReload.append(IndexPath(row: previousSelectedRow, section: indexPath.section))
                }
            }
        case .multiple, .manual:
            break
        }
        
        selectableObjects[object.id] = true
        searchTableView.reloadRows(at: toReload, with: .fade)
    }
}


fileprivate class LongPressTouchDelegate<T: UpdatableEntity>: NSObject, UIGestureRecognizerDelegate {
    private let searchTableView: UITableView
    weak var selectionHandler: SearchSelectedObjectHandler?
    var getSection: ((IndexPath) -> SearchTemplateSection<T>)?
    
    init(searchTableView: UITableView) {
        self.searchTableView = searchTableView
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let selectionMode = self.selectionHandler?.selectionMode ?? .single
        if selectionMode == .manual { return false }
        
        let touchPoint = touch.location(in: searchTableView)
        if let indexPath = searchTableView.indexPathForRow(at: touchPoint),
            let _ = getSection?(indexPath) as Any as? SearchDataSection<T>  {
            return true
        }
        
        return false
    }
}
