//
//  ViewController.swift
//  Translate widget
//
//  Created by Yingcai Dong on 2016-12-24.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var languateInputLabel: UITextField!
    @IBOutlet weak var OutputTextView: UITextView!
    
    var translationHistory = ""
    var lastText = ""
    var outputResult = ""
    var translation = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // enable clear all button at the right of text field
        languateInputLabel.clearButtonMode = .always
        languateInputLabel.adjustsFontSizeToFitWidth = true
        languateInputLabel.minimumFontSize = 10.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: edit action
    @IBAction func editingBegin(_ sender: Any) {
        // when start edit show keyboard
        languateInputLabel.becomeFirstResponder()
    }

    // MARK: translate button action
    @IBAction func startTranslate(_ sender: UIButton) {
        translateButton.isEnabled = false
        languateInputLabel.resignFirstResponder()
        
        lastText = languateInputLabel.text!
        
        //translations.append(lastText)
        performTranslation()
    }
    
    func performTranslation() {
        let langSource = "en"
        let langTarget = "zh-CN"
        
        if lastText != "" {
            let textEscaped = lastText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            let url = URL(string: "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(langSource)&tl=\(langTarget)&dt=t&q=\(textEscaped!)")
            
            let task = URLSession.shared.dataTask(with: url!) {
                data, response, error in
                guard let data = data, error == nil
                    else {
                        // handle error
                        DispatchQueue.main.async {
                            self.translateButton.isEnabled = true
                            self.OutputTextView.text = "Error: \(error?.localizedDescription)"
                        }
                        return
                }
                
                DispatchQueue.main.async {
                    // receive raw data
                    self.outputResult = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
                    
                    // extract translation result from array
                    self.outputResult = self.outputResult.components(separatedBy: "\"")[1]
                    //self.translationHistory = "\(self.lastText)\n\(self.outputResult)\n" + self.translationHistory
                    
                    self.translation.insert(self.outputResult, at: 0)
                    if self.translation.count > 10 {
                        self.translation.removeLast()
                    }
                    
                    self.translateButton.isEnabled = true
                    
                    self.OutputTextView.text = self.translation.joined(separator: "\n")
                }
            }
            task.resume()
        } else {
            translateButton.isEnabled = true
            OutputTextView.text = "Plaease Input Something\nDon't left blank"
            return
        }
        
    }
    
    func showHistoryTrans() {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        translateButton.isEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // when the input text field is empty, button is disabled
        let oldString: NSString = textField.text! as NSString
        let newString: NSString = oldString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 0 {
            translateButton.isEnabled = true
        }
        return true
    }

    // MARK: auto invoke when user cleaning the content
    deinit {
        // code here
    }
    
}

