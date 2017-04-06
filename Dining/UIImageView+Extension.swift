//
//  ImageView+Extension.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/25/17.
//

import UIKit

// simple cache that will purge oldest if it grows larger than cacheSize
// threadsafe updates to cache structure and does purging in the utilty QOS.
// probably better to purge based upon how big the latest request is, and
// purge as many items as it takes to open up the cache to allocate it.

private var cache : [String: (timeCount: Int, size: Int, image: UIImage)] = [:]
private var timeCount = 0
let cacheSize = 300_000

extension UIImageView {
    
    func loadImageAtURL(_ urlOrig : URL) {
        UIImageView.loadImageAtURLCache(urlOrig) { (image, url) in
            if urlOrig == url {
                self.image = image
            }
        }
    }
    
    class func purgeCache() {
        DispatchQueue.global(qos: .utility).async {
            let size = cache.reduce(0) { $0 + $1.value.size }
            if size > cacheSize {
                let sortedLRU = cache.keys.sorted(by: { (key1, key2) -> Bool in
                    let val1 = cache[key1]?.timeCount
                    let val2 = cache[key2]?.timeCount
                    return val1! > val2!
                })
                if let oldest = sortedLRU.first {
                    NSLog("removing \(oldest)")
                    cache[oldest] = nil
                }
            }
        }
    }
  
    class func readCache(url : URL) -> UIImage? {
        // must wait for access, if any lower priority tasks
        // block this, those queues will be promoted by GCD to prevent deadlock.
        var image : UIImage? = nil
        DispatchQueue.global(qos: .userInitiated).sync {
            image = cache[url.absoluteString]?.image
        }
        return image
    }
    
    class func writeCache(url : URL, size: Int, image: UIImage) {
        // update as soon as possible.
        DispatchQueue.global(qos: .userInitiated).async {
            timeCount += 1
            cache[url.absoluteString] = (timeCount: timeCount, size:size, image: image)
            purgeCache()
        }
    }
    
    class func loadImageAtURLCache(_ url : URL, completion: @escaping (UIImage, URL) -> Void ) {
        if let cacheHit = readCache(url: url) {
            completion(cacheHit, url)
        } else {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { data, response, error in
                if let data = data {
                    DispatchQueue.global(qos: .userInitiated).async { () -> Void in
                        let createImage = UIImage(data: data) // decode off main thread
                        DispatchQueue.main.async { () -> Void in
                            completion(createImage!, url)
                            writeCache(url: url, size:data.count, image:createImage!)
                        }
                    }
                } else {
                    print("image failed to load \(url)")
                }
            }
            task.resume()
        }
    }
}
