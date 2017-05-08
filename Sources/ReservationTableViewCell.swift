//
//  ReservationTableViewCell.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/26/17.
//

import UIKit

class ReservationTableViewCell: UITableViewCell {

    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var titleView : UILabel!

    var title : String = ""
    var cellReuseIdentifier: String = ""
    var items: [Any] = []
    var height : CGFloat {
        return 280.0
    }
    var configure: (_ cell: Any, _ model: Any) -> Void = {cell, model in }

    required init(cellReuseIdentifier: String,
                           title: String,
                           configure: @escaping (_ cell: Any,_ model: Any) -> Void,
                           items:[Any]) {
        self.title = title
        self.cellReuseIdentifier = cellReuseIdentifier
        self.items = items
        self.configure = configure
        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // quick hack to get a roundish display.
        profileView.layer.cornerRadius = profileView.frame.size.height / 2
        profileView.layer.masksToBounds = true
        profileView.layer.borderWidth = 3
        super.awakeFromNib()
    }
    
    struct ViewData {
        let title: String
        let url: URL?
    }
    
    var viewData: ViewData? {
        didSet {
            titleView.text = viewData?.title
            if let url = viewData?.url, url.absoluteString != "" {
                self.profileView.loadImageAtURL(url)
            } else {
                self.profileView.image = UIImage(named: "Placeholder")
            }
        }
    }
    
    func configure(model: Any) {
        let reservation = model as! Reservation
        viewData = ViewData(reservation: reservation)
    }
}

extension ReservationTableViewCell.ViewData {
    init(reservation: Reservation) {
        self.title = reservation.restaurant.name
        let profilePhoto = reservation.restaurant.profilePhoto
        let urlStr = profilePhoto?.urlForSize(desiredSize: CGSize(width: 500, height: 500))
        let url =  URL(string: urlStr ?? "")
        self.url = url
    }
}
