//
//  CustomSplitViewController.swift
//  Borders
//
//  Created by Juan Gabriel Gomila Salas on 8/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

class CustomSplitViewController: UISplitViewController {
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge{
            return [.top]
        }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
