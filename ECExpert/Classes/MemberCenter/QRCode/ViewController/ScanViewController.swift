//
//  ScanViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/25.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

enum ScanType: Int{
    case All = 0
    case QRCode, BarCode
}


typealias ScanCompleteFunc  = (scanViewControlelr: ScanViewController, scanResult: String) -> Void

class ScanViewController: BasicViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private var device: AVCaptureDevice!
    private var input: AVCaptureDeviceInput!
    private var output: AVCaptureMetadataOutput!
    private var session: AVCaptureSession!
    private var preview: AVCaptureVideoPreviewLayer!
    
    private let height: CGFloat = KM_FRAME_SCREEN_WIDTH - 100
    private let width: CGFloat = KM_FRAME_SCREEN_WIDTH - 100
    
    private var timer: NSTimer!
    
    var scanType: ScanType
    let scanCompleteFunc: ScanCompleteFunc?
    
    deinit{
        KMLog("ScanViewController deinit")
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    
    init(scanType: ScanType, scanCompleteFunc: ScanCompleteFunc?){
        self.scanType = scanType
        self.scanCompleteFunc = scanCompleteFunc
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(scanType: ScanType.All, scanCompleteFunc: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = UIView(frame: KM_FRAME_SCREEN_BOUNDS)
        
        setUpView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "scan_light"), style: UIBarButtonItemStyle.Plain, target: self, action: "light")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func light(){
        if device != nil && device.hasTorch{
            device.lockForConfiguration(nil)
            if device.torchMode == AVCaptureTorchMode.Off{
                device.torchMode = AVCaptureTorchMode.On
            }else{
                device.torchMode = AVCaptureTorchMode.Off
            }
        }
    }
    
    func setUpView(){
        // 1. 摄像头设备
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // 2.设置输入
        var error: NSError?
        input = AVCaptureDeviceInput(device: device, error: &error)
        if error != nil{
            self.progressHUD?.mode = MBProgressHUDMode.Text
            self.progressHUD?.detailsLabelText = error?.localizedDescription
            self.progressHUD?.minShowTime = 2
            self.progressHUD?.showAnimated(true, whileExecutingBlock: { () -> Void in
                
            }, completionBlock: { [unowned self]() -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            return
        }
        
        // 3. 设置输出
        output = AVCaptureMetadataOutput()
        let visible = getVisibleFrame()
        let x: CGFloat = (visible.size.width - width) / 2.0
        let y: CGFloat = (visible.size.height - height) / 2.0 + visible.origin.y
        let scanRect = CGRectMake(y / KM_FRAME_SCREEN_HEIGHT, x / KM_FRAME_SCREEN_WIDTH, height / KM_FRAME_SCREEN_HEIGHT, width / KM_FRAME_SCREEN_WIDTH)
        output.rectOfInterest = scanRect
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        
        // 4. 拍摄会话
        session = AVCaptureSession()
        if session.canAddInput(input){
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        
        // 4.1 设置输出的格式
        // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
        //    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        switch scanType{
        case .All:
            output.metadataObjectTypes = [AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode]
        case .QRCode:
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        case .BarCode:
            output.metadataObjectTypes = [AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code]
        }
        
        // 5. 设置预览图层（用来让用户能够看到扫描情况）
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = self.view.bounds
        self.view.layer.insertSublayer(preview, atIndex: 0)
        
        // 6. 设置遮掩层
        let alphaColor = RGBA(0, 0, 0, 0.5)
        let topView = UIView(frame: CGRectMake(0, 0, KM_FRAME_SCREEN_WIDTH, y))
        topView.backgroundColor = alphaColor
        
        let bottomView = UIView(frame: CGRectMake(0, y + height , KM_FRAME_SCREEN_WIDTH, KM_FRAME_SCREEN_HEIGHT - y - height))
        bottomView.backgroundColor = alphaColor
        
        let leftView = UIView(frame: CGRectMake(0, y, x, height))
        leftView.backgroundColor = alphaColor
        
        let rightView = UIView(frame: CGRectMake(x + width, y, x, height))
        rightView.backgroundColor = alphaColor
        
        let centerView = UIView(frame: CGRectMake(x, y, width, height))
        centerView.backgroundColor = UIColor.clearColor()
        
        let borderImageView = UIImageView(frame: centerView.bounds)
        borderImageView.image = UIImage(named: "scan_border")
        borderImageView.contentMode = UIViewContentMode.ScaleToFill
        
        let moveLine = UIImageView(frame: CGRectMake(5, 5, width - 10, 5))
        moveLine.image = UIImage(named: "scan_line")
        moveLine.contentMode = UIViewContentMode.ScaleToFill
        
        centerView.addSubview(borderImageView)
        centerView.addSubview(moveLine)
        
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)
        self.view.addSubview(leftView)
        self.view.addSubview(rightView)
        self.view.addSubview(centerView)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "moveLine:", userInfo: moveLine, repeats: true)
        session.startRunning()
    }
    
    func moveLine(timer: NSTimer!){
        let moveView = timer.userInfo as! UIView
        let maxY: CGFloat = height - 10
        let minY: CGFloat = 5
        let currentY: CGFloat = moveView.frame.origin.y
        let increaseY: CGFloat = 5
        var nextY: CGFloat = currentY + increaseY
        
        if nextY > maxY{
            nextY = minY
            var frame = moveView.frame
            frame.origin.y = nextY
            moveView.frame = frame
        }else{
            UIView.beginAnimations("MoveLine", context: nil)
            var frame = moveView.frame
            frame.origin.y = nextY
            moveView.frame = frame
            UIView.commitAnimations()
        }
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        session.stopRunning()
        preview.removeFromSuperlayer()
        
        // 取消定时器
        timer.invalidate()
        timer = nil
        
        let result = metadataObjects.first as! AVMetadataMachineReadableCodeObject
        let scanResult = result.stringValue
        
        if scanCompleteFunc != nil{
            scanCompleteFunc!(scanViewControlelr: self, scanResult: scanResult)
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

}
