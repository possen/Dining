//
//  DiningTableViewController.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/26/17.
//

import UIKit

class ReservationTableViewController: UITableViewController {

    @IBOutlet weak var grabArea: UIView!
    
    private var reservationDataManager = ReservationDataManager.shared
    private var reservationDataManagerTableViewAdaptor : TableViewAdaptor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(
            target: self,
            action:#selector(tapAction))
        grabArea.addGestureRecognizer(tap)
        
        let reservationIndex = 0 // currently we only support one reservation.
        let reservation = reservationDataManager.reservations[reservationIndex]

        // create label area
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: grabArea.frame.width / 2, y: grabArea.frame.height / 2)
        label.textAlignment = .center
        label.text = reservation.restaurant.name
        label.textColor = UIColor.black
        grabArea.addSubview(label)

        reservationDataManager.fetchReservations()
        
        // register 3 different cell types for each section.
        var reservationAdaptor = TableViewAdaptorSection<ReservationTableViewCell, Reservation> (
            cellReuseIdentifier: "ReservationCell",
            title: "",
            height: 200,
            items: [reservation])
        { cell, model in
            cell.viewData = ReservationTableViewCell.ViewData(reservation: model)
        }
        
        var mapAdaptor = TableViewAdaptorSection<MapTableViewCell, Restaurant> (
            cellReuseIdentifier: "MapCell",
            title: "Map",
            height: 200,
            items: [reservation.restaurant])
        { cell, model in
            cell.viewData = MapTableViewCell.ViewData(restaurant: model)
        }
        
        var dishAdaptor = TableViewAdaptorSection<DishTableViewCell, Dish> (
            cellReuseIdentifier: "DishCell",
            title: "Popular Dishes",
            height: 100,
            items: reservation.restaurant.dishes)
        { cell, model in
            cell.viewData = DishTableViewCell.ViewData(dish: model)
        }
        
        let sections : [TableSectionAdaptor] = [reservationAdaptor, mapAdaptor, dishAdaptor]
        
        reservationDataManagerTableViewAdaptor = TableViewAdaptor(
            tableView: tableView,
            sections: sections,
            didChangeHandler: {
                let reservationIndex = 0 // currently we only support one reservation.
                let reservation = self.reservationDataManager.reservations[reservationIndex]
                reservationAdaptor.items = [reservation]
                mapAdaptor.items = [reservation.restaurant]
                dishAdaptor.items = reservation.restaurant.dishes
                print("dish count \(dishAdaptor.items.count)")
                self.tableView.reloadData()
            }
        )

        reservationDataManager.delegate = reservationDataManagerTableViewAdaptor
    }
    
    @IBAction fileprivate func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapAction(sender : UITapGestureRecognizer) {
        dismissPressed(sender)
    }

    @IBAction func refreshData(_ sender: UIRefreshControl) {
        ReservationDataManager.count += 1
        ReservationDataManager.count %= ReservationDataManager.testfileNames.count

        reservationDataManager.fetchReservations()
        sender.endRefreshing()
    }
}



