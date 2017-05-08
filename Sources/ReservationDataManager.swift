//
//  ReservationDataManager
//  Dining
//
//  Created by Paul Ossenbruggen on 2/25/17.
//

import UIKit
import Argo


protocol TableViewDataManagerDelegate : class {
    func update()
}

class ReservationDataManager {
    static let testfileNames = ["FullReservation",
                                "2dishes",
                                "PartialReservation"]
    static var count = 0
    
    // in real code I would try to avoid a singleton if possible.
    static let shared = ReservationDataManager()
    
    weak var delegate : TableViewDataManagerDelegate? = nil

    var reservations : [Reservation] = [] {
        didSet {
            delegate?.update()
        }
    }
    
    func fetchReservations() {
        //
        // if we were going to use network to fetch data it would occur here 
        //
        
        // rotate through tests
        let filename = ReservationDataManager.testfileNames[ReservationDataManager.count]
        
        let url = Bundle.main.url(forResource: filename, withExtension:"json")
        NSLog("Test File \(String(describing: url))")
        let data = try! Data(contentsOf:url!, options: Data.ReadingOptions.uncached)
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let j = json {
            let reservation : Reservation? = decode(j)
        
            // preload
            if let str = reservation?.restaurant.profilePhoto?.urlForSize(desiredSize: CGSize(width: 500, height: 500)),
                let preloadURL = URL(string:str)  {
                UIImageView.loadImageAtURLCache(preloadURL) { image in }
            }
            
            self.reservations = [reservation!] // plural if the user has multiple reservations but not implemented here.
        }

    }
}



