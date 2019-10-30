import UIKit

struct LoaderStyle {
    static let light = LoaderStyle(bgColor: UIColor.white, indicatorColor: UIColor.black, opacity: 0.9)
    static let dark = LoaderStyle(bgColor: UIColor.black, indicatorColor: UIColor.white, opacity: 0.65)
    static let clearDark = LoaderStyle(bgColor: UIColor.clear, indicatorColor: UIColor.black, opacity: 0.9)
    static let clearLight = LoaderStyle(bgColor: UIColor.clear, indicatorColor: UIColor.white, opacity: 0.9)
    
    let bgColor: UIColor
    let indicatorColor: UIColor
    let opacity: CGFloat
}

extension UIView {
    fileprivate static let loaderTag = 9999
    fileprivate static let blockerViewTag = 9998

    
    final var loaderViewIsPresented: Bool {
        return directSubviewWithTag(UIView.loaderTag) != nil
    }
    
    
    final func showLoader(style: LoaderStyle = .dark, scaleByParentSize: Bool = false) {
        self.showLoaderByTag(UIView.loaderTag, style: style, scaleByParentSize: scaleByParentSize)
    }
    
    
    final func removeLoader(_ completionHandler: (() -> ())? = nil) {
        removeLoaderByTag(UIView.loaderTag, completionHandler: completionHandler)
    }
    
    
    final func removeLoaderImmediately() {
        removeLoaderImmediatelyByTag(UIView.loaderTag)
    }
    
    
    final func blockUserInteraction() {
        let block = UIView()
        block.isUserInteractionEnabled = true
        block.translatesAutoresizingMaskIntoConstraints = false
        block.backgroundColor = UIColor.clear
        block.tag = UIView.blockerViewTag
        
        addSubview(block)
        block.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        block.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        block.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        block.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        setNeedsLayout()
        bringSubviewToFront(block)
    }
    
    
    final func unblockUserInteraction() {
        directSubviewWithTag(UIView.blockerViewTag)?.removeFromSuperview()
    }
    
    
    fileprivate func showLoaderByTag(_ tag: Int, style: LoaderStyle = .dark, scaleByParentSize: Bool = false) {
        let loaderView = directSubviewWithTag(tag)
        loaderView?.removeFromSuperview()
        isUserInteractionEnabled = false
        
        let container = UIView()
        container.tag = UIView.loaderTag
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        let indicatorContainer = UIView()
        indicatorContainer.backgroundColor = style.bgColor
        indicatorContainer.alpha = style.opacity
        indicatorContainer.layer.cornerRadius = 5
        indicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(indicatorContainer)
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = style.indicatorColor
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicatorContainer.addSubview(indicator)
        
        let views: [String: Any] = ["container": container,
                                    "indicator": indicator]
        var cnts = [NSLayoutConstraint]()
        
        cnts += NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|",
                                               options: [], metrics: nil, views: views)
        cnts += NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|",
                                               options: [], metrics: nil, views: views)
        cnts += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: [],
                                               metrics: nil, views: views)
        cnts += NSLayoutConstraint.constraints(withVisualFormat: "V:|[indicator]|", options: [],
                                               metrics: nil, views: views)
        
        
        if scaleByParentSize {
            cnts += [
                indicatorContainer.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.3),
                indicatorContainer.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.3),
                indicatorContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicatorContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ]
        } else {
            let size = UIScreen.main.bounds.deviceHeight * 0.09
            cnts += [
                indicatorContainer.widthAnchor.constraint(equalToConstant: size),
                indicatorContainer.heightAnchor.constraint(equalToConstant: size),
                indicatorContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicatorContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ]
        }
        
        NSLayoutConstraint.activate(cnts)
        setNeedsLayout()
        bringSubviewToFront(container)
    }
    
    
    fileprivate func removeLoaderImmediatelyByTag(_ tag: Int) {
        let loaderView = directSubviewWithTag(tag)
        isUserInteractionEnabled = true
        loaderView?.removeFromSuperview()
        loaderView?.alpha = 0
    }
    
    
    fileprivate func removeLoaderByTag(_ tag: Int, completionHandler: (() -> Void)? = nil) {
        let loaderView = directSubviewWithTag(tag)
        isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.7, animations: {
            loaderView?.alpha = 0
        }) { _ in
            completionHandler?()
            loaderView?.removeFromSuperview()
        }
    }
    
    
    fileprivate func directSubviewWithTag(_ tag: Int) -> UIView? {
        return subviews.first { $0.tag == tag }
    }
}
