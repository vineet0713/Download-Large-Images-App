//
//  ViewController.swift
//  Download Large Images
//
//  Created by Vineet Joshi on 2/8/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

// Given by instructor:
enum BigImages: String {
    case whale = "https://lh3.googleusercontent.com/16zRJrj3ae3G4kCDO9CeTHj_dyhCvQsUDU0VF0nZqHPGueg9A9ykdXTc6ds0TkgoE1eaNW-SLKlVrwDDZPE=s0#w=4800&h=3567"
    case shark = "https://lh3.googleusercontent.com/BCoVLCGTcWErtKbD9Nx7vNKlQ0R3RDsBpOa8iA70mGW2XcC76jKS09pDX_Rad6rjyXQCxngEYi3Sy3uJgd99=s0#w=4713&h=3846"
    case seaLion = "https://lh3.googleusercontent.com/ibcT9pm_NEdh9jDiKnq0NGuV2yrl5UkVxu-7LbhMjnzhD84mC6hfaNlb-Ht0phXKH4TtLxi12zheyNEezA=s0#w=4626&h=3701"
}

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var largeImage: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: IBActions (from Buttons and Slider)
    
    // synchronous download (downloads a large image while blocking the main queue and UI - NOT RECOMMENDED!)
    @IBAction func sync(_ sender: Any) {
        /*
         Get the URL for image
         Obtain the Data with the image
         Convert into a UIImage
         Display it
        */
        
        guard let url = URL(string: BigImages.whale.rawValue) else {
            print("The URL could not be created!")
            return
        }
        
        // this statement is the one that blocks the main queue:
        guard let data = try? Data(contentsOf: url) else {
            print("The URL's data could not be created!")
            return
        }
        
        let image = UIImage(data: data)
        largeImage.image = image
    }
    
    // simple asynchronous download (avoids blocking by creating a new queue that runs in background, without blocking UI)
    @IBAction func async(_ sender: Any) {
        guard let url = URL(string: BigImages.shark.rawValue) else {
            print("The URL could not be created!")
            return
        }
        
        // create a queue from scratch
        let downloadQueue = DispatchQueue(label: "download")
        
        // call async to send a closure to the downloads queue
        downloadQueue.async {
            guard let data = try? Data(contentsOf: url) else {
                print("The URL could not be created!")
                return
            }
            let image = UIImage(data: data)
            
            DispatchQueue.main.sync(execute: {
                // this must be run in the main queue, because it operates on a UIImageView!
                self.largeImage.image = image
            })
        }
    }
    
    // asynchronous download (downloads image in a global queue and uses completion handler - RECOMMENDED!)
    @IBAction func asyncWithCompletionClosure(_ sender: Any) {
        withLargeImage { (image) in
            self.largeImage.image = image
        }
    }
    
    // function with completion handler:
    func withLargeImage(completionHandler handler: @escaping (_ image: UIImage) -> Void) {
        // qos parameter specifies priority (userInitiated is one of higher priorities)
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: BigImages.seaLion.rawValue) else {
                print("The URL could not be created!")
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                print("The URL's data could not be created!")
                return
            }
            let image = UIImage(data: data)
            
            // make sure that all completion handlers run in the main queue!
            DispatchQueue.main.async(execute: { 
                if let image = image {
                    // calls the completion handler:
                    handler(image)
                }
            })
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            largeImage.alpha = CGFloat(slider.value)
        }
    }
}

