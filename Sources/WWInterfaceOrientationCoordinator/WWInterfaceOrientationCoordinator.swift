//
//  WWInterfaceOrientationCoordinator.swift
//  WWInterfaceOrientationCoordinator
//
//  Created by William.Weng on 2026/10/14.
//

import UIKit

/// 協調 `UIViewController` 的方向（orientation）與 horizontal size class 變化
///
/// 此物件以 weak reference 持有 view controller，可用來：
/// - 讀取目前的 interface orientation 與 horizontal size class
/// - 註冊 horizontal size class 變更時的回呼
/// - 在 view controller 轉場動畫期間提供目前的 orientation
public class WWInterfaceOrientationCoordinator {
    
    private weak var viewController: UIViewController?  // 觀察目標的 view controller
    
    /// 建立 orientation coordinator
    ///
    /// - Parameter viewController: 要觀察與協調的 view controller；Coordinator 不會強持有它
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - 公開參數
public extension WWInterfaceOrientationCoordinator {
    
    /// 目前的 interface orientation
    var orientation: UIInterfaceOrientation? {
        viewController?.view.window?.windowScene?.effectiveGeometry.interfaceOrientation
    }
    
    /// 目前的 horizontal size class
    var horizontalClass: UIUserInterfaceSizeClass? {
        viewController?.traitCollection.horizontalSizeClass
    }
    
    /// 目前的 vertical size class
    var verticalSizeClass: UIUserInterfaceSizeClass? {
        viewController?.traitCollection.verticalSizeClass
    }
}

// MARK: - 公開參數
@available(iOS 27.1, *)
public extension WWInterfaceOrientationCoordinator {
    
    /// 獲取畫面上所有【物理存在】的摺疊線/分割區域
    /// - Note: 包含「不活躍狀態」（例如：當摺疊手機完全攤平時，折痕在物理上存在但此時寬度為 0 ）
    /// - Purpose: 適合用來決定巨觀的網格（Grid）或分欄結構，避免使用者在開合螢幕時畫面發生大幅度跳動
    var divisionRegions: [UIView.ReservedRegion] {
        return viewController?.view.reservedRegions(kind: .division, options: [.includeInactive]) ?? []
    }
    
    /// 獲取畫面上所有【當前正在遮擋像素】的硬體/系統區域
    /// - Note: 預設只包含「活躍狀態」（例如：動態島、瀏海、挖孔鏡頭，或當前顯示的系統控制列）
    /// - Purpose: 適合用來做 UI 的邊距避讓（Padding），確保按鈕或重要文字絕對不會被物理硬體遮住
    var occlusionRegions: [UIView.ReservedRegion] {
        return viewController?.view.reservedRegions(kind: .occlusion) ?? []
    }
    
    /// 獲取當前【真正被折起、看得見】的第一個主要摺疊線區域
    /// - Logic: 直接從已獲取的 `divisionRegions` 中，高效篩選出第一個狀態為 `isActive` 的區域
    /// - Purpose: 適合用來啟動微觀的 UI 調整，例如：當此屬性不為 nil 時，代表手機正處於半折疊的「懸停模式（Flex Mode）」，可將特定內容移開摺疊軸
    var activeDivisionRegion: UIView.ReservedRegion? {
        return divisionRegions.first { $0.isActive }
    }
}

// MARK: - 公開函式
@available(iOS 27.1, *)
public extension WWInterfaceOrientationCoordinator {
    
    /// 依跨軸比例建立 `UISplitArrangement.DimensionRange`
    ///
    /// - Parameters:
    ///   - size: 用來換算比例的容器尺寸。寬度與高度都必須是大於 0 的有限數值
    ///   - ratio: 跨軸比例，決定要讓寬度跟隨高度，或高度跟隨寬度
    ///   - minimum: 最小尺寸，預設為 `.absolute(0)`
    ///   - maximum: 最大尺寸；若為 `nil`，則使用 `.fractional(1)`，表示不超過可用空間
    ///
    /// - Returns:
    ///   - `.success(DimensionRange)`：計算成功時回傳可套用到 arrangement 的尺寸範圍
    ///   - `.failure(DimensionRangeError)`：尺寸或比例無效時回傳對應錯誤
    static func crossAxisDimensionRange(with size: CGSize, ratio: CrossAxisRatio, minimum: UISplitArrangement.Dimension = .absolute(0), maximum: UISplitArrangement.Dimension? = nil) -> Result<UISplitArrangement.DimensionRange, DimensionRangeError> {

        guard size.width.isFinite, size.height.isFinite,
              size.width > 0, size.height > 0
        else {
            return .failure(.invalidSize(size))
        }

        let rawRatio: CGFloat
        
        switch ratio {
        case .widthFollowsHeight(let value): rawRatio = value
        case .heightFollowsWidth(let value): rawRatio = value
        }
        
        guard rawRatio.isFinite, rawRatio >= 0 else { return .failure(.invalidRatio(rawRatio)) }

        let preferredFraction: CGFloat

        switch ratio {
        case .widthFollowsHeight(let heightRatio):
            let targetWidth = size.height * heightRatio
            preferredFraction = targetWidth / size.width
        case .heightFollowsWidth(let widthRatio):
            let targetHeight = size.width * widthRatio
            preferredFraction = targetHeight / size.height
        }
        
        guard preferredFraction.isFinite else { return .failure(.invalidRatio(rawRatio)) }

        let clampedFraction = min(max(preferredFraction, 0.0), 1.0)
        var range = UISplitArrangement.DimensionRange()
        
        range.minimum = minimum
        range.preferred = .fractional(clampedFraction)
        range.maximum = maximum ?? .fractional(1.0)
        
        return .success(range)
    }
}


// MARK: - 公開函式
public extension WWInterfaceOrientationCoordinator {
    
    /// 註冊 horizontal size class 變更通知，並立即回報一次目前狀態
    ///
    /// 註冊後會先以 `initial` 回報目前的 horizontal size class 與 orientation；之後每當 `UITraitHorizontalSizeClass` 改變，便以 `handler` 回報新舊值
    ///
    /// - Parameters:
    ///   - initial: 註冊完成後立即呼叫的回呼，用來處理目前的初始狀態
    ///   - handler: horizontal size class 改變時呼叫的回呼，提供變更前後的 size class 與目前 orientation
    @MainActor
    func register(forHorizontalSizeClassChanges initial: @escaping (WWLayoutEnvironmentInformation) -> Void, onChange handler: @escaping (WWLayoutEnvironmentInformation) -> Void) {
        
        guard let viewController else { return }
        
        var previousTrait: WWTraitSizeClass = .unknown
        var currentTrait: WWTraitSizeClass = .init(horizontalClass: horizontalClass, verticalSizeClass: verticalSizeClass)
        
        initial(.init(previousTrait: previousTrait, currentTrait: currentTrait, orientation: orientation))
        
        viewController.registerForTraitChanges([UITraitHorizontalSizeClass.self]) { [weak self] (viewController: UIViewController, previousTraitCollection: UITraitCollection) in
            
            guard let self else { return }
            
            previousTrait = .init(horizontalClass: previousTraitCollection.horizontalSizeClass, verticalSizeClass: previousTraitCollection.verticalSizeClass)
            currentTrait = .init(horizontalClass: horizontalClass, verticalSizeClass: verticalSizeClass)
            
            handler(.init(previousTrait: previousTrait, currentTrait: currentTrait, orientation: orientation))
        }
    }
        
    /// 在 view controller 轉場動畫期間，使用目前 orientation 執行自訂動畫
    ///
    /// - Parameters:
    ///   - coordinator: 由 `willTransition(to:with:)` 提供的轉場協調器
    ///   - animation: 與轉場同時執行的動畫回呼
    ///   - completion: 轉場動畫結束後呼叫的回呼，可取得轉場 context
    func willTransition(with coordinator: UIViewControllerTransitionCoordinator, animation: @escaping (WWLayoutEnvironmentInformation) -> Void, completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) {
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            
            guard let self else { return }
            
            let previousTrait: WWTraitSizeClass = .unknown
            let currentTrait: WWTraitSizeClass = .init(horizontalClass: horizontalClass, verticalSizeClass: verticalSizeClass)
                        
            if let orientation {
                animation(.init(previousTrait: previousTrait, currentTrait: currentTrait, orientation: orientation))
            }
            
        }, completion: { context in
            completion?(context)
        })
    }
}
