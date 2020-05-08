//
//  ViewController.swift
//  Sample
//
//  Created by Stas Kochkin on 04.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import UIKit
import Appodeal


final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didInitialiseAd),
            name: .AdDidInitialize,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func didInitialiseAd() {
        Appodeal.showAd(.bannerTop, rootViewController: self)
    }
}

