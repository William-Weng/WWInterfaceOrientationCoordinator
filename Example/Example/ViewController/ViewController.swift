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
    
    private let foldBox = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFolderView()
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 27.1, *) {
            if let region = orientationCoordinator.activeDivisionRegion {
                foldBox.frame = region.frame
            } else {
                foldBox.frame = .zero
            }
        }
    }
}

private extension ViewController {
    
    func initFolderView() {
        
        foldBox.layer.borderColor = UIColor.systemRed.cgColor
        foldBox.layer.borderWidth = 2
        foldBox.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        foldBox.isUserInteractionEnabled = false
        
        view.addSubview(foldBox)
    }

    func updateLayout(info: WWLayoutEnvironmentInformation) {
        
        let orientation = info.orientation ?? .portrait
        let horizontalClass = info.currentTrait?.horizontalClass ?? .regular
        
        switch orientation {
        case .landscapeLeft, .landscapeRight: imageView.image = (horizontalClass == .regular) ? .innerLandscape : .outterLandscape
        case .portrait, .portraitUpsideDown: imageView.image = (horizontalClass == .regular) ?.innerPortrait:.outterPortrait
        case .unknown: imageView.image = .outterPortrait
        @unknown default: imageView.image = .outterPortrait
        }
    }
}
