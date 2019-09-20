//
//  SecondViewController.swift
//  NanoChallenge2
//
//  Created by Jasmine Hanifa Mounir on 19/09/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet var subView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var totalCoinOutlet: UILabel!
    
    var seconds = 10
    var countDown = Timer()
    var effect: UIVisualEffect!
    var totalCoin = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.cornerRadius = 5
        
        visualEffectView.isHidden = true
        effect = visualEffectView.effect
        visualEffectView.effect = nil
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        countDown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SecondViewController.counter), userInfo: nil, repeats: true)
        startButton.isHidden = true
    }
    
    @objc func counter(){
        seconds -= 1
        timeLabel.text = String(seconds)
        if seconds == 0{
            countDown.invalidate()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            animateIn()
        }
    }
    
    func animateIn(){
        self.view.addSubview(subView)
        subView.center = self.view.center
        
        subView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.isHidden = false
            self.visualEffectView.effect = self.effect
            self.subView.alpha = 1
            self.subView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.subView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.subView.alpha = 0
//            self.visualEffectView.effect = nil
        }) { (success:Bool) in
            self.performSegue(withIdentifier: "prevVC", sender: self)
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        animateOut()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        totalCoin += 10

        vc.totalCoin = totalCoin
    }
}
