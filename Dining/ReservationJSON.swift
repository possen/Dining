//
//  Reservation.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/24/17.
//
// I started this, thinking I needed it but then realized you already load them.
// So I did not fully debug it. My approach was to add an extension to allow ecapsulation of the
// initialzation of the objects. I debated keeping this in here but figured it might be interesting 
// but don't consider it part of the official submission.
//

import Foundation
import CoreLocation

extension PhotoSize {
    init?(json: [String: Any]) {
        guard let widthString = json["width"] as? String,
              let width = Int(widthString),
              let heightString = json["height"] as? String,
              let height = Int(heightString),
              let uri = json["uri"] as? String else {
                return nil
        }
        
        self.width = width
        self.height = height
        self.uri =  uri
    }
}

extension Photo {
    init?(json: [String: Any]) {
        guard let photoSizes = json["references"] as? [Any],
              let photoId = json["id"] as? String,
              let name = json["name"] as? String else {
                return nil
        }
        self.photoSizes = photoSizes.flatMap {
            let photoSize = $0 as? [String: Any]
            return photoSize != nil ? PhotoSize(json: photoSize!) : nil
        }
        self.photoId = photoId
        self.name = name
    }
}

extension Snippet {
    init?(json: [String: Any]) {
        guard let content = json["content"] as? String,
            let rangeDict = json["range"] as? [String: Any],
            let location = rangeDict["location"] as? Int,
            let length = rangeDict["location"] as? Int,
            let highlights = json["highlights"] as? [[String: Any]] else {
                return nil
        }
        
        self.content = content
        self.range = NSRange(location:location, length: length)
        self.highlights = highlights.flatMap {
            guard let range = $0 as? [String: String],
                  let locationString = range["location"],
                  let lengthString = range["legnth"],
                  let location = Int(locationString),
                  let length = Int(lengthString) else {
                    return nil
            }
            return NSRange(location: location, length: length)
        }
    }
}

extension Dish {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
              let name = json["name"] as? String,
              let photos = json["photos"] as? [Any],
              let snippetStr = json["snippet"] as? [String : Any],
              let snippet = Snippet(json: snippetStr) else {
                return nil
        }
        self.id = id
        self.name = name
        
        self.photos = photos.flatMap {
            let photo = $0 as? [String: Any]
            return photo != nil ? Photo(json: photo!) : nil
        }
        self.snippet = snippet
    }
}

extension Restaurant {
    init?(json : [String: Any]) {
        guard let id = json["id"] as? String,
              let name = json["name"] as? String,
              let street = json["street"] as? String,
              let city = json["city"] as? String,
              let state = json["state"] as? String,
              let zip = json["zip"] as? String,
              let country = json["country"] as? String,
              let photo = json["profilePhoto"] as? [String : Any],
              let dishes = json["dishes"] as? [Any],
              let latitude = json["latitude"] as? Double,
              let longitude = json["longitude"] as? Double else {
                return nil
        }

        self.id = id
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        self.profilePhoto = Photo(json: photo)
        self.dishes = dishes.flatMap {
            let dish = $0 as? [String : Any]
            return dish != nil ? Dish(json: dish!) : nil
        }
    }
}

extension Reservation {

    static func create(fromURL jsonFileURL: URL) -> Reservation? {
        guard let jsonData = try? Data(contentsOf: jsonFileURL),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as! [String: Any] else {
            return nil
        }
        return Reservation(json: json)
    }
    
    init?(json: [String: Any]) {
        let formatter = ISO8601DateFormatter()
        guard let restaurantDict = json["restaurant"] as? [String : Any],
              let restaurant = Restaurant(json: restaurantDict),
              let utcDateString = json["utcDateTime"] as? String,
              let localDateString = json["dateTime"] as? String,
              let utcDate = formatter.date(from: utcDateString ),
              let localDate = formatter.date(from: localDateString),
              let partySize = json["partySize"] as? Int else {
                return nil
        }
        self.restaurant = restaurant
        self.utcDate = utcDate
        self.localDate = localDate
        self.partySize = partySize
        self.confirmationMessage = json["confirmationMessage"] as? String
    }
}

