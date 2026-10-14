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
    /// - Parameter viewController: 要觀察與協調的 view controller；Coordinator 不會強持有它。
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
    func register(forHorizontalSizeClassChanges initial: @escaping (WWOrientationInformation) -> Void, onChange handler: @escaping (WWOrientationInformation) -> Void) {
        
        guard let viewController else { return }
        
        initial(.init(previousHorizontalClass: nil, horizontalClass: horizontalClass, orientation: orientation))
        
        viewController.registerForTraitChanges([UITraitHorizontalSizeClass.self]) { [weak self] (viewController: UIViewController, previousTraitCollection: UITraitCollection) in
            guard let self else { return }
            handler(.init(previousHorizontalClass: previousTraitCollection.horizontalSizeClass, horizontalClass: horizontalClass, orientation: orientation))
        }
    }
    
    /// 在 view controller 轉場動畫期間，使用目前 orientation 執行自訂動畫
    ///
    /// - Parameters:
    ///   - coordinator: 由 `willTransition(to:with:)` 提供的轉場協調器
    ///   - animation: 與轉場同時執行的動畫回呼
    ///   - completion: 轉場動畫結束後呼叫的回呼，可取得轉場 context
    func willTransition(with coordinator: UIViewControllerTransitionCoordinator, animation: @escaping (WWOrientationInformation) -> Void, completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) {
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self else { return }
            if let orientation { animation(.init(previousHorizontalClass: nil, horizontalClass: horizontalClass, orientation: orientation)) }
        }, completion: { context in
            completion?(context)
        })
    }
}
