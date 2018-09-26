//
//  Home1ViewController.swift
//  WilliamPen
//
//  Created by silsila uthup on 16/08/18.
//  Copyright © 2018 carmatec. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import Vision
import ImageIO

/* GLOBAL VARIABLES */
var CIFilterNames = [
    "CIPhotoEffectChrome",
    "CIPhotoEffectFade",
    "CIPhotoEffectInstant",
    "CIPhotoEffectNoir",
    "CIPhotoEffectProcess",
    "CIPhotoEffectTonal",
    "CIPhotoEffectTransfer",
    "CISepiaTone"
]


class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 255 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5).cgColor
        let colorBottom = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
class GradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = .white { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
class Home1ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var testview: UIView!
    @IBOutlet weak var img_image: UIImageView!
    var img34 = UIImage()
    var testval = ""
    let colors = Colors()
    var test = ""
//    //opencv test -starting
//    private var rect: CIRectangleFeature = CIRectangleFeature()
//    private var cropedImage: UIImage!
//    private var finalImage: UIImage!
//    private var infoLabel: UILabel!
//    private var currentStep = 0
//    private var time: TimeInterval = 0
//    private var cropRect: CropRect!
//    private var useCI = true
    
    private var originalImage = UIImage()
    private let ciContext = CIContext(options: nil)
    var img19 = UIImage()
    var testimg1 = UIImage()
    //opencd test - ending
    
    //test
    let pixelThinner = 5
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Bar Code Scanner"
        if test == "true"
        {
//            let toonFilter = SmoothToonFilter()
//            let filteredImage = testImage.filterWithOperation(toonFilter)
            
//            let pngImage = UIImagePNGRepresentation(filteredImage)!
//            do {
//                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
//                let fileURL = URL(string:"test.png", relativeTo:documentsDir)!
//                try pngImage.write(to:fileURL, options:.atomic)
//            } catch {
//                print("Couldn't write to file with error: \(error)")
//            }
//
//            // Filtering image for display
//            picture = PictureInput(image:UIImage(named:"WID-small.jpg")!)
//            filter = SaturationAdjustment()
//            picture --> filter --> renderView
//            picture.processImage()
//   //     }
            //  self.img_image.image = getScannedImage(inputImage: self.img34) //filteredImage //
            let coreImage = CIImage(image: self.img34)
            let filter = CIFilter(name: "\(CIFilterNames[0])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            self.img_image.image = UIImage(cgImage: filteredImageRef!);

            self.img_image.image = getScannedImage(inputImage: UIImage(cgImage: filteredImageRef!))
//            let ciimage = CIImage(image: self.img34)
//            guard let cg1 = performRectangleDetection(image: ciimage!) elseZ
//            {
//                let alert = UIAlertController(title: "Image not found", message: "Please scan the image correctly", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//            img19 = convert(cmage: cg1)
//            let myImage = img19
//            var croppedImage = cropBottomImage(image: myImage)
//            testimg1 = croppedImage
//            croppedImage = getScannedImage(inputImage: testimg1)!
//            self.img_image.image = cropImage(croppedImage, toRect: CGRect(x:0, y:100, width:croppedImage.size.width, height:croppedImage.size.height/2), viewWidth: croppedImage.size.width, viewHeight: croppedImage.size.height/2) //croppedImage
  
        }
    }
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    func analizeImage(_ image: UIImage) {
        
        self.img_image.image = image
        
        findColors(image) { [weak self] imageColors in
            guard let sSelf = self else { return }
            var (primaryColor, secondaryColor, detailColor) = sSelf.findMainColors(imageColors)
            
            if primaryColor == nil { primaryColor = .black }
            if secondaryColor == nil { secondaryColor = .white }
            if detailColor == nil { detailColor = .white }
            
            sSelf.view.backgroundColor = primaryColor
        
         //   sSelf.primaryLabel.textColor = primaryColor
          //  sSelf.secondaryLabel.textColor = secondaryColor
          //  sSelf.detailLabel.textColor = detailColor
        }
    }
    
    func findColors(_ image: UIImage, completion: @escaping ([String: Int]) -> Void) {
        guard let pixelData = image.cgImage?.dataProvider?.data else { completion([:]); return }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var countedColors: [String: Int] = [:]
        
        let pixelsWide = Int(image.size.width * image.scale)
        let pixelsHigh = Int(image.size.height * image.scale)
        
        //  let widthRange = 0..<pixelsWide
        //  let heightRange = 0..<pixelsHigh
        
        let widthThinner = Int(pixelsWide / pixelThinner) + 1
        let heightThinner = Int(pixelsHigh / pixelThinner) + 1
        let widthRange = stride(from: 0, to: pixelsWide, by: widthThinner)
        let heightRange = stride(from: 0, to: pixelsHigh, by: heightThinner)
        
        for x in widthRange {
            for y in heightRange {
                let pixelInfo: Int = ((pixelsWide * y) + x) * 4
                let color = "\(data[pixelInfo]).\(data[pixelInfo + 1]).\(data[pixelInfo + 2])"
                if countedColors[color] == nil {
                    countedColors[color] = 0
                } else {
                    countedColors[color]! += 1
                }
            }
        }
        
        completion(countedColors)
    }
    
    func findMainColors(_ colors: [String: Int]) -> (UIColor?, UIColor?, UIColor?) {
        
        var primaryColor: UIColor?, secondaryColor: UIColor?, detailColor: UIColor?
        for (colorString, _) in colors.sorted(by: { $0.value > $1.value }) {
            let colorParts: [String] = colorString.components(separatedBy: ".")
            let color: UIColor = UIColor(red: CGFloat(Int(colorParts[0])!) / 255,
                                         green: CGFloat(Int(colorParts[1])!) / 255,
                                         blue: CGFloat(Int(colorParts[2])!) / 255,
                                         alpha: 1).color(withMinimumSaturation: 0.15)
            
            guard !color.isBlackOrWhite() else { continue }
            if primaryColor == nil {
                primaryColor = color
            } else if secondaryColor == nil {
                if primaryColor!.isDistinct(color) {
                    secondaryColor = color
                }
            } else if detailColor == nil {
                if secondaryColor!.isDistinct(color) && primaryColor!.isDistinct(color) {
                    detailColor = color
                    break
                }
            }
        }
        return (primaryColor, secondaryColor, detailColor)
    }
    func cropBottomImage(image: UIImage) -> UIImage {
        let rect = CGRect(x: 0, y: 150, width: image.size.width, height: image.size.height/2)
        return cropImage(image: image, toRect: rect)
    }
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    //MARK - Instance Methods
    func CreateBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
    
    
    //Convert Vision Frame to UIKit Frame
    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    func performRectangleDetection(image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])!
        // Get the detections
        let features = detector.features(in: image)
        for feature in features as! [CIRectangleFeature] {
           // resultImage = self.drawHighlightOverlayForPoints(image: image, topLeft: feature.topLeft, topRight: feature.topRight,bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
            resultImage =  cropBusinessCardForPoints(image: image, topLeft: feature.topLeft, topRight: feature.topRight, bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
        }

        
        return resultImage
        
    }
    func cropBusinessCardForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        
        var businessCard: CIImage
        businessCard = image.applyingFilter(
            "CIPerspectiveTransformWithExtent",
            parameters: [
                "inputExtent": CIVector(cgRect: image.extent),
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)])
        businessCard = image.cropped(to: businessCard.extent)
        
        return businessCard
    }
    
    
    func drawHighlightOverlayForPoints(image: UIKit.CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> UIKit.CIImage {
        
        var overlay = UIKit.CIImage(color: CIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 0.45))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         parameters: [
                                                    "inputExtent": CIVector(cgRect: image.extent),
                                                    "inputTopLeft": CIVector(cgPoint: topLeft),
                                                    "inputTopRight": CIVector(cgPoint: topRight),
                                                    "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                                    "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return overlay.composited(over: image)
    }
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func getScannedImage(inputImage: UIImage) -> UIImage? {
        
        let openGLContext = EAGLContext(api: .openGLES3 )
        let context = CIContext(eaglContext: openGLContext!)
        
        let filter = CIFilter(name: "CIColorControls")
        let coreImage = CIImage(image: inputImage) 
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        filter?.setValue(5, forKey: kCIInputContrastKey) //5
        filter?.setValue(1.0, forKey: kCIInputSaturationKey) //1
        filter?.setValue(1.2, forKey: kCIInputBrightnessKey)//1.2
        
        if let outputImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let output = context.createCGImage(outputImage, from: outputImage.extent)
            return UIImage(cgImage: output!)
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_scanaction(_ sender: Any)
    {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let home1 = story.instantiateViewController(withIdentifier: "VNViewController") as!
            VNViewController
        self.present(home1, animated: true, completion: nil)
    }
    @IBAction func btn_shareaction(_ sender: Any)
    {
        if test == "true"
        {
            let image = img_image.image!
            
            // set up activity view controller
            let imageToShare = [image]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Image not found", message: "Please scan image to share", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func btn_saveaction(_ sender: Any)
    {
        if test == "true"
        {
            let image = img_image.image!
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else
        {
            let alert = UIAlertController(title: "Image not found", message: "Please scan image to svae in gallery", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image saved to gallery!!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}
extension UIImage {
    func fixed() -> UIImage {
        let ciContext = CIContext(options: nil)
        
        let cgImg = ciContext.createCGImage(ciImage!, from: ciImage!.extent)
        let image = UIImage(cgImage: cgImg!, scale: scale, orientation: .left)
        
        return image
}
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

