//
//  ViewController.swift
//  HelloArrow2
//
//  Created by Dan Carter on 2014-10-24.
//  Copyright (c) 2014 Dan Carter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setupNotifications()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        let view = GLView(frame: UIScreen.mainScreen().bounds)
        self.view = view
        return
    }
    
    func setupNotifications() {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            notification in
            let view = self.view as GLView
            view.updateForNewOrientation(UIDevice.currentDevice().orientation, animated: true)
        }
    }
}

