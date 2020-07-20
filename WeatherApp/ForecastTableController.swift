//
//  ForecastTableController.swift
//  WeatherApp
//
//  Created by Shota Nozadze on 2/19/20.
//  Copyright © 2020 Shota Nozadze. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ForecastTableController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var dict = Dictionary<Int, Array<ForecastToShow> >()
    let week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var blur: UIBlurEffect! = nil
    var visualeffect: UIVisualEffectView! = nil
    
    var lat = 41.716667
    var lon = 44.783333
    let appid = "8f3198776615e391e91cdfc2d0fab8dd"
    
    @IBAction func reload(_ sender: Any) {
        visualeffect.effect = UIBlurEffect(style: .regular)
        dict = Dictionary<Int, Array<ForecastToShow> >()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        getCurrentLocation()
        getForecast()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blur = UIBlurEffect(style: .regular)
        visualeffect = UIVisualEffectView(effect: blur)
        
        view.addSubview(visualeffect)
        visualeffect.frame = view.frame
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        getCurrentLocation()
        getForecast()
    }
    
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
    
    func getForecast(){
        let url = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=" + appid

        Alamofire.request(url).responseJSON{
            response in
            
            if let resp = response.result.value {
                let jsonResponse = JSON(resp)
                
                let list = jsonResponse["list"].array!
                                
                for i in list {
                    let main = i["main"]
                    
                    let temp = Int(round(main["temp"].doubleValue - 273.15))
                    let tempStr = "\(String(describing: temp))°C"
                    
                    let weather = i["weather"].array![0]
                    let descr = weather["description"].stringValue
                    
                    let icon = weather["icon"].stringValue
                    
                    let date = i["dt_txt"].stringValue
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dt = dateFormatter.date(from: date)!
                    
                    var day = Calendar.current.component(.weekday, from: dt)
                    let hour = Calendar.current.component(.hour, from: dt)
                    
                    var hourStr = "\(String(describing: hour)):00"
                    
                    if hourStr.count < 5 {
                        hourStr = "0" + hourStr
                    }
                    
                    day = day-2
                    if day < 0 {
                        day = 6
                    }
                    
                    let weekday = self.week[day]
                    
                    let showForecast = ForecastToShow(hour: hourStr, description: descr, weather: tempStr, icon: icon, weekDay: weekday)
                    
                    let index = (self.dict.count) - 1
                    let lastWeekday = self.dict[index]?.first?.weekDay
                    
                    if lastWeekday == weekday {
                        self.dict[index]?.append(showForecast)
                    } else{
                        self.dict[index+1] = [showForecast]
                    }
                }
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.visualeffect.effect = nil
            } else {
                self.activityIndicator.stopAnimating()

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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict[section]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastViewCell", for: indexPath) as! ForecastViewCell
        
        cell.link = self
        
        let elem = dict[indexPath.section]?[indexPath.row]
        
        cell.hour.text = elem?.hour
        cell.descr.text = elem?.description
        cell.temp.text = elem?.weather
        
        let btnImage = UIImage(named: elem!.icon)
        cell.iconButt.setImage(btnImage, for: .normal)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        
        let headerStr = dict[section]?.first?.weekDay
        label.text = headerStr
                
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        
        label.layer.borderColor = UIColor.systemGray4.cgColor
        label.layer.borderWidth = 1.0
        
        label.backgroundColor = UIColor.white
                
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        activityIndicator.stopAnimating()
        
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
