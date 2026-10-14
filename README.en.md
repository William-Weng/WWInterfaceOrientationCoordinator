[English](./README.en.md) | [正體中文](./README.md)

# [WWInterfaceOrientationCoordinator](https://swiftpackageindex.com/William-Weng)

[![Swift-5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWInterfaceOrientationCoordinator)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

A lightweight UIKit utility for coordinating changes to a `UIViewController`’s horizontal size class and interface orientation, particularly useful for adapting layouts on iPhone Duo across its outer and inner displays, unfolding, partially folded configurations, and rotation.

The outer display of iPhone Duo typically uses a compact width, while the inner display typically uses a regular width. Apps should adapt their layouts based on size classes rather than hardcoding a layout for every device configuration. This component brings size class observation and current orientation access together in a single coordinator, keeping trait and transition handling from being scattered throughout your view controller.

https://github.com/user-attachments/assets/f8d1eb71-b920-4013-af30-600cbf432366

## ✨ Features

- Observes `UITraitHorizontalSizeClass` changes to support compact/regular layout transitions between Duo’s outer and inner displays.
- Provides `UIInterfaceOrientation?` for accessing the current interface orientation during transition animations.
- Holds a weak reference to `UIViewController` to avoid mutual strong references between the coordinator and the view controller.
- Encapsulates initial state, trait changes, and transition animation information in a unified `Information` structure.
- Works well with multiple XIBs, `UISplitViewController`, sidebar/detail interfaces, and compact/regular layouts.

## 📦 Installation

### Swift Package Manager

In Xcode, select:

`File` → `Add Package Dependencies...`

Enter the package repository URL, select the version you want to use, and add the package to your app target.

For a local package, select:

`File` → `Add Package Dependencies...` → `Add Local...`

Once the package has been added to your target, import it to get started:

```swift
import WWInterfaceOrientationCoordinator
```

## 🧱 API Overview

| API | Description |
| --- | --- |
| `orientation` | The current interface orientation of the observed view controller. Returns `nil` if the view controller is not attached to a window or its window scene is unavailable. |
| `horizontalClass` | The current horizontal size class from the view controller’s trait collection. Returns `nil` if the view controller has been deallocated. |
| `register(forHorizontalSizeClassChanges:onChange:)` | Registers for horizontal size class changes. Calls `initial` immediately with the current state, then calls `onChange` whenever `UITraitHorizontalSizeClass` changes. |
| `willTransition(with:animation:completion:)` | Runs a custom animation alongside a view controller transition, using the current interface orientation. If the orientation cannot be determined, the animation callback is not called. |

## 🧪 Usage Example

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
    
    func updateLayout(info: WWOrientationInformation) {
        
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

- Do not rely solely on orientation to determine your layout. On Duo, the same orientation may correspond to different displays or folding configurations. Prioritize the horizontal size class and actual view bounds when adapting your layout.
- Use orientation for animations and orientation-specific behavior. Examples include changing the direction of an animation during rotation, adjusting transition effects, or handling media playback orientation.
- The coordinator does not own the view controller. It observes the view controller through a weak reference, avoiding a retain cycle between `UIViewController` and the coordinator.
- Avoid strongly capturing the view controller in callbacks. If an `initial`, `onChange`, `animation`, or `completion` closure captures `self`, use `[weak self]` where appropriate.
