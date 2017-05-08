//
//  Reservation.swift
//  Dining
//
//

import Foundation
import CoreLocation
import UIKit
import CoreGraphics
import Argo
import Curry
import Runes

class DateFormatters {
    static let instance = DateFormatters()
    let isoFormatter: DateFormatter
    let isoNoTimezoneFormatter: DateFormatter
    
    init() {
        // Allocating formatter is expensive, allocate once.
        do {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
            self.isoFormatter = formatter
        }
        
        do {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            self.isoNoTimezoneFormatter = formatter
        }
    }
}


// MARK: - PhotoSize -

struct PhotoSize {
	 public let width: Int
	 public let height: Int
	 public let uri: String
	
	public init(uri: String, width: Int?, height: Int?) {
		self.uri = uri
		self.height = height ?? Int.max
		self.width = width ?? Int.max
	}
}

extension PhotoSize: Decodable {
    static func decode(_ json: JSON) -> Decoded<PhotoSize> {
        return curry(PhotoSize.init)
            <^> json <|  "uri"
            <*> json <|? "width"
            <*> json <|? "height"
    }
}

// MARK: - Photo -

struct Photo {
	
    public let photoSizes: [PhotoSize]
    public var photoId: String?
    public var name: String?
		
    init(photoSizes: [PhotoSize], photoId: String?, name: String?) {
        self.photoSizes = photoSizes
        self.photoId = photoId
        self.name = name
    }
    
	public func urlForSize(desiredSize: CGSize) -> String {
		let scale = 1.0 / UIScreen.main.scale
		let desiredWidth = scale * desiredSize.width
		for size in self.photoSizes {
			if CGFloat(size.width) >= desiredWidth {
				return size.uri
			}
		}
		
		return self.photoSizes[self.photoSizes.count - 1].uri
	}
}

extension Photo: Decodable {
    static func decode(_ json: JSON) -> Decoded<Photo> {
        return curry(Photo.init)
            <^> json <|| "references"
            <*> json <|? "id"
            <*> json <|? "name"
    }
}

// MARK: - Snippet -

struct Snippet {
	public let content: String
	public let range: NSRange
	public let highlights: [NSRange]
    
    init(content: String, range: NSRange, highlights: [NSRange]) {
        self.content = content
        self.range = range
        self.highlights = highlights
    }
}

extension Snippet: Decodable {
    static func decode(_ json: JSON) -> Decoded<Snippet> {
        let r = curry(Snippet.init)
            <^> json <|  "content"
            <*> json <|  "range"
            <*> json <|| "highlights"
        return r
    }
}

extension NSRange: Decodable {
    init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }
    
    public static func decode(_ json: JSON) -> Decoded<NSRange> {
        return curry(NSRange.init)
            <^> json <|  "location"
            <*> json <|  "length"
    }
}

// MARK: - Dish -

struct Dish {
	public let id: String
	public let name: String
	
	public let photos: [Photo]
	public let snippet: Snippet
    
    init(id: String, name: String, photos: [Photo], snippet: Snippet) {
        self.id = id
        self.name = name
        self.photos = photos
        self.snippet = snippet
    }
}

extension Dish: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Dish> {
        let r = curry(Dish.init)
            <^> json <|  "id"
            <*> json <|  "name"
            <*> json <|| "photos"
            <*> json <|  "snippet"
        return r
    }
}

// MARK: - Restaurant -

struct Restaurant {
	public let id: String
	public let name: String
	
	public let street: String
	public let city: String
	public let state: String
	public let zip: String
	public let country: String
	
	public let location: CLLocation
	
	public let profilePhoto: Photo?
	public let dishes: [Dish]
    
    init(id: String,
         name: String,
         street: String,
         city: String,
         state: String,
         zip: String,
         country: String,
         latitude: Double,
         longitude: Double,
         profilePhoto: Photo?,
         dishes: [Dish]) {
        self.id = id
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.profilePhoto = profilePhoto
        self.dishes = dishes
    }
}

extension Restaurant: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Restaurant> {
       let r = curry(Restaurant.init)
            <^> json <|  "id"
            <*> json <|  "name"
            <*> json <|  "street"
            <*> json <|  "city"
            <*> json <|  "state"
            <*> json <|  "zip"
            <*> json <|  "country"
            <*> json <|  "latitude"
            <*> json <|  "longitude"
            <*> json <|? "profilePhoto"
            <*> json <|| "dishes"

        return r
    }
}

// MARK: - Reservation -

struct Reservation {
    
    public let restaurant: Restaurant
    
    public let utcDate: Date
    public let localDate: Date
    
    public let partySize: Int
    
    public let confirmationMessage: String?
    
    public init(restaurant: Restaurant, utcDate: String, localDate: String, partySize: Int, confirmationMessage: String?) {
        self.restaurant = restaurant
        self.utcDate = DateFormatters.instance.isoFormatter.date(from: utcDate)!
        self.localDate = DateFormatters.instance.isoNoTimezoneFormatter.date(from: localDate)!
        self.partySize = partySize
        self.confirmationMessage = confirmationMessage
    }
}

extension Reservation: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Reservation> {
        return curry(Reservation.init)
            <^> json <|  "restaurant"
            <*> json <|  "utcDateTime"
            <*> json <|  "dateTime"
            <*> json <|  "partySize"
            <*> json <|? "confirmationMessage"
    }
}

