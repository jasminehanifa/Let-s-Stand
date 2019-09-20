//
//  OnboardingViewController.swift
//  NanoChallenge2
//
//  Created by Jasmine Hanifa Mounir on 20/09/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var continueOutlet: UIButton!
    
    @IBOutlet weak var goalTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        UserDefaults.standard.set(Int(goalTF.text!), forKey: "goal")
        performSegue(withIdentifier: "toMainVC", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
