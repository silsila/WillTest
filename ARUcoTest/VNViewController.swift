//
//  VNViewController.swift
//  ARUcoTest
//
//  Created by Dorin Danilov on 25/07/2018.
//  Copyright © 2018 HHCC. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import SceneKit
var imgcount = Int()



@available(iOS 11.0, *)
@objc public class VNViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var CameraImageView: UIImageView!
    //@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sceneView: SCNView!
    @objc var foobar = Int()
    var cameraNode: SCNNode!
    private var boxNode: SCNNode!
    
    @IBOutlet weak var previewView: UIView!
    
    //new method for auto capture
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraImage: UIImage?
    let output = AVCaptureVideoDataOutput()
    
    let stillImageOutput = AVCaptureStillImageOutput()
    var img123 = UIImage()
    
    //border detection method
    let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
    let imageProcessingQueue = DispatchQueue.global(qos: .userInitiated)
    
    let ciContext = CIContext()
    
    lazy var rectDetector: CIDetector = {
        return CIDetector(ofType: CIDetectorTypeRectangle,
                          context: self.ciContext,
                          options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])!
    }()
    var flashLayer: CALayer?
    let kCIPerspectiveCorrection = "CIPerspectiveCorrection"
    let kCIAffineTransform = "CIAffineTransform"
    lazy var boxLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = 2
        layer.cornerRadius = 8
        layer.isOpaque = false
        layer.opacity = 0
        layer.frame = self.view.bounds
        self.view.layer.addSublayer(layer)
        return layer
    }()
    
    var detectRectangles = true
    var wantsPhoto = false
    var barCodeFrameView: UIView?
    
    
    //test
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0/255
    var green: CGFloat = 0.0/255
    var blue: CGFloat = 0.0/255
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    //end of test
    
    override public func viewDidLoad() {
        super.viewDidLoad()
       // setupCamera()
        startCamera()
        initSceneKit()
    }
    func setupCamera() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: AVMediaType.video,
                                                                position: .back)
        device = discoverySession.devices[0]
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device!)
        } catch {
            return
        }
        
       
        output.alwaysDiscardsLateVideoFrames = true
        if #available(iOS 11.0, *) {
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        } else {
            // Fallback on earlier versions
        }
        let queue = DispatchQueue(label: "cameraQueue")
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        captureSession?.addOutput(output)
        captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        previewLayer?.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        
        view.layer.insertSublayer(previewLayer!, at: 0)
        
        captureSession?.startRunning()
    }
    
    func initSceneKit() {
        // create a new scene
        
        let scene = SCNScene()
        
        // create and add a camera to the scene
        cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zFar = 1000
        camera.zNear = 0.1
        cameraNode.camera = camera
        
        scene.rootNode.addChildNode(cameraNode)
        
        //retrieve the SCNView
        let scnView = sceneView!
        
        // set the scene to the view
        scnView.scene = scene
        
        scnView.autoenablesDefaultLighting = true
        
        // configure the view
        scnView.backgroundColor = UIColor.clear
        
        let box = SCNBox(width: 10, height: 10 , length: 10, chamferRadius: 0)
        boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0,0,0)
        
        
        scene.rootNode.addChildNode(boxNode)
        
        sceneView.pointOfView = cameraNode
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if previewLayer != nil {
            previewLayer?.frame = previewView.bounds
        }
    }
//
    private func startCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { status in
            if status {
                DispatchQueue.main.async(execute: {
                    self.initCamera()
                })
            } else {

            }
        }
    }
    
    func initCamera() {
        let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.back)
        let deviceInput = try! AVCaptureDeviceInput(device: device!)
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSession.Preset.iFrame960x540
        self.captureSession?.addInput(deviceInput)
        let sessionOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()

        let outputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
        sessionOutput.setSampleBufferDelegate(self, queue: outputQueue)
        self.captureSession?.addOutput(sessionOutput)
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.previewLayer?.backgroundColor = UIColor.black.cgColor
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.previewView.layer.addSublayer(self.previewLayer!)

        self.captureSession!.startRunning()
        view.setNeedsLayout()
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        guard let transQR = OpenCVWrapper.arucoTransformMatrix(from: pixelBuffer) else {
            
            DispatchQueue.main.async(execute: {
                self.boxNode.isHidden = true
            })
            
            return
        }
        if (captureSession?.canAddOutput(stillImageOutput))!
        {
            stillImageOutput.isHighResolutionStillImageOutputEnabled = true
            captureSession?.automaticallyConfiguresCaptureDeviceForWideColor = true
            captureSession?.addOutput(stillImageOutput)
        }
        DispatchQueue.main.async(execute: {
            print("marker id is:\(transQR.markerID)")
            print("marker projectionMatrix is:\(transQR.projectionMatrix)")
            print("rotationVector id is:\(transQR.rotationVector)")
            print("translationVector id is:\(transQR.translationVector)")
            print("transform id is:\(transQR.transform)")
            print("testnumber id is:\(transQR.testnumber)")
            print("testarray id is:\(transQR.testarray)")
            self.previewView.backgroundColor = UIColor(patternImage: transQR.image)
            self.cameraImage = transQR.image
            self.CameraImageView.image = self.cameraImage
            if transQR.testnumber == 4
            {
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                let image = CIImage(cvImageBuffer: imageBuffer)
                for feature in self.rectDetector.features(in: image, options: nil) {
                    guard let rectFeature = feature as? CIRectangleFeature else { continue }
                    let imageWidth = image.extent.height
                    let imageHeight = image.extent.width
                    let imageScale = min(self.view.frame.size.width / imageWidth,
                                         self.view.frame.size.height / imageHeight)
                    let bl = CGPoint(x: rectFeature.topLeft.y * imageScale,
                                     y: rectFeature.topLeft.x * imageScale)
                    let tl = CGPoint(x: rectFeature.topRight.y * imageScale,
                                     y: rectFeature.topRight.x * imageScale)
                    let tr = CGPoint(x: rectFeature.bottomRight.y * imageScale,
                                     y: rectFeature.bottomRight.x * imageScale)
                    let br = CGPoint(x: rectFeature.bottomLeft.y * imageScale,
                                     y: rectFeature.bottomLeft.x * imageScale)
                
                    //self.displayQuad(points: (tl: tl, tr: tr, br: br, bl: bl) )
                    let bll = transQR.testarray[2] as! CGPoint
                    let tll = transQR.testarray[0] as! CGPoint
                    let trr = transQR.testarray[1] as! CGPoint
                    let brr = transQR.testarray[3] as! CGPoint
//                    self.displayQuad(points: (tl: tll, tr: trr, br: brr, bl: bll))
                    
//                    let bll = CGPoint(x: CGFloat(transQR.transform.m41), y: CGFloat(transQR.transform.m43))
//                    let tll = CGPoint(x: CGFloat(transQR.transform.m14), y: CGFloat(transQR.transform.m12))
//                    let trr = CGPoint(x: CGFloat(transQR.transform.m21), y: CGFloat(transQR.transform.m23))
//                    let brr = CGPoint(x: CGFloat(transQR.transform.m34), y: CGFloat(transQR.transform.m32))
                   
                    self.displayQuad(points: (tl: tll, tr: trr, br: brr, bl: bll))
                    self.view.bringSubview(toFront: self.CameraImageView)
//                  if let processedImage = self.perspectiveCorrect(image,  points: (tl: tll, tr: trr, br: brr, bl: bll))
                    if let processedImage = self.perspectiveCorrect(image,  cgrectfeature:rectFeature)
                    {
                        DispatchQueue.main.async
                        {
                                self.displayImage(ciImage: processedImage)
                        }
                    }
                }
            }
            
        })
    }
    
    //test method
    func drawLine(from: CGPoint, to: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        
        CameraImageView.image?.draw(in: view.bounds)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: from)
        context?.addLine(to: to)
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        context?.strokePath()
        
        CameraImageView.image = UIGraphicsGetImageFromCurrentImageContext()
     //   CameraImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
//end of test method
    //border method
    private func flashScreen() {
        let flash = CALayer()
        flash.frame = view.bounds
        flash.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(flash)
        flash.opacity = 0
        
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.1
        anim.autoreverses = true
        anim.isRemovedOnCompletion = true
        anim.delegate = self as! CAAnimationDelegate
        flash.add(anim, forKey: "flashAnimation")
        
        self.flashLayer = flash
    }
    // MARK: - Rotation
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    private func displayRect(rect: CGRect) {
        /*
         -------------
         ---(layer)---
         ---(preview)-
         ---(rect)----
         ^
         */
        // hideBoxTimer?.invalidate()
        boxLayer.frame = rect
        boxLayer.opacity = 1
        
        //
        //        hideBoxTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
        //            self.boxLayer.opacity = 0
        //            timer.invalidate()
        //        })
    }
    
    private func displayQuad(points: (tl: CGPoint, tr: CGPoint, br: CGPoint, bl: CGPoint)) {
        let path = UIBezierPath()
        path.move(to: points.tl)
        path.addLine(to: points.tr)
        path.addLine(to: points.br)
        path.addLine(to: points.bl)
        path.addLine(to: points.tl)
        path.close()
        let cgPath = path.cgPath.copy(strokingWithWidth: 4, lineCap: .round, lineJoin: .round,
                                      miterLimit: 0)
        boxLayer.path = cgPath
        boxLayer.opacity = 1
    }
    
    private func perspectiveCorrect(_ image: CIImage, cgrectfeature:CIRectangleFeature) -> CIImage? {
        
        let perspectiveFilter = CIFilter(name: kCIPerspectiveCorrection)!
        perspectiveFilter.setValue(image, forKey: kCIInputImageKey)
        
        let corners = [
            (cgrectfeature.topLeft, "inputTopLeft"),
            (cgrectfeature.topRight, "inputTopRight"),
            (cgrectfeature.bottomRight, "inputBottomRight"),
            (cgrectfeature.bottomLeft, "inputBottomLeft"),
            ]
        
        for (point, key) in corners {
            let vector = CIVector(cgPoint: point)
            perspectiveFilter.setValue(vector, forKey: key)
        }
        
        guard let correctedImage = perspectiveFilter.outputImage else { return nil }
        let extent = correctedImage.extent
        
        let transformFilter = CIFilter(name: kCIAffineTransform)!
        /*----*
         |    |
         *----*/
        
        var transform = CGAffineTransform(translationX: extent.midX, y: -extent.midY)
        transform = transform.rotated(by: -.pi/2)
        transform = transform.translatedBy(x: -extent.midX, y: extent.midY)
        transformFilter.setValue(correctedImage, forKey: kCIInputImageKey)
        transformFilter.setValue(transform, forKey: kCIInputTransformKey)
        
        return transformFilter.outputImage
    }
    
    private func displayImage(ciImage: CIImage) {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            fatalError()
        }
        let image1 = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)

        //        let test = [CGRect(x: 20, y: 5, width: 20, height: 20),CGRect(x: 150, y: 5, width: 20, height: 20),CGRect(x: 20, y: 375, width: 20, height: 20),CGRect(x: 150, y: 375, width: 20, height: 20)]
        //        for i in test
        //        {
        //            image1 = self.drawRectangleOnImage(image: image1,rect: i)
        //            img123 = image1
        //        }
        img123 = image1
        
        self.capture1()
    }
    func capture1()
    {
        boxLayer.opacity = 0
        detectRectangles = false
        // flash
        flashScreen()
        // save photo
        wantsPhoto = true
        self.captureSession?.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let home = story.instantiateViewController(withIdentifier: "Home1ViewController") as!Home1ViewController //self.img123
        home.img34 = self.img123 //self.getScannedImage(inputImage: self.img123)!
        home.test = "true"
        self.present(home, animated: true, completion: nil)
    }
//    func getScannedImage(inputImage: UIImage) -> UIImage? {
//
//        let openGLContext = EAGLContext(api: .openGLES3 )
//        let context = CIContext(eaglContext: openGLContext!)
//
//        let filter = CIFilter(name: "CIColorControls")
//        let coreImage = CIImage(image: inputImage) //
//        filter?.setValue(coreImage, forKey: kCIInputImageKey)
//        filter?.setValue(1.0, forKey: kCIInputSaturationKey) //5
//     //   filter?.setValue(1.0, forKey: kCIInputSaturationKey) //1
//      //  filter?.setValue(1.2, forKey: kCIInputBrightnessKey)//1.2
//
//        if let outputImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
//            let output = context.createCGImage(outputImage, from: outputImage.extent)
//            return UIImage(cgImage: output!)
//        }
//        return nil
//    }

    func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
    func snapshot()
    {
        print("SNAPSHOT")
        self.captureSession?.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
       // self.img123 = self.fixOrientationOfImage(image: image)!
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let home = story.instantiateViewController(withIdentifier: "Home1ViewController") as! Home1ViewController
        home.img34 = self.CameraImageView.image!
        home.test = "true"
        self.present(home, animated: true, completion: nil)
        
//       // captureSession?.stopRunning()
//        CameraImageView.image = cameraImage
//       // CameraImageView.image = blurImage(image: cameraImage, forRect: <#T##CGRect#>)
    }
    func blurImage(image:UIImage, forRect rect: CGRect) -> UIImage?
    {
        let context = CIContext(options: nil)
        var inputImage = CIImage(image: image)
      //  let inputImage = CIImage(CGImage: image.CGImage!)


        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue((70.0), forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage

        var cgImage:CGImage?

        if let asd = outputImage
        {
            cgImage = context.createCGImage(asd, from: rect)
        }

        if let cgImageA = cgImage
        {
            return UIImage(cgImage: cgImageA)
        }

        return nil
    }
    func setCameraMatrix(_ transformModel:  TransformModel) {
        
        print(transformModel.transform.description)
        
        cameraNode.rotation = transformModel.rotationVector
        cameraNode.position = transformModel.translationVector
        print("position: \(cameraNode.position.x) \(cameraNode.position.y) \(cameraNode.position.z)")
    }
    
}
extension SCNMatrix4 {
    var description: String {
        get {
            return "\(m11) \(m12) \(m13) \(m14) \n" +
                    "\(m21) \(m22) \(m23) \(m24) \n" +
                    "\(m31) \(m32) \(m33) \(m34) \n" +
                    "\(m41) \(m42) \(m43) \(m44) \n"
        }
    }
}
extension VNViewController : CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        flashLayer?.removeFromSuperlayer()
        flashLayer = nil
    }
}

