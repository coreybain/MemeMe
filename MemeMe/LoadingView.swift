//
//  LoadingView.swift
//  MemeMe
//
//  Created by Corey Baines on 24/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LoadingView {
    
    
    static var thinIndeterminate: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.thicknessRatio = 0.02
        progress.indeterminateProgress = 0.80
        progress.indeterminateDuration = 1.0
        progress.progressTintColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        return progress
    }()
    
    
    static var loadingImageView: UIView = {
        let loadingImageView = UIView()
        let loadingImage = UIImage(named: "spiritdevslarge")
        let loadingUIVIew = UIImageView(image: loadingImage)
        loadingImageView.addSubview(loadingUIVIew)
        loadingUIVIew.snp_makeConstraints { (make) in
            make.size.equalTo(loadingImageView)
            make.center.equalTo(loadingImageView)
        }
        return loadingImageView
/*
        let loadingImage = UIImage(named: "spiritdevslarge")
        let loadingUIVIew = UIImageView(image: loadingImage)
        loadingUIVIew.snp_makeConstraints { (make) in
            make.size.equalTo(lo)
        }
 */
    }()
    
    class func loadingSpinner(mainView:UIView) {
        mainView.addSubview(loadingImageView)
        mainView.addSubview(thinIndeterminate)
        thinIndeterminate.snp_makeConstraints { (make) in
            make.size.equalTo(56)
            make.center.equalTo(mainView)
        }
        loadingImageView.snp_makeConstraints { (make) in
            make.size.equalTo(32)
            make.center.equalTo(mainView)
        }

    }
    
    class func startSpinning(mainView:UIView) {
        loadingSpinner(mainView)
        thinIndeterminate.enableIndeterminate()
    }
    
    class func stopSpinning() {
        thinIndeterminate.removeFromSuperview()
        loadingImageView.removeFromSuperview()
    }
    
    
    
    
}