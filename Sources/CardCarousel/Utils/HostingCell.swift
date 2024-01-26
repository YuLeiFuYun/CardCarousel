//
//  HostingCell.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/12.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
class HostingCell<Content: View>: UICollectionViewCell {
    
    /// Controller to host the SwiftUI View
    private(set) var host: UIHostingController<Content>?
    
    /// Add host controller to the heirarchy
    func embed(in parent: UIViewController, withView content: Content) {
        if let host = self.host {
            host.rootView = content
            host.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: content)
            
            parent.addChild(host)
            host.didMove(toParent: parent)
            self.contentView.addSubview(host.view)
            self.host = host
        }
    }
    
    // MARK: Controller + view clean up
    
    deinit {
        host?.willMove(toParent: nil)
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        host = nil
    }
}
