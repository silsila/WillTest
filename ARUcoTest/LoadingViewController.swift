//
//  LoadingViewController.swift
//  WilliamPen
//
//  Created by silsila uthup on 16/08/18.
//  Copyright © 2018 carmatec. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextpage(_ sender: Any)
    {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let home = story.instantiateViewController(withIdentifier: "Home1ViewController") as! Home1ViewController
        self.present(home, animated: true, completion: nil)
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

