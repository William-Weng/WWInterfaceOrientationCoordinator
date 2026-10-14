//
//  WWOrientationInformation.swift
//  WWInterfaceOrientationCoordinator
//
//  Created by William.Weng on 2026/10/14.
//

import UIKit

/// 描述一次 horizontal size class 或方向變化時的相關資訊
public struct WWOrientationInformation {
    public let previousHorizontalClass: UIUserInterfaceSizeClass?   // 變更前的 horizontal size class
    public let horizontalClass: UIUserInterfaceSizeClass?           // 目前的 horizontal size class
    public let orientation: UIInterfaceOrientation?                 // 目前的 interface orientation
}
