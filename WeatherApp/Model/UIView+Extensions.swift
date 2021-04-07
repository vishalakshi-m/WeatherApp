//
//  UIView+Extensions.swift
//  WeatherApp
//
//  Created by Mac4Dev1 on 07/04/21.
//

import Foundation
import UIKit

extension UIView{
    func activityStartAnimating(activityColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), backgroundColor: UIColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9607843137, alpha: 1).withAlphaComponent(0.2)) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        backgroundView.addSubview(activityIndicator)
        self.bringSubviewToFront(backgroundView)
        self.isUserInteractionEnabled = false
        UIApplication.shared.keyWindow?.rootViewController?.children.last?.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.addSubview(backgroundView)
    }
    
    func activityStopAnimating() {
        if let background = viewWithTag(475647){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
        UIApplication.shared.keyWindow?.rootViewController?.children.last?.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
}
