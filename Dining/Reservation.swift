//
//  Reservation.swift
//  Dining
//
//

import Foundation
import CoreLocation
import UIKit
import CoreGraphics

struct PhotoSize {
	public let width: Int
	public let height: Int
	public let uri: String
	
	public init?(uri: String, width: Int?, height: Int?) {
		guard uri.count > 0 else {
			return nil
		}
		
		self.uri = uri
		self.height = height ?? Int.max
		self.width = width ?? Int.max
	}
}

struct Photo {
	
	public let photoSizes: [PhotoSize]
	public var photoId: String?
	public var name: String?
	
	public init?(id: String?, name: String?, sizes: [PhotoSize]) {
		guard sizes.count > 0 else {
			return nil
		}
		self.photoId = id
		self.name = name
		self.photoSizes = sizes
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

struct Snippet {
	let content: String
	let range: NSRange
	let highlights: [NSRange]
}

struct Dish {
	let id: String
	let name: String
	
	let photos: [Photo]
	let snippet: Snippet
}

struct Restaurant {
	let id: String
	let name: String
	
	let street: String
	let city: String
	let state: String
	let zip: String
	let country: String
	
	let location: CLLocation
	
	let profilePhoto: Photo?
	let dishes: [Dish]
}

struct Reservation {
	
	let restaurant: Restaurant
	
	let utcDate: Date
	let localDate: Date
	
	let partySize: Int
	
	let confirmationMessage: String?
}
