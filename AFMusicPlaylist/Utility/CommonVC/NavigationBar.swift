import UIKit

protocol NavigationBar {
    func setupNavigationBar(title: String?, withImage imageView: UIView?)
}

extension NavigationBar where Self: UIViewController {
    func setupNavigationBar(title: String? = nil, withImage imageView: UIView? = nil) {
        navigationBar(title: title ?? "", bgColor: AFColors.header, textColor: UIColor.white)
        navigationItem.titleView = imageView
    }
    
    
    func animateTitleColor(_ color: UIColor, duration: Double = 1) {
        UIView.animate(withDuration: duration) { [unowned self] () -> Void in
            self.navigationController?.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: color,
                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.ifIpad(22))]
        }
    }
    
    
    func setupNavigationBar(title: String, bgColor: UIColor, textColor: UIColor = UIColor.white) {
        navigationBar(title: title, bgColor: bgColor, textColor: textColor)
    }
    
    
    fileprivate func navigationBar(title: String, bgColor: UIColor, textColor: UIColor) {
        navigationItem.title = title
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: textColor,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.ifIpad(22))]

        navigationController?.navigationBar.barTintColor = bgColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem =
            UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension CommonViewController: NavigationBar { }

