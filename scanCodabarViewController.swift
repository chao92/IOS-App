//
//  scanCodabarViewController.swift
//  Integrity_APP
//
//  Created by chao on 2/2/16.
//  Copyright © 2016 Shuang Wang. All rights reserved.
//

import UIKit
import Alamofire

class scanCodabarViewController: UIViewController, ZXCaptureDelegate,UITextFieldDelegate {
    
    var capture = ZXCapture()
    var captureSizeTransform = CGAffineTransform()
    
    
    var userFirstName: String = ""
    var userLastName: String = ""
    var userPicLink: String = ""
    
    @IBOutlet weak var scanRectView: UIView!
    @IBOutlet weak var decodedLabel: UILabel!
    
    @IBOutlet weak var studentID: UITextField!
    
    @IBOutlet weak var finish: UIButton!
    
    @IBAction func requestDetialInf(sender: AnyObject) {
        Alamofire.request(.POST, "\(urlGlobalBase)jsonGetUserInfByBarcode.php", parameters: ["barCode" : self.studentID.text!] as [String:AnyObject])
            .validate()
            .responseJSON {
                response in
                if(response.result.isSuccess) {
                    var dic = response.result.value as! [String: AnyObject]
                    var res = dic["success"] as! Int
                    if(res==1) {
                        print("Get user Info success!")
                        self.userFirstName = pv(dic["firstName"] as? String)
                        self.userLastName = pv(dic["lastName"] as? String)
                        self.userPicLink = pv(dic["piclink"] as? String)
                        let destViewController:UIViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("barCodeResultViewController") as UIViewController
                        (destViewController as! barCodeResultViewController).userFirstName = self.userFirstName
                        (destViewController as! barCodeResultViewController).userLastName = self.userLastName
                        (destViewController as! barCodeResultViewController).userPicLink = self.userPicLink
                        (destViewController as! barCodeResultViewController).userBarCodeValue = self.studentID.text!
                        self.navigationController?.pushViewController(destViewController, animated: true)
                        
                        
                    }
                    else {
                        var alert:UIAlertView = UIAlertView()
                        alert.title = "User Info retrive failed"
                        alert.message = "Cannot retrive user information"
                        //alert.delegate = self
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }
                }
                else {
                    var alert:UIAlertView = UIAlertView()
                    alert.title = "Cannot Connection to Service"
                    alert.message = "Server side error, please try again"
                    //alert.delegate = self
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
        }
        
        
    }
    
    //TextField Delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("loading from objC")
        
        // scanViewController().viewDidLoad()
        // self.registerForPreviewingWithDelegate(scanViewController, sourceView:)
        // self.presentingViewController = objC
        //objC.window.rootViewController
        /*
        autoreleasepool {
        UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(AppScanDelegate))
        }*/
        //self.scanView = AppDelegate().window
        // Do any additional setup after loading the view.
        self.capture.camera = self.capture.back()
        self.capture.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
        self.view.layer.addSublayer(self.capture.layer)
        self.view.bringSubviewToFront(self.scanRectView)
        //self.view.bringSubviewToFront(self.decodedLabel)
        self.view.bringSubviewToFront(self.studentID)
        self.view.bringSubviewToFront(self.finish)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        self.capture.delegate = self
        self.applyOrientation()
    }
    
    func applyOrientation(){
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        var scanRectRotation: float_t
        var captureRotation: float_t
        switch (orientation) {
        case UIInterfaceOrientation.Portrait:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
        case UIInterfaceOrientation.LandscapeLeft:
            captureRotation = 90;
            scanRectRotation = 180;
            break;
        case UIInterfaceOrientation.LandscapeRight:
            captureRotation = 270;
            scanRectRotation = 0;
            break;
        case UIInterfaceOrientation.PortraitUpsideDown:
            captureRotation = 180;
            scanRectRotation = 270;
            break;
        default:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
        }
        self.applyRectOfInterest(orientation)
        let transform = CGAffineTransformMakeRotation((CGFloat)(captureRotation / 180 * Float(M_PI)))
        self.capture.transform = transform
        self.capture.rotation = CGFloat(scanRectRotation)
        self.capture.layer.frame = self.view.frame
        
    }
    
    func applyRectOfInterest(orientation: UIInterfaceOrientation){
        var scaleVideo: CGFloat, scaleVideoX: CGFloat, scaleVideoY: CGFloat
        var videoSizeX: CGFloat, videoSizeY: CGFloat
        var transformedVideoRect = self.scanRectView.frame
        if(self.capture.sessionPreset == AVCaptureSessionPreset1920x1080){
            videoSizeX = 1080;
            videoSizeY = 1920;
        } else {
            videoSizeX = 720;
            videoSizeY = 1280;
        }
        if(UIInterfaceOrientationIsPortrait(orientation)){
            scaleVideoX = self.view.frame.size.width / videoSizeX;
            scaleVideoY = self.view.frame.size.height / videoSizeY;
            scaleVideo = max(scaleVideoX, scaleVideoY);
            if(scaleVideoX > scaleVideoY) {
                transformedVideoRect.origin.y += (scaleVideo * videoSizeY - self.view.frame.size.height) / 2;
            } else {
                transformedVideoRect.origin.x += (scaleVideo * videoSizeX - self.view.frame.size.width) / 2;
            }
        } else {
            scaleVideoX = self.view.frame.size.width / videoSizeY;
            scaleVideoY = self.view.frame.size.height / videoSizeX;
            scaleVideo = max(scaleVideoX, scaleVideoY);
            if(scaleVideoX > scaleVideoY) {
                transformedVideoRect.origin.y += (scaleVideo * videoSizeX - self.view.frame.size.height) / 2;
            } else {
                transformedVideoRect.origin.x += (scaleVideo * videoSizeY - self.view.frame.size.width) / 2;
            }
        }
        self.captureSizeTransform = CGAffineTransformMakeScale(1/scaleVideo, 1/scaleVideo)
        self.capture.scanRect = CGRectApplyAffineTransform(transformedVideoRect, self.captureSizeTransform)
        
        
    }
    
    func barcodeFormatToString(format:ZXBarcodeFormat) -> NSString{
        switch (format) {
        case kBarcodeFormatAztec:
            return "Aztec";
            
        case kBarcodeFormatCodabar:
            return "CODABAR";
            
        case kBarcodeFormatCode39:
            return "Code 39";
            
        case kBarcodeFormatCode93:
            return "Code 93";
            
        case kBarcodeFormatCode128:
            return "Code 128";
            
        case kBarcodeFormatDataMatrix:
            return "Data Matrix";
            
        case kBarcodeFormatEan8:
            return "EAN-8";
            
        case kBarcodeFormatEan13:
            return "EAN-13";
            
        case kBarcodeFormatITF:
            return "ITF";
            
        case kBarcodeFormatPDF417:
            return "PDF417";
            
        case kBarcodeFormatQRCode:
            return "QR Code";
            
        case kBarcodeFormatRSS14:
            return "RSS 14";
            
        case kBarcodeFormatRSSExpanded:
            return "RSS Expanded";
            
        case kBarcodeFormatUPCA:
            return "UPCA";
            
        case kBarcodeFormatUPCE:
            return "UPCE";
            
        case kBarcodeFormatUPCEANExtension:
            return "UPC/EAN extension";
            
        default:
            return "Unknown";
        }
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    //MARK: ZXCaptureDelegate Methods
    
    func captureResult(capture: ZXCapture!, result: ZXResult!){
        if(result==nil){
            return
        }
        let inverse = CGAffineTransformInvert(self.captureSizeTransform)
        let point: NSMutableArray = []
        var location: NSString = ""
        for (var i=0; i<result.resultPoints.count; i++){
            let resultpoint: ZXResultPoint = result.resultPoints[i] as! ZXResultPoint
            let cgPoint = CGPointMake(CGFloat(resultpoint.x), CGFloat(resultpoint.y))
            var transformedPoint = CGPointApplyAffineTransform(cgPoint, inverse)
            transformedPoint = self.scanRectView.convertPoint(transformedPoint, toView: self.scanRectView.window)
            let windowsPointValue: NSValue = NSValue(CGPoint: CGPointMake(transformedPoint.x,transformedPoint.y))
            location = "at\(transformedPoint.x),\(transformedPoint.y)"
            point.addObject(windowsPointValue)
            
        }
        //let formatingString = self.barcodeFormatToString(result.barcodeFormat)
        //let display = "Scanned! Format:\(formatingString)\nContents: \(result.text)\nLocation: \(location)"
        let display = result.text
        dispatch_async(dispatch_get_main_queue(), {self.studentID.text = display})
        /*
        self.decodedLabel.performSelectorOnMainThread(Selector.init(stringLiteral: display), withObject: display, waitUntilDone: true)
        */
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        self.capture.stop()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(2) * NSEC_PER_SEC)), dispatch_get_main_queue(), {self.capture.start()})
    }
    
}
