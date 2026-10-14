//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/10/14.
//

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
