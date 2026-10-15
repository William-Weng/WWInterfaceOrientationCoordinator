//
//  Model.swift
//  WWInterfaceOrientationCoordinator
//
//  Created by William.Weng on 2026/10/14.
//

import UIKit

/// 方向與水平 Size Class 變化的資訊
public struct WWOrientationInformation {
    
    public let previousHorizontalClass: UIUserInterfaceSizeClass?
    public let horizontalClass: UIUserInterfaceSizeClass?
    public let orientation: UIInterfaceOrientation?
    
    /// 初始化方向資訊
    /// - Parameters:
    ///   - previousHorizontalClass: 變更前的 horizontal size class；若是第一次取得資訊或沒有前值，可傳 `nil`
    ///   - horizontalClass: 目前的 horizontal size class；若暫時無法取得，可傳 `nil`
    ///   - orientation: 目前的 interface orientation；若暫時無法取得，可傳 `nil`
    public init(previousHorizontalClass: UIUserInterfaceSizeClass?, horizontalClass: UIUserInterfaceSizeClass?, orientation: UIInterfaceOrientation?) {
        self.previousHorizontalClass = previousHorizontalClass
        self.horizontalClass = horizontalClass
        self.orientation = orientation
    }
}

// MARK: - 公開參數
public extension WWOrientationInformation {
    
    /// 空白／未知的方向資訊
    ///
    /// 適合作為初始值、重置值，或表示「目前沒有任何有效的方向資訊」；三個欄位皆為 `nil`
    static var `nil`: Self { .init(previousHorizontalClass: nil, horizontalClass: nil, orientation: nil) }
}

// MARK: - 公開參數
public extension WWOrientationInformation {
    
    /// 是否為橫向 UI
    var isLandscape: Bool {
        orientation?.isLandscape ?? false
    }
    
    /// 是否為直向 UI
    var isPortrait: Bool {
        orientation?.isPortrait ?? false
    }
    
    /// 目前的 horizontal size class 是否為 regular
    var isRegularWidth: Bool {
        horizontalClass == .regular
    }
    
    /// 目前的 horizontal size class 是否為 compact
    var isCompactWidth: Bool {
        horizontalClass == .compact
    }
    
    /// horizontal size class 是否從 compact 變成 regular (常見於 iPhone 直轉橫，或 iPad 進入較寬的顯示環境)
    var didChangeToRegularWidth: Bool {
        previousHorizontalClass == .compact && horizontalClass == .regular
    }
    
    /// horizontal size class 是否從 regular 變成 compact
    var didChangeToCompactWidth: Bool {
        previousHorizontalClass == .regular && horizontalClass == .compact
    }
}
