//
//  ReusableView.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/14.
//

import UIKit

protocol ReusableView { }

extension ReusableView {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }
extension UITableViewHeaderFooterView: ReusableView { }
extension UICollectionReusableView: ReusableView { }
