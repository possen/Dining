//
//  ImageView+Extension.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/25/17.
//

import UIKit

// simple in memory cache that will purge oldest if it grows larger than cacheSize
// threadsafe updates to cache structure and does purging in the utilty QOS.
// probably better to purge based upon how big the latest request is, and
// purge as many items as it takes to open up the cache to allocate it.


class ImageCache {
    let cacheQueue = DispatchQueue(label: "cache", qos: .utility)
    private var cache : [String: (timeCount: Int, size: Int, image: UIImage)] = [:]
    private var timeCount = 0
    let cacheSize = 10_000_000
    
    static var shared = ImageCache()
    
    fileprivate func purgeCache() {
        cacheQueue.async {
            let size = self.cache.reduce(0) { $0 + $1.value.size }
            if size > self.cacheSize {
                let sortedLRU = self.cache.keys.sorted(by: { (key1, key2) -> Bool in
                    let val1 = self.cache[key1]?.timeCount ?? self.timeCount
                    let val2 = self.cache[key2]?.timeCount ?? self.timeCount
                    return val1 > val2
                })
                if let oldest = sortedLRU.first {
                    NSLog("removing \(oldest)")
                    self.cache[oldest] = nil
                }
            }
        }
    }
    
    fileprivate func readCache(url : URL) -> UIImage? {
        // must wait for access, if any lower priority tasks
        // block this, those queues will be promoted by GCD to prevent deadlock.
        var image : UIImage? = nil
        cacheQueue.sync {
            image = cache[url.absoluteString]?.image
        }
        return image
    }
    
    fileprivate func writeCache(url : URL, size: Int, image: UIImage) {
        // update as soon as possible.
        cacheQueue.async {
            self.timeCount += 1
            self.cache[url.absoluteString] = (timeCount: self.timeCount, size:size, image: image)
            self.purgeCache()
        }
    }
}

extension UIImageView {
    
    func loadImageAtURL(_ urlOrig : URL) {
        UIImageView.loadImageAtURLCache(urlOrig) { (image, url) in
            if urlOrig == url {
                self.image = image
            }
        }
    }
    
    private class func loadImageAtURLCache(_ url : URL, completion: @escaping (UIImage, URL) -> Void ) {
        if let cacheHit = ImageCache.shared.readCache(url: url) {
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
                            ImageCache.shared.writeCache(url: url, size:data.count, image:createImage!)
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

