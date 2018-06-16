//
//  DishTableViewCell.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/26/17.
//

import UIKit

class DishTableViewCell: UITableViewCell {
    @IBOutlet weak var photo : UIImageView!
    
    @IBOutlet weak var dishName: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    var title : String = ""
    var cellReuseIdentifier: String = ""
    var items: [Any] = []
    var configure: (_ cell:Any, _ model: Any) -> Void = {cell, model in }

    var height : CGFloat {
        return 75.0
    }

    internal required init(cellReuseIdentifier: String,
                  title: String,
                  configure: @escaping (_ cell: Any, _ model: Any) -> Void,
                  items:[Any]) {
        self.title = title
        self.cellReuseIdentifier = cellReuseIdentifier
        self.items = Array(items[0..<min(items.count, 3)]) // only show first 3
        self.configure = configure

        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)
   
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct ViewData {
        let dishName: String
        let description: String
        let url: URL
        let highlights: [NSRange]
    }
    
    var viewData: ViewData? {
        didSet {
            if let url = viewData?.url, let photo = self.photo {
                photo.loadImageAtURL(url)
            } else {
                self.photo.image = UIImage(named: "Placeholder")
            }
            
            let desc = viewData?.description ?? "No description"
            dishName.text = viewData?.dishName ?? "No dish name"
            
            if let highlights = viewData?.highlights {
                let attrText = NSMutableAttributedString(string: desc)
                for highlight in highlights {
                    attrText.addAttribute(convertToNSAttributedStringKey(convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)),
                                          value: UIColor.blue,
                                          range: highlight)
                }
                self.detail.attributedText = attrText
            } else {
                self.detail.text = desc
            }
        }
    }
}

extension DishTableViewCell.ViewData {
    init(dish: Dish) {
        let dishPhoto = dish.photos[0]
        let urlStr = dishPhoto.urlForSize(desiredSize: CGSize(width: 500, height: 500))
        let url =  URL(string: urlStr)
        self.url = url ?? URL(string: "")!
        self.description = dish.snippet.content
        self.highlights = dish.snippet.highlights
        self.dishName = dish.name
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKey(_ input: String) -> NSAttributedString.Key {
	return NSAttributedString.Key(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
