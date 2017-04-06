//
//  DiningTests.swift
//  DiningTests
//
//

import XCTest
@testable import DiningApp

class DiningTests: XCTestCase {
    
    func testFullReservation() {
		let url = Bundle.main.url(forResource: "FullReservation", withExtension:"json")
		let data = try! Data(contentsOf:url!, options: Data.ReadingOptions.uncached)
		let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
		
		guard let reservation = ReservationAssembler().createReservation(json) else {
			XCTFail("reservation was not built")
			return
		}
		
		XCTAssertNotNil(reservation.restaurant.profilePhoto)
		XCTAssertTrue(reservation.restaurant.dishes.count == 3)
		
		let firstDish = reservation.restaurant.dishes[0]
		XCTAssertNotEqual(firstDish.photos.count, 0)
		XCTAssertNotEqual(firstDish.snippet.highlights.count, 0)
    }
	
	func testTwoDishes() {
		let url = Bundle.main.url(forResource: "2dishes", withExtension:"json")
		let data = try! Data(contentsOf:url!, options: Data.ReadingOptions.uncached)
		let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
		
		guard let reservation = ReservationAssembler().createReservation(json) else {
			XCTFail("reservation was not built")
			return
		}
		
		XCTAssertNotNil(reservation.restaurant.profilePhoto)
		XCTAssertEqual(reservation.restaurant.dishes.count, 2)
		
		let firstDish = reservation.restaurant.dishes[0]
		XCTAssertNotEqual(firstDish.photos.count, 0)
		XCTAssertNotEqual(firstDish.snippet.highlights.count, 0)
	}
	
	func testPartialReservation() {
		let url = Bundle.main.url(forResource: "PartialReservation", withExtension:"json")
		let data = try! Data(contentsOf:url!, options: Data.ReadingOptions.uncached)
		let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
		
		guard let reservation = ReservationAssembler().createReservation(json) else {
			XCTFail("reservation was not built")
			return
		}
		
		XCTAssertNotNil(reservation.restaurant.profilePhoto)
		XCTAssertEqual(reservation.restaurant.dishes.count, 0)
	}

	
}
