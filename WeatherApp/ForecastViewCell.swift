//
//  ForecastViewCell.swift
//  WeatherApp
//
//  Created by Shota Nozadze on 2/20/20.
//  Copyright © 2020 Shota Nozadze. All rights reserved.
//

import UIKit

class ForecastViewCell: UITableViewCell {
    
    var link: ForecastTableController?
    
    @IBOutlet weak var hour: UILabel!
    @IBOutlet weak var descr: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var iconButt: UIButton!
    
}
