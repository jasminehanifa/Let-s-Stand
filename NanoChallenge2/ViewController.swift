//
//  ViewController.swift
//  NanoChallenge2
//
//  Created by Jasmine Hanifa Mounir on 18/09/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import HealthKit
import LocalAuthentication
import UserNotifications

//enum CategoryValueAppleStandHour : NSInteger{
//    case stood = 0
//    case idle = 1
//}

class ViewController: UIViewController {
    @IBOutlet weak var standHourLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var CircularProgress: CircularProgressView!
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var coin: UILabel!
    @IBOutlet weak var currentHour: UILabel!
    @IBOutlet weak var currentGoal: UILabel!
    
    
    let healthStore = HKHealthStore()
    var context = LAContext()
    let shapeLayer = CAShapeLayer()
    var standHours: Float = 0
    var standGoal: Float = 0
    
    var totalCoin = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        faceIDAuthentication()
        requestPermission()
        
        customButton()
        notif()
//        notifContent()
        print(totalCoin)
        let coin1 = String(totalCoin)
        self.coin.text = coin1
//
//        var goal2 = Int(currentGoal.text!)
//        let goal1 = UserDefaults.standard.integer(forKey: "goal")
//        goal2 = Int(goal1)
//
        
    }

    override func viewWillAppear(_ animated: Bool) {
        getStandHourData()
        circularStandHourProgress()
    }
    func requestPermission(){
        if HKHealthStore.isHealthDataAvailable(){
            let objectTypes: Set<HKObjectType> = [HKObjectType.activitySummaryType(), HKObjectType.categoryType(forIdentifier: .appleStandHour)!
            ]
            
            healthStore.requestAuthorization(toShare: objectTypes as? Set<HKSampleType>, read: objectTypes) { (success, error) in
                if !success {
                    print("You are not allwoded to the helath data")
                }else{
                    print("You allwoded to the helath data")
                }
            }
        }
    }
    
    func getStandHourData(){
//        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
//            fatalError("*** This should never fail. ***")
//        }
//        let endDate = NSDate()
//        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate as Date, options: []) else {
//            fatalError("*** unable to calculate the start date ***")
//        }
//        let units: NSCalendar.Unit = [.day, .month, .year, .era]
//
//        var startDateComponents = calendar.components(units, from: startDate)
//        startDateComponents.calendar = calendar as Calendar
//        var endDateComponents = calendar.components(units, from: endDate as Date)
//        endDateComponents.calendar = calendar as Calendar
//        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        dateComponents.calendar = calendar
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)

        let sampleQuery = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            guard let summaries = summaries, summaries.count > 0 else{
                print("no summaries")
                return
            }
            DispatchQueue.main.async {
                for summary in summaries{
                    let standUnit = HKUnit.count()
                    self.standHours = Float(summary.appleStandHours.doubleValue(for: standUnit))
//                    self.standGoal = summary.appleStandHoursGoal.doubleValue(for: standUnit)
                    guard let time = summary.dateComponents(for: calendar as Calendar).date else{return}
                    let standHourInt: Int = Int(self.standHours)
                    self.standHourLabel.text = "\(standHourInt)"
                    self.currentHour.text = "\(standHourInt)"
                    print("\(time) -  Stand hours : \(self.standHours)")
                    if self.standHours < 12.00{
                        self.CircularProgress.setProgressWithAnimation(duration: 2.0, value: self.standHours/12.0)
                        self.label.text = "You haven't reach your goal"
                        self.notifContent()
                    } else if self.standHours >= 12.00{
                        self.label.text = "Yaey!! You already reach your goal"
                        self.standButton.isHidden = true
                        self.CircularProgress.setProgressWithAnimation(duration: 2.0, value: 1.0)
                    }
                }
            }
        }
        healthStore.execute(sampleQuery)
    }
    
    
    func notif(){
        let types = [
            HKObjectType.categoryType(forIdentifier: .appleStandHour)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { (query, completionHandler, error) in
                
                // Handle new data here
                
            }
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (complete, error) in
                
            }
        }
    } 
    
    func notifContent(){
        let content = UNMutableNotificationContent()
        content.title = "Let's Stand and Walk"
        content.body = "You haven't reach your goal for today"
        content.sound = UNNotificationSound.default
        
        let timeInterval = 60.0 * 60.0
        let date = Date().addingTimeInterval(timeInterval)
        
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: "notifID", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func faceIDAuthentication(){
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Identify yorself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success{
                        self?.getStandHourData()
                    }else{
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Try Again", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        }else{
            let ac = UIAlertController(title: "Face ID unavailable", message: "Your device is not configured for biometric authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try Again", style: .default))
            present(ac, animated: true)
        }
    }
   
    
    func circularStandHourProgress(){
        CircularProgress.trackColor = #colorLiteral(red: 0.4479289055, green: 0.8122398257, blue: 0.9100942612, alpha: 0.1496949914)
        CircularProgress.progressColor = #colorLiteral(red: 0.4479289055, green: 0.8122398257, blue: 0.9100942612, alpha: 1)
    }
   
    func customButton(){
        standButton.layer.cornerRadius = 7
    }
    
    @IBAction func standButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "nextVC", sender: self)
    }
    
}

