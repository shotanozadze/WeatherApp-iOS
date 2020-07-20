//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shota Nozadze on 2/1/20.
//  Copyright © 2020 Shota Nozadze. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var shareWeather = ""
    @IBOutlet weak var blur: UIVisualEffectView!
    
    var lat = 41.716667
    var lon = 44.783333
    let appid = "8f3198776615e391e91cdfc2d0fab8dd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
                
        getCurrentLocation()
        getWeather()
    }
    
    @IBAction func reload(_ sender: Any) {
        blur.effect = UIBlurEffect(style: .regular)
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        getCurrentLocation()
        getWeather()
    }
    
    @IBAction func share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [shareWeather], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var iconButt: UIButton!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var couldsButt: UIButton!
    @IBOutlet weak var humidityButt: UIButton!
    @IBOutlet weak var pressureButt: UIButton!
    @IBOutlet weak var speedButt: UIButton!
    @IBOutlet weak var degButt: UIButton!
    
    @IBOutlet weak var cloudsLab: UILabel!
    @IBOutlet weak var humidityLab: UILabel!
    @IBOutlet weak var pressureLab: UILabel!
    @IBOutlet weak var speedLab: UILabel!
    @IBOutlet weak var degLab: UILabel!
    
    func getCurrentLocation(){
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
    }
    
    func getWeather(){
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=" + appid
        
        Alamofire.request(url).responseJSON{
            response in
            
            if let resp = response.result.value {
                let jsonResponse = JSON(resp)
                let weather = jsonResponse["weather"].array![0]
                let main = jsonResponse["main"]
                let sys = jsonResponse["sys"]
                
                let locName = jsonResponse["name"].stringValue + ", " + sys["country"].stringValue
                
                let temp = Int(round(main["temp"].doubleValue - 273.15))
                let tempStr = "\(String(describing: temp))°C"
                
                let descr = weather["main"].stringValue
                let currWeather = tempStr + " | " + descr
                
                let pressure = main["pressure"].doubleValue
                let pressureStr = "\(pressure) hPa"
                let humidity = main["humidity"].stringValue + "mm"
                
                let wind = jsonResponse["wind"]
                let windSpeed = wind["speed"].doubleValue
                let speedStr = "\(windSpeed) km/h"
                let windDeg = wind["deg"].stringValue
                
                let clouds = jsonResponse["clouds"]
                let allClouds = clouds["all"].stringValue + "%"
                
                let icon = weather["icon"].stringValue
                
                let btnImage = UIImage(named: "a" + icon)
                self.iconButt.setImage(btnImage, for: .normal)
                
                self.locLabel.text = locName
                self.weatherLabel.text = currWeather
                
                self.cloudsLab.text = allClouds
                self.humidityLab.text = humidity
                self.pressureLab.text = pressureStr
                self.speedLab.text = speedStr
                self.degLab.text = windDeg
                
                if self.shareWeather.count == 0 {
                    self.shareWeather += locName + " - " + currWeather + "; clouds: " + allClouds + "; humidity: " + humidity + "; pressure: " + pressureStr + "; speed: " + speedStr + "; deg: " + windDeg + "."
                }
                
                self.activityIndicator.stopAnimating()
                self.blur.effect = nil
            } else {
                self.activityIndicator.stopAnimating()
                self.shareButt.isEnabled = false
                
                let errorView = UIView()
                errorView.backgroundColor = UIColor.white
                errorView.frame = self.view.frame
                self.view.addSubview(errorView)
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label.center = self.view.center
                label.textAlignment = .center
                label.text = "ERROR: No Internet!"

                errorView.addSubview(label)
            }
            
        }
    }
    
    @IBOutlet weak var shareButt: UIBarButtonItem!
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        activityIndicator.stopAnimating()
        shareButt.isEnabled = false
        
        let errorView = UIView()
        errorView.backgroundColor = UIColor.white
        errorView.frame = self.view.frame
        self.view.addSubview(errorView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = self.view.center
        label.textAlignment = .center
        label.text = "ERROR: Turn on location!"

        errorView.addSubview(label)
    }
    
}
