# 配置
需要配置文件权限
>Privacy - Camera Usage Description
Privacy - Camera Usage Description

导入头文件
``` swift
import AVFoundation
```

# 二维码扫描
## 定义摄像头
``` swift
var session: AVCaptureSession!
var layer: AVCaptureVideoPreviewLayer!
```

## 设置摄像头
``` swift
func setupScanSession() {
    // 获取摄像设备
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    // 看看有没有可用摄像头,一般可能被用户取消授权需主动去设置界面开启
    guard device != nil else {
        let alertView = UIAlertView(title: "提示", message: "没有发现可用摄像设备", delegate: self, cancelButtonTitle: "确定")
        alertView.show()
        return
    }
    // 初始化链接对象
    session = AVCaptureSession()
    let input: AVCaptureDeviceInput?
    do {
        input = try AVCaptureDeviceInput.init(device: device)
    } catch {
        print("输入流出问题了:\(error)")
        return
    }
    // 设置会话的输入设备
    if session.canAddInput(input) {
        session.addInput(input)
    }
    // 创建输出流
    let output = AVCaptureMetadataOutput()
    // 设置代理, 在主线程里刷新
    output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    // 设置高质量采集率
    session.canSetSessionPreset(AVCaptureSessionPresetHigh)
    if session.canAddOutput(output) {
        session.addOutput(output)
    }
    // 设置扫码支持的编码格式 (条形码和二维码)
    output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
    layer = AVCaptureVideoPreviewLayer(session: session)
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    // 设置相机扫描框大小
    layer.frame = CGRect(x: 10, y: 100, width: 300, height: 300)
    self.view.layer.insertSublayer(layer, at: 0)
    // 开始扫描
    startScan()
}
```
## 开始扫描
``` swift
fileprivate func startScan() {
    guard let session = session else { return }
    if !session.isRunning {
        session.startRunning()
    }
}
```
## 扫码捕捉完成
``` swift
//扫描捕捉完成
extension ScanQRViewController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // 停止扫码
        session.stopRunning()
        // 开始对信息解读
        var QRCodeMessage = ""
        for metaData in metadataObjects {
            if (metaData as? AVMetadataObject)?.type == AVMetadataObjectTypeQRCode {
                QRCodeMessage = ((metaData as? AVMetadataMachineReadableCodeObject)?.stringValue)!
            }
        }
        print("扫码结果\(QRCodeMessage)")
    }
}
```

# 二维码识别
## UIImage扩展类实现
``` swift
extension UIImage {
    /**
    1.识别图片二维码
    - returns: 二维码内容
    */
    func recognizeQRCode() -> String? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        let features = detector?.features(in: CoreImage.CIImage(cgImage: self.cgImage!))
        guard (features?.count)! > 0 else { return nil }
        let feature = features?.first as? CIQRCodeFeature
        return feature?.messageString
    }
}
```
## 调用
``` swift
let image = UIImage(named: "qrimage")
DispatchQueue.global().async {
    let recognizeResult = image?.recognizeQRCode()
    let result = (recognizeResult?.characters.count)! > 0 ? recognizeResult : "无法识别"
    print(result)
}
```


# 二维码生成
## String扩展
``` swift
extension String {
    /**
    生成二维码

    - parameter size:            大小
    - parameter color:           颜色
    - parameter bgColor:         背景颜色
    - parameter logo:            图标
    - parameter radius:          圆角
    - parameter borderLineWidth: 线宽
    - parameter borderLineColor: 线颜色
    - parameter boderWidth:      带宽
    - parameter borderColor:     带颜色

    - returns: 自定义二维码
    */
    func generateQRCode(size:CGFloat?,color:UIColor?,bgColor:UIColor?,logo:UIImage?,radius:CGFloat,borderLineWidth:CGFloat?,borderLineColor:UIColor?,boderWidth:CGFloat?,borderColor:UIColor?) -> UIImage {

        let ciImage = generateCIImage(size: size, color: color, bgColor: bgColor)
        let image = UIImage(ciImage: ciImage)

        guard let QRCodeLogo = logo else { return image }

        let logoWidth = image.size.width/4
        let logoFrame = CGRect(x: (image.size.width - logoWidth) /  2, y: (image.size.width - logoWidth) / 2, width: logoWidth, height: logoWidth)

        // 绘制logo
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        // 线框
        let logoBorderLineImagae = QRCodeLogo.getRoundRectImage(size: logoWidth, radius: radius, borderWidth: borderLineWidth, borderColor: borderLineColor)
        // 边框
        let logoBorderImagae = logoBorderLineImagae.getRoundRectImage(size: logoWidth, radius: radius, borderWidth: boderWidth, borderColor: borderColor)

        logoBorderImagae.draw(in: logoFrame)

        let QRCodeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return QRCodeImage!
    }


    /**
    生成CIImage

    - parameter size:    大小
    - parameter color:   颜色
    - parameter bgColor: 背景颜色

    - returns: CIImage
    */
    func generateCIImage(size:CGFloat?,color:UIColor?,bgColor:UIColor?) -> CIImage {

        // 1.缺省值
        var QRCodeSize : CGFloat = 300//默认300
        var QRCodeColor = UIColor.black//默认黑色二维码
        var QRCodeBgColor = UIColor.white//默认白色背景

        if let size = size { QRCodeSize = size }
        if let color = color { QRCodeColor = color }
        if let bgColor = bgColor { QRCodeBgColor = bgColor }

        // 2.二维码滤镜
        let contentData = self.data(using: String.Encoding.utf8)
        let fileter = CIFilter(name: "CIQRCodeGenerator")

        fileter?.setValue(contentData, forKey: "inputMessage")
        fileter?.setValue("H", forKey: "inputCorrectionLevel")

        let ciImage = fileter?.outputImage

        // 3.颜色滤镜
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(cgColor: QRCodeColor.cgColor), forKey: "inputColor0")// 二维码颜色
        colorFilter?.setValue(CIColor(cgColor: QRCodeBgColor.cgColor), forKey: "inputColor1")// 背景色

        // 4.生成处理
        let outImage = colorFilter!.outputImage
        let scale = QRCodeSize / outImage!.extent.size.width;
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let transformImage = colorFilter!.outputImage!.applying(transform)
        return transformImage
    }
}
```
## UIImage扩展类
``` swift
extension UIImage {
    // 获取圆角图片
    func getRoundRectImage(size:CGFloat,radius:CGFloat) -> UIImage {
        return getRoundRectImage(size: size, radius: radius, borderWidth: nil, borderColor: nil)
    }

    // 获取圆角图片(带边框)
    func getRoundRectImage(size:CGFloat,radius:CGFloat,borderWidth:CGFloat?,borderColor:UIColor?) -> UIImage {
        let scale = self.size.width / size ;

        // 初始值
        var defaultBorderWidth : CGFloat = 0
        var defaultBorderColor = UIColor.clear

        if let borderWidth = borderWidth { defaultBorderWidth = borderWidth * scale }
        if let borderColor = borderColor { defaultBorderColor = borderColor }

        let radius = radius * scale
        let react = CGRect(x: defaultBorderWidth, y: defaultBorderWidth, width: self.size.width - 2 * defaultBorderWidth, height: self.size.height - 2 * defaultBorderWidth)

        // 绘制图片设置
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let path = UIBezierPath(roundedRect:react , cornerRadius: radius)

        // 绘制边框
        path.lineWidth = defaultBorderWidth
        defaultBorderColor.setStroke()
        path.stroke()
        path.addClip()

        // 画图片
        draw(in: react)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!;
    }
}
```
## 使用
``` swift
let url = "http://www.baidu.com"
let image = url.generateQRCode()
```

[源码下载](https://github.com/wjncode/DNQrCodeScanning)
