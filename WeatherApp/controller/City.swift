//
//  City.swift
//  WeatherApp
//
//  Created by Mac4Dev1 on 03/04/21.
//

import UIKit
import CoreLocation

class City: UIViewController {

    var currentLocationDetails: LocationInfo?
    
    @IBOutlet var HeadingLabel: UILabel!
    
    @IBOutlet var temperature: UILabel!
    
    @IBOutlet var clouds: UILabel!
    
    @IBOutlet var windSpeed: UILabel!
    
    @IBOutlet var humidity: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.activityStartAnimating()
        
        if let location = currentLocationDetails{
            self.getWeatherInfo(cityName: location.cityName, countryCode: location.countryCode)
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func getWeatherInfo(cityName: String,countryCode: String)
    {
        guard let requestURL = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(cityName),\(countryCode)&appid=42f5dddd0ad35a92b5a346af6f05bc28") else {
            print("cannot generate URL")
            return
        }
        
        ServiceUtils.shared.performTask(for: requestURL) { result in
            switch result {
            case .success(let output):
                
                
                DispatchQueue.main.async {
                    
                    self.view.activityStopAnimating()
                    let response = output.0
                    let outPutResponse: NetworkResponse = ServiceUtils.shared.verifyStatus(response: response)
                    let data = output.1
//                    print("Ouput Response is \(String(describing: String(data: data, encoding: .utf8)))")
                    if outPutResponse == .success {
                        let weatherInfo = try? JSONDecoder().decode(WeatherData.self, from: data)
                        self.HeadingLabel.text = (self.HeadingLabel.text ?? "") + " in \(weatherInfo?.name ?? "")"
                        if let temperatureVal = weatherInfo?.main?.temp,let windSpeed = weatherInfo?.wind?.speed {
                            self.temperature.text = "\(String(format: "%.0f", temperatureVal - 273.15))˚ "
                            self.windSpeed.text = "\(windSpeed) meter/sec"
                        }
                        self.humidity.text = "\(weatherInfo?.main?.humidity ?? 0) %"
                        self.clouds.text = "\(weatherInfo?.weather?.first?.main ?? "")"
                        
                    }
                }
              
                case .failure(let error):
                DispatchQueue.main.async {
                    let alertAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                        self.view.activityStartAnimating()
                        
                        if let location = self.currentLocationDetails{
                            self.getWeatherInfo(cityName: location.cityName, countryCode: location.countryCode)
                        }
                    }
                    
                    let AlertController = UIAlertController(title: "Weather App", message: error.localizedDescription, preferredStyle: .alert)
                    AlertController.addAction(alertAction)
                    
                    AlertController.present(self, animated: false, completion: nil)
                                        
                    print("Error is \(error.localizedDescription)")

                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
