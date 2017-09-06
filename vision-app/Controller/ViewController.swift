//
//  ViewController.swift
//  vision-app
//
//  Created by Jennifer Vilanda Hasler on 8/14/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import UIKit
import AVKit
import CoreML
import Vision
import DocumentsOCR
import TesseractOCR


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, G8TesseractDelegate {
    
    
    @IBOutlet weak var vwCameraContainer: UIView!
    @IBOutlet weak var vwCamera: UIView!
    @IBOutlet weak var vwVisibleArea: UIView!
    @IBOutlet weak var vwSnapshot: UIView!
    
    @IBOutlet weak var vwDetection: UIView!
    
    @IBOutlet weak var txfDetection: UITextView!

    
    @IBOutlet var visuals: UIVisualEffectView!
    @IBOutlet weak var btnPlay: UIButton!
    //@IBOutlet weak var pckRecognition: UIPickerView!
    
    internal var fontFamilies: [String] = {
        var arr: [String] = []
        for family in UIFont.familyNames.sorted() {
            for font in UIFont.fontNames(forFamilyName: family) {
                arr.append(font)
            }
        }
        return arr
    }()
    
    internal var previewLayer: AVCaptureVideoPreviewLayer?
    
    internal var currentFont: UIFont? {
        didSet {
            self.txfDetection.font = self.currentFont
           // self.lblTitle.font = self.currentFont
        }
    }
    
    //uiPickerView Language
    

    
    
    internal var currentIndexPath: IndexPath?
    internal var currentImage: UIImage?
    internal var currentSentenceFrames: [CGRect] = []
    internal var currentLetterFrames: [CGRect] = []
    internal var shouldAnalyzeImage = true
    
    internal var session = AVCaptureSession()
    internal var requests = [VNRequest]()
    lazy internal var tesseract: G8Tesseract = {
        let _tesseract = G8Tesseract(language: selectedLanguage)
        _tesseract?.delegate = self
        //_tesseract?.charWhitelist
        //_tesseract?.charBlacklist
        return _tesseract!
    }()
    
    internal var currentDetectedText: String? {
        didSet {
            //self.lblTitle.isHidden = true
            self.txfDetection.text = self.currentDetectedText
        }
    }
    
    internal enum RecognitionTypes: Int {
        case grayscale = 0
        case blackwhite = 1
        //case normal = 2
        
        static func titles() -> [String] {
            return ["gray", "b/w"] //, "original"]
        }
    }
    var test = 1
    let languageArray = ["English", "German", "French", "Danish"]
    var selectedLanguage = "eng"
    //internal var recognitionState = RecognitionTypes.init(rawValue: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
     
        print(test)
        //import language item
        let languageItem = UIBarButtonItem(title: "Language", style: .plain, target: self, action: #selector(laguageTouched))
        navigationItem.leftBarButtonItem = languageItem
        //import editItem
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTouched))
       navigationItem.rightBarButtonItem = editItem
        
        
        if selectedLanguage == "English"{
            selectedLanguage = "eng"
        }else if selectedLanguage == "French"{
            selectedLanguage = "fra"
        }
        else if selectedLanguage == "German"{
            selectedLanguage = "deu"
        }
        else if selectedLanguage == "Danish"{
            selectedLanguage = "dan"
        }
        print(selectedLanguage)
        
        print("tess language is \(tesseract.language)")
        
        txfDetection.text = "hello"

        vwVisibleArea.backgroundColor = UIColor.clear
        vwSnapshot.backgroundColor = UIColor.clear
        vwCamera.backgroundColor = UIColor.clear

        prepareLiveVideo()
        play()
        startTextDetection()
    }
    
    
    @objc private func laguageTouched(){
        print("language")
       // self.pause()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "languageVC")
        self.present(vc!, animated: true, completion: self.pause)
    }
    @objc private func editTouched(){
        print("edit")
        // self.pause()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editVC")
        self.present(vc!, animated: true, completion: self.pause)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.previewLayer?.frame = self.vwCamera.bounds //on load, fix bounds
    }
    
    @IBAction func onPlay(_ sender: UIButton) {
        if sender.isSelected {
            self.pause()
        }
        else {
            self.play()
        }
    }
    
    internal func play() {
        self.startSession()
        self.btnPlay.isSelected = true
    }
    
    internal func pause() {
        self.stopSession()
        self.btnPlay.isSelected = false
    }
    
    @IBAction func onLanguage(_ sender: Any) {
        if (sender as AnyObject).isSelected{
        self.pause()
        print("language")
        }
        print("language2")
    }
    
    @IBAction func onEdit(_ sender: Any) {
        pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UIPicker
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return "1"
//    }
    
}


