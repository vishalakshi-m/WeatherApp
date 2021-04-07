//
//  LocationCollectionViewCell.swift
//  WeatherApp
//
//  Created by Mac4Dev1 on 06/04/21.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    
    let locationName: UILabel = {
       let label = UILabel()
        label.text = ""
        label.minimumScaleFactor = 0.25
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.textColor = #colorLiteral(red: 0.1764705882, green: 0.1882352941, blue: 0.1960784314, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        if UIDevice.current.userInterfaceIdiom == .pad {
            label.font = UIFont(name: "Avenir Bold", size: 24.0)
        } else {
            label.font = UIFont(name: "Avenir Bold", size: 16.0)
        }
        return label
    }()
    
    var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: UI_USER_INTERFACE_IDIOM() == .pad ? 20.0 : 16.0)
        button.setTitle("X", for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).withAlphaComponent(0.2)
        
        self.addSubview(locationName)
        self.addSubview(removeButton)
        
        locationName.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            locationName.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            locationName.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            locationName.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),
            
            removeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            removeButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            removeButton.leadingAnchor.constraint(equalTo: locationName.trailingAnchor, constant: 0)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
