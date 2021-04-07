//
//  Home.swift
//  WeatherApp
//
//  Created by Mac4Dev1 on 03/04/21.
//

import UIKit
import MapKit
import CoreLocation

class Home: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var emptyBookMarksLabel: UILabel!
    
    @IBOutlet var mainListContainer: UIView!
    
    @IBOutlet var collectionViewContainer: UIView!
    
    var locationCollectionView:UICollectionView = {
        var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var locations:[LocationInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCollectionView()
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        if let list = UserDefaults.standard.object(forKey: UserDefaultKeys.Locations.rawValue) as? Data {
            locations = try? PropertyListDecoder().decode([LocationInfo].self, from: list)
            emptyBookMarksLabel.alpha = 0
            mainListContainer.alpha = 1
        }else{
            mainListContainer.alpha = 0
            emptyBookMarksLabel.alpha = 1
        }
        
        // Do any additional setup after loading the view.
    }
    
    func initializeCollectionView(){
        self.view.addSubview(locationCollectionView)
        locationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationCollectionView.leadingAnchor.constraint(equalTo: self.collectionViewContainer.leadingAnchor, constant: 0),
            locationCollectionView.trailingAnchor.constraint(equalTo: self.collectionViewContainer.trailingAnchor, constant: 0),
            locationCollectionView.topAnchor.constraint(equalTo: self.collectionViewContainer.topAnchor, constant: 0),
            locationCollectionView.bottomAnchor.constraint(equalTo: self.collectionViewContainer.bottomAnchor, constant: 0)
        ])
        
        locationCollectionView.delegate = self
        locationCollectionView.dataSource = self
        
        locationCollectionView.register(LocationCollectionViewCell.self, forCellWithReuseIdentifier: "CellID")
    }
    
    @IBAction func addLocationToList(_ sender: Any) {
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.mapView.addAnnotation(annotation)
        
        CLGeocoder().reverseGeocodeLocation(currentLocation) { (placeMarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            
            if let placeMarkArr = placeMarks
            {
                if placeMarkArr.count > 0{
                    if let location = placeMarkArr.first
                    {
                        if let city = location.locality,let countryCode = location.isoCountryCode{
                            let locationInfo = LocationInfo(cityName: city, countryCode: countryCode)
                            if self.locations != nil{
                                if self.locations?.filter({ $0.cityName == city }).count == 0{
                                    self.locations?.append(locationInfo)
                                }
                            }
                            else{
                                self.locations = [locationInfo]
                            }
                            let encodeData = try? PropertyListEncoder().encode(self.locations)
                            UserDefaults.standard.set(encodeData, forKey: UserDefaultKeys.Locations.rawValue)
                            DispatchQueue.main.async {
                                self.mainListContainer.alpha = 1
                                self.locationCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}

extension Home: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}
extension Home:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath) as? LocationCollectionViewCell
        cell?.locationName.text = locations?[indexPath.row].cityName
        
        cell?.removeButton.accessibilityIdentifier = locations?[indexPath.row].cityName
        cell?.removeButton.addTarget(self, action: #selector(RemoveLocationfromList(_:)), for: .touchUpInside)
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: self.collectionViewContainer.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "City") as! City
        nextViewController.currentLocationDetails = locations?[index]
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return UIDevice.current.userInterfaceIdiom == .pad  ? 10 : 5
    }
    
    @objc func RemoveLocationfromList(_ sender: Any){
        
        if let button = sender as? UIButton, let name = button.accessibilityIdentifier{
//            locations =  locations?.filter({ $0.cityName != name })
            
            if let loccationsArr = locations{
                var indexItemToDelete = 0
                for (ind,Location) in loccationsArr.enumerated() {
                    if Location.cityName == name{
                        indexItemToDelete = ind
                    }
                }
                locations?.remove(at: indexItemToDelete)
            }
            
            if locations?.count ?? -1 > 0{
                let data = try? PropertyListEncoder().encode(locations)
                UserDefaults.standard.set(data, forKey: UserDefaultKeys.Locations.rawValue)
            }else{
                UserDefaults.standard.set(nil, forKey: UserDefaultKeys.Locations.rawValue)
                emptyBookMarksLabel.alpha = 1
                mainListContainer.alpha = 0
            }
            locationCollectionView.reloadData()
        }
    }
}
