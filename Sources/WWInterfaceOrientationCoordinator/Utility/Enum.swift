//
//  Enum.swift
//  WWInterfaceOrientationCoordinator
//
//  Created by William.Weng on 2026/10/21.
//

import Foundation

/// 表示某個 view 的尺寸要依「另一個軸」的比例來決定
public enum CrossAxisRatio {
    case widthFollowsHeight(CGFloat)    // 寬度 = 高度 * ratio
    case heightFollowsWidth(CGFloat)    // 高度 = 寬度 * ratio
}

/// 計算過程中可能發生的錯誤
public enum DimensionRangeError: Error, Equatable {
    case invalidSize(CGSize?)           // 輸入的容器尺寸無效 (0 / 負數 / NaN / infinity)
    case invalidRatio(CGFloat)          // 跨軸比例無效  (0 / 負數 / NaN / infinity)
    case fractionOutOfRange(CGFloat)    // 依尺寸與 ratio 換算出的比例超出可用範圍 (0.0...1.0)
}
