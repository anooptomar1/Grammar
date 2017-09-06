//
//  LanguageViewController.swift
//  vision-app
//
//  Created by Jennifer Vilanda Hasler on 9/6/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import Foundation
import UIKit

class LanguageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
   
    let languageArray = ["English", "German", "French", "Danish"]
    var languageChoice = "English"
    var selectedLanguage = "English"
    var test = 1

    @IBOutlet var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        print(test)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "languageSegue"{
            let viewController = segue.destination as! ViewController
            viewController.selectedLanguage = languageChoice
        }
    }
    
    func createLanguagePicker(){
        let languagePicker = UIPickerView()
        languagePicker.delegate = self
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageChoice = languageArray[row]
    }
    

    
}
