//
//  Model.swift
//  WWInterfaceOrientationCoordinator
//
//  Created by William.Weng on 2026/10/14.
//

import UIKit

/// 裝置方向與 Size Class 變化後的快照資訊
public struct WWLayoutEnvironmentInformation {
    
    public let previousTrait: WWTraitSizeClass?
    public let currentTrait: WWTraitSizeClass?
    public let orientation: UIInterfaceOrientation?
    
    /// 建立方向與 Size Class 資訊
    /// - Parameters:
    ///   - previousTrait: 變更前的 Size Class；沒有前值時傳 `nil`
    ///   - currentTrait: 目前的 Size Class；無法取得時傳 `nil`
    ///   - orientation: 目前的介面方向；無法取得時傳 `nil`
    public init(previousTrait: WWTraitSizeClass?, currentTrait: WWTraitSizeClass?, orientation: UIInterfaceOrientation?) {
        self.previousTrait = previousTrait
        self.currentTrait = currentTrait
        self.orientation = orientation
    }
}

// MARK: - 公開參數
public extension WWLayoutEnvironmentInformation {
    
    /// 空白／未知的方向資訊
    ///
    /// 適合作為初始值、重置值，或表示「目前沒有任何有效的方向資訊」；三個欄位皆為 `nil`
    static var unknown: Self { .init(previousTrait: nil, currentTrait: nil, orientation: nil) }
}

// MARK: - 公開參數
public extension WWLayoutEnvironmentInformation {
    
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
        currentTrait?.horizontalClass == .regular
    }
    
    /// 目前的 horizontal size class 是否為 compact
    var isCompactWidth: Bool {
        currentTrait?.horizontalClass == .compact
    }
    
    /// 目前的 vertical size class 是否為 regular
    var isRegularHeight: Bool {
        currentTrait?.verticalSizeClass == .regular
    }
    
    /// 目前的 vertical size class 是否為 compact
    var isCompactHeight: Bool {
        currentTrait?.verticalSizeClass == .compact
    }
    
    /// horizontal size class 是否從 compact 變成 regular (常見於 iPhone 直轉橫，或 iPad 進入較寬的顯示環境)
    var didChangeToRegularWidth: Bool {
        previousTrait?.horizontalClass == .compact && currentTrait?.horizontalClass == .regular
    }
    
    /// horizontal size class 是否從 regular 變成 compact
    var didChangeToCompactWidth: Bool {
        previousTrait?.horizontalClass == .regular && currentTrait?.horizontalClass == .compact
    }
}

/// 某一時刻的 horizontal 與 vertical Size Class 狀態
public struct WWTraitSizeClass {
    
    public let horizontalClass: UIUserInterfaceSizeClass?
    public let verticalSizeClass: UIUserInterfaceSizeClass?
    
    /// 建立 Size Class 狀態
    /// - Parameters:
    ///   - horizontalClass: horizontal size class；無法取得時傳 `nil`
    ///   - verticalSizeClass: vertical size class；無法取得時傳 `nil`
    public init(horizontalClass: UIUserInterfaceSizeClass?, verticalSizeClass: UIUserInterfaceSizeClass?) {
        self.horizontalClass = horizontalClass
        self.verticalSizeClass = verticalSizeClass
    }
}

// MARK: - 公開參數
public extension WWTraitSizeClass {
    
    /// 空白／未知的 Size Class 狀態
    ///
    /// 適合作為初始值、重置值，或表示目前沒有任何有效資訊；`horizontalClass`、`verticalSizeClass` 皆為 `nil`
    static var unknown: Self { .init(horizontalClass: nil, verticalSizeClass: nil) }
}
