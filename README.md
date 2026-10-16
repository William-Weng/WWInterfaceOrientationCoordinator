[English](./README.en.md) | [正體中文](./README.md)

# [WWInterfaceOrientationCoordinator](https://swiftpackageindex.com/William-Weng)

[![Swift-5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWInterfaceOrientationCoordinator)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

一套輕量的 UIKit 工具，用來協調 `UIViewController` 的 **horizontal size class** 變化與 **interface orientation**，特別適合處理 **iPhone Duo** 在外螢幕、內螢幕、展開、半折與旋轉之間的版面切換。

iPhone Duo 的外螢幕通常對應 compact width，內螢幕則通常對應 regular width；App 應依 size class 調整版面，而不是針對每種裝置姿勢寫死 layout。本元件把「監聽 size class 變化」與「取得目前 orientation」收斂到同一個 coordinator，讓 ViewController 不需要散落多處處理 trait 與轉場邏輯。

https://github.com/user-attachments/assets/f8d1eb71-b920-4013-af30-600cbf432366

## ✨ [主要功能](https://medium.com/@iamCoder/device-orientation-modes-in-ios-c86fb3497ede)

- 觀察 `UITraitHorizontalSizeClass` 變化，適合處理 Duo 外螢幕與內螢幕間的 compact／regular 切換。
- 提供 `UIInterfaceOrientation?`，方便在轉場動畫中判斷目前方向。
- 使用 `weak` 持有 `UIViewController`，避免 coordinator 與 VC 互相強持有。
- 將初始狀態、trait 變化與轉場動畫的資訊統一封裝成 `Information`。
- 適合搭配多個 XIB、`UISplitViewController`、sidebar／detail 或 compact／regular 版面。

## 📦 [安裝方式](https://blakecrosley.com/zh-Hant/blog/designing-for-iphone-duo)

### 使用 Swift Package Manager

在 Xcode 中選擇：

`File` → `Add Package Dependencies...`

接著輸入套件 repository URL，選擇要使用的版本，並將套件加入 App target。

如果這是本地套件，也可以在 Xcode 中使用：

`File` → `Add Package Dependencies...` → `Add Local...`

安裝完成後，將該套件匯入目標後，就可以使用了：

```swift
import WWInterfaceOrientationCoordinator
```

## 🧱 [API 總覽](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)

### WWInterfaceOrientationCoordinator

| API | 說明 |
| --- | --- |
| `orientation` | 目前所觀察 view controller 的 interface orientation。若 view controller 尚未加入 window，或無法取得 window scene，則回傳 `nil`。 |
| `horizontalClass` | 目前 view controller trait collection 的 horizontal size class。若 view controller 已被釋放，則回傳 `nil`。 |
| `register(forHorizontalSizeClassChanges:onChange:)` | 註冊 horizontal size class 變更通知。註冊後會立即以目前狀態呼叫 `initial`，之後每當 `UITraitHorizontalSizeClass` 改變時呼叫 `onChange`。 |
| `willTransition(with:animation:completion:)` | 在 view controller 轉場期間，依目前 interface orientation 執行自訂動畫。若無法取得目前方向，則不會呼叫動畫 callback。 |

### WWLayoutEnvironmentInformation

| API | 說明 |
| --- | --- |
| `previousTrait` | 變更前的 Size Class；沒有前值時傳 `nil`。 |
| `currentTrait` | 目前的 Size Class；無法取得時傳 `nil`。 |
| `orientation` | 目前的介面方向；無法取得時傳 `nil`。 |
| `unknown` | 空白／未知的方向資訊。 |
| `isLandscape` | 是否為橫向 UI。 |
| `isPortrait` | 是否為直向 UI。 |
| `isRegularWidth` | 目前的 horizontal size class 是否為 regular。 |
| `isCompactWidth` | 目前的 horizontal size class 是否為 compact。 |
| `didChangeToRegularWidth` | horizontal size class 是否從 compact 變成 regular。 |
| `didChangeToCompactWidth` | horizontal size class 是否從 regular 變成 compact。 |
| `init(previousHorizontalClass:horizontalClass:orientation:)` | 目前所觀察 view controller 的 interface orientation。若 view controller 尚未加入 window，或無法取得 window scene，則回傳 `nil`。 |

### WWTraitSizeClass

| API | 說明 |
| --- | --- |
| `horizontalClass` | horizontal size class；無法取得時傳 `nil`。 |
| `verticalSizeClass` | vertical size class；無法取得時傳 `nil`。 |
| `unknown` | 空白／未知的 Size Class 狀態。 |

## 🧪 [使用範例](https://developer.apple.com/videos/play/wwdc2017/812/)

```swift
import UIKit
import WWInterfaceOrientationCoordinator

final class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private lazy var orientationCoordinator = WWInterfaceOrientationCoordinator(viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orientationCoordinator.register { [weak self] info in
            guard let self else { return }
            updateLayout(info: info)
        } onChange: { [weak self] info in
            guard let self else { return }
            updateLayout(info: info)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        orientationCoordinator.willTransition(with: coordinator) { [weak self] info in
            guard let self else { return }
            updateLayout(info: info)
        }
    }
}

private extension ViewController {
    
    func updateLayout(info: WWLayoutEnvironmentInformation) {

        let orientation = info.orientation ?? .portrait
        let horizontalClass = info.horizontalClass ?? .regular
        
        switch orientation {
        case .landscapeLeft, .landscapeRight: imageView.image = (horizontalClass == .regular) ? .innerLandscape : .outterLandscape
        case .portrait, .portraitUpsideDown: imageView.image = (horizontalClass == .regular) ?.innerPortrait:.outterPortrait
        case .unknown: imageView.image = .outterPortrait
        @unknown default: imageView.image = .outterPortrait
        }
    }
}
```

## Design Notes

- **不要只用 orientation 決定 layout。** Duo 的同一個 orientation 可能對應不同螢幕或折疊姿勢；layout 應優先依 horizontal size class 與實際 view bounds 調整。
- **orientation 適合用於動畫與方向相關行為。** 例如旋轉時改變動畫方向、調整過場效果，或處理媒體播放方向。
- **Coordinator 不擁有 VC。** 它以 `weak` reference 觀察 view controller，因此不會造成 `UIViewController` 與 coordinator 的 retain cycle。
- **callback 請避免強持有 VC。** 若你在 `initial`、`onChange`、`animation` 或 `completion` closure 中 capture `self`，建議視情況使用 `[weak self]`。
