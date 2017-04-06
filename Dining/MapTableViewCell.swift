//
//  MapTableViewCell.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/26/17.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell  {
    @IBOutlet weak var titleView : UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var title : String = ""
    var cellReuseIdentifier: String = ""
    var items: [Any] = []
    var configure: (_ cell:Any, _ model: Any) -> Void = {cell, model in }

    var height : CGFloat {
        return 360.0
    }

    required init(cellReuseIdentifier: String,
                           title: String,
                           configure: @escaping (_ cell: Any,_ model: Any) -> Void,
                           items: [Any]) {
        self.title = title
        self.cellReuseIdentifier = cellReuseIdentifier
        self.items = items
        self.configure = configure

        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)

        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct ViewData {
        let title: String
        let location: CLLocation
    }
    
    var viewData: ViewData? {
        didSet {
            titleView!.text = viewData?.title
            if let location = viewData?.location {
                self.updateMapView(location: location)
            }
        }
    }
    
    func updateMapView(location: CLLocation) {
        
        var region = MKCoordinateRegion()
        region.center = location.coordinate
        region.span.latitudeDelta = 0.001
        region.span.longitudeDelta = 0.001
        
        mapView.setRegion(region, animated:false)
    }
}

extension MapTableViewCell.ViewData {
    init(restaurant: Restaurant) {
        self.title = restaurant.city
        self.location = restaurant.location
    }
}


