//
//  ViewController.swift
//  vision-app
//
//  Created by Jennifer Vilanda Hasler on 8/14/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import CoreML
import Vision
import DocumentsOCR
import TesseractOCR


var textInEdit = String()
var selectedLanguage = "eng"
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, G8TesseractDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let imagePickerController:UIImagePickerController = UIImagePickerController()
    @IBOutlet weak var vwCameraContainer: UIView!
    @IBOutlet weak var vwCamera: UIView!
    @IBOutlet weak var vwVisibleArea: UIView!
    @IBOutlet weak var vwSnapshot: UIView!
    
    @IBOutlet weak var vwDetection: UIView!
    
    @IBOutlet weak var txfDetection: UITextView!

    
    @IBOutlet var visuals: UIVisualEffectView!
    @IBOutlet weak var btnPlay: UIButton!
    

    
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
        let _tesseract = G8Tesseract(language: "eng")
        _tesseract?.delegate = self
        //_tesseract?.charWhitelist
        //_tesseract?.charBlacklist
        return _tesseract!
    }()
    
    internal var currentDetectedText: String? {
        didSet {
            //self.lblTitle.isHidden = true
            self.txfDetection.text = self.currentDetectedText
            textInEdit = currentDetectedText!
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
    


    
    //internal var recognitionState = RecognitionTypes.init(rawValue: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //import editItem
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTouched))
        navigationItem.rightBarButtonItem = editItem

        vwVisibleArea.backgroundColor = UIColor.clear
        vwSnapshot.backgroundColor = UIColor.clear
        vwCamera.backgroundColor = UIColor.clear

        cameraInit()
        
        prepareLiveVideo()
        play()
        startTextDetection()
        vwVisibleArea.tintColor = UIColor.white
    }
 
    @objc private func editTouched(){ 
        print("edit")

       // performSegue(withIdentifier: "EditSegue", sender: self)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editVC")
        let nav = UINavigationController(rootViewController: vc!)
        self.present(nav, animated: true, completion: self.pause)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.previewLayer?.frame = self.vwCamera.bounds //on load, fix bounds
    }
    
    @IBAction func onPlay(_ sender: UIButton) {
        if sender.isSelected {
            self.pause()
           
        }else {
            self.play()

        }
    }
    
    internal func play() {
        self.startSession()
        self.btnPlay.isSelected = true
        btnPlay.setImage(UIImage(named: "pause"), for: .normal)
        btnPlay.backgroundColor = UIColor(red:0.73, green:0.40, blue:0.83, alpha:1.0)
        vwVisibleArea.tintColor = UIColor.clear
        Camera_image_View.image = UIImage.from(color: UIColor.clear)
    }
    
    internal func pause() {
        self.stopSession()
        self.btnPlay.isSelected = false
        btnPlay.setImage(UIImage(named: "play"), for: .normal)
        btnPlay.backgroundColor = UIColor(red:0.21, green:0.15, blue:0.69, alpha:1.0)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        self.present(imagePickerController, animated: true) { () -> Void in}
        pause()
        txfDetection.text = ""
    }
    
    @IBOutlet var finalImage: UIImageView!
    @IBOutlet var Camera_image_View: UIImageView!
  
    let textDetector = Text_Detector.init(isDisplayBackground: true)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.Camera_image_View.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: textDetection)
      
    }
    func cameraInit(){
        imagePickerController.delegate = self
        imagePickerController.modalTransitionStyle = .flipHorizontal
        imagePickerController.modalPresentationStyle = .overFullScreen
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.cameraCaptureMode = .photo
    }
    func textDetection(){
        if(self.Camera_image_View.image != nil){
            
           Camera_image_View.image = textDetector.textDetect(dectect_image: Camera_image_View.image!, display_image_view: Camera_image_View)
            txfDetection.text = textInEdit
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class Text_Detector: vision_mod, G8TesseractDelegate {
    
    var havBackground:Bool = true;
    init(isDisplayBackground:Bool) {
        havBackground = isDisplayBackground
    }


    lazy internal var tesseract: G8Tesseract = {
        let _tesseract = G8Tesseract(language: "eng")
        _tesseract?.delegate = self
        //_tesseract?.charWhitelist
        //_tesseract?.charBlacklist
        return _tesseract!
    }()

    func textDetect(dectect_image:UIImage, display_image_view:UIImageView)->UIImage{
        let handler:VNImageRequestHandler = VNImageRequestHandler.init(cgImage: (dectect_image.cgImage)!)
        var result_img:UIImage = UIImage.init();
        
        let request:VNDetectTextRectanglesRequest = VNDetectTextRectanglesRequest.init(completionHandler: { (request, error) in
            if( (error) != nil){
                print("Got Error In Run Text Dectect Request");
                
            }else{
                
                result_img = self.mixImage(top_image: self.drawRectangleForTextDectect(image: display_image_view.image!,results: request.results as! Array<VNTextObservation>), bottom_image: dectect_image)
                
                self.tesseract.image = result_img
                self.tesseract.recognize()
                print("text is \(self.tesseract.recognizedText)")
                print(self.tesseract.recognizedText)
                textInEdit = self.tesseract.recognizedText
            }
        })
        request.reportCharacterBoxes = true
        do {
            try handler.perform([request])
            return result_img;
        } catch {
            return result_img;
        }
    }
    
    func drawRectangleForTextDectect(image: UIImage, results:Array<VNTextObservation>) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        var t:CGAffineTransform = CGAffineTransform.identity;
        t = t.scaledBy( x: image.size.width, y: -image.size.height);
        t = t.translatedBy(x: 0, y: -1 );
        
        let img = renderer.image { ctx in
            for item in results {
                let TextObservation:VNTextObservation = item
                ctx.cgContext.setFillColor(UIColor.clear.cgColor)
                ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
                ctx.cgContext.setLineWidth(3)
                ctx.cgContext.addRect(item.boundingBox.applying(t))
                ctx.cgContext.drawPath(using: .fillStroke)

//                for item_2 in TextObservation.characterBoxes!{
//                    let RectangleObservation:VNRectangleObservation = item_2
//                    ctx.cgContext.setFillColor(UIColor.clear.cgColor)
//                    ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
//                    ctx.cgContext.setLineWidth(2)
//                    ctx.cgContext.addRect(RectangleObservation.boundingBox.applying(t))
//                    ctx.cgContext.drawPath(using: .fillStroke)
//                }
            }
            
        }
        return img
    }
}

class vision_mod: NSObject {
    
    override init() {
        
    }
    
    func mixImage(top_image:UIImage, bottom_image:UIImage, top_image_point:CGPoint=CGPoint.init(x: 0, y: 0), isHaveBackground:Bool = true)-> UIImage{
        let bottomImage = bottom_image//self.Camera_Image_View.image
        //bottomImage = UIImage.from(color: .red)

        let newSize = bottom_image.size // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        
        if(isHaveBackground==true){
            bottomImage.draw(in: CGRect(origin: CGPoint.init(x: 0, y: 0), size: newSize))
        }
        top_image.draw(in: CGRect(origin: CGPoint.init(x: 0, y: 0), size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage!
    }
    
}
extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
