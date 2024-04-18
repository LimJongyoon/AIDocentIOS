import UIKit
import AVFoundation
import Vision

/// VisionObjectRecognitionViewController는 ViewController를 상속받아 객체 인식 기능을 추가합니다.
class VisionObjectRecognitionViewController: CameraViewController {
    
    // 인식된 객체를 표시하기 위한 오버레이 레이어입니다.
    private var detectionOverlay: CALayer! = nil
    var iphon12Ratio = 19.5/9
    // Vision 요청을 보관하는 배열입니다. 이 배열에는 객체 인식을 수행하는 VNRequest가 포함됩니다.
    private var requests = [VNRequest]()
    
    /// Vision 설정을 수행하고 Core ML 모델을 로드합니다.
    @discardableResult
    func setupVision() -> NSError? {
        let error: NSError! = nil
        
        // Core ML 모델 파일의 URL을 가져옵니다.
        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            // VNCoreMLModel을 생성하여 Vision 요청에 사용합니다.
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                // UI 업데이트는 메인 스레드에서 수행합니다.
                DispatchQueue.main.async(execute: {
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            // 생성된 요청을 requests 배열에 추가합니다.
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }

    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // 이전에 추가된 모든 레이어를 제거합니다.
        detectionOverlay.sublayers?.forEach { $0.removeFromSuperlayer() }

        // 화면 하단에 표시될 반투명 사각형 레이어를 생성합니다.
        let bottomOverlay = createBottomOverlay()
        detectionOverlay.addSublayer(bottomOverlay)
        
        // 결과가 있는 경우 첫 번째 객체의 이름을 표시합니다.
        if let firstObservation = results.first as? VNRecognizedObjectObservation {
            let topLabelObservation = firstObservation.labels.first
            if let identifier = topLabelObservation?.identifier, let confidence = topLabelObservation?.confidence {
                let textLayer = createTextSubLayerForBottomOverlay(identifier: identifier, confidence: confidence)
                bottomOverlay.addSublayer(textLayer)
            }
        }
        
        CATransaction.commit()
    }
    
    /// AVCaptureOutput의 샘플 버퍼를 받을 때마다 호출되어, Vision 요청을 수행합니다.
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 디바이스의 방향에 따른 이미지의 방향을 설정합니다.
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        // 이미지 분석을 위한 Vision 요청 핸들러를 생성하고, 요청을 수행합니다.
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    /// AVCapture를 설정하고, Vision 관련 설정을 수행합니다.
    override func setupAVCapture() {
        super.setupAVCapture()
        
        setupLayers() // 인식된 객체를 표시하기 위한 레이어를 설정합니다.
        updateLayerGeometry() // 레이어의 기하학적 변환을 업데이트합니다.
        setupVision() // Vision 요청을 설정합니다.
        
        startCaptureSession() // 캡처 세션을 시작합니다.
    }
    
    /// 인식된 객체를 표시하기 위한 레이어를 설정합니다.
    func setupLayers() {
        detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0, y: 0.0, width: bufferSize.width, height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    /// 레이어의 기하학적 변환을 업데이트합니다. 화면 방향과 크기 조정을 고려합니다.
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        // 화면 크기에 맞추어 레이어의 크기를 조정합니다.
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // 레이어를 화면 방향으로 회전하고, 크기를 조정합니다.
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
    }
    
    
    
    // 화면 하단에 표시될 회색 반투명 사각형 레이어를 생성합니다.
    func createBottomOverlay() -> CALayer {
        // 사각형 오버레이의 높이를 픽셀로 설정합니다.
        let overlayHeight: CGFloat = 100.0
        let overlayWidth: CGFloat = detectionOverlay.bounds.width / iphon12Ratio // 세로기준으로 작성됨 세로가 640이니까 비율을 그대로 따지면 295.38임
        // CALayer 인스턴스를 생성합니다. 이 레이어는 반투명 사각형으로 사용됩니다.
        let overlay = CALayer()
        // 사각형의 배경색을 반투명 회색으로 설정합니다. RGBA 값은 각각 0.5, 0.5, 0.5, 0.5입니다.
        overlay.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0, 0, 0, 0.5])
        // 사각형의 크기와 위치를 설정합니다. 여기서는 전체 너비와 위에서 정의한 높이를 사용합니다.
        overlay.bounds = CGRect(x: 0.0, y: 0.0, width: overlayWidth, height: overlayHeight)
        // 사각형의 중심 위치를 화면 하단 중앙으로 설정합니다.
        // detectionOverlay.bounds.maxX는 최하단(640)이야 거기에 사각형 박스 높이의 절반을 빼면 사각형 크기가 그대로 나옴 이유는 사각형 중앙의 포지션의 스탠다드이기 때문이다
        overlay.position = CGPoint(x: detectionOverlay.bounds.maxX - overlayHeight/2, y: detectionOverlay.bounds.midY)
        
        
        // 90도 회전 적용
        overlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi / -2))

        // 설정이 완료된 사각형 레이어를 반환합니다.
        return overlay
    }


    // 화면 하단의 반투명 사각형 내부에 표시될 텍스트 레이어를 생성합니다.
    func createTextSubLayerForBottomOverlay(identifier: String, confidence: VNConfidence) -> CATextLayer {
        // 위에 박스랑 똑같이 픽셀모드로 가는게 계산이 편리함
        let overlayHeight: CGFloat = 50.0 // 박스의 절반
        let overlayWidth: CGFloat = detectionOverlay.bounds.width / iphon12Ratio
        // CATextLayer 인스턴스를 생성합니다. 이 레이어는 텍스트를 렌더링하는 데 사용됩니다.
        let textLayer = CATextLayer()
        // 텍스트 색상을 흰색으로 설정합니다.
        textLayer.foregroundColor = UIColor.white.cgColor
        // 텍스트를 중앙 정렬합니다.
        textLayer.alignmentMode = .center
        // 텍스트 내용을 설정합니다. 여기서는 인식된 객체의 이름과 신뢰도를 포함합니다.
        textLayer.string = "\(identifier)\nConfidence: \(String(format: "%.2f", confidence))"
        // 텍스트의 폰트 크기를 픽셀로 설정합니다.
        textLayer.fontSize = 15
        // 긴 텍스트가 레이어를 넘어갈 경우 끝을 생략하기 위해 truncationMode를 설정합니다.
        textLayer.truncationMode = .end
        // 텍스트 레이어가 여러 줄의 텍스트를 지원하도록 설정합니다.
        textLayer.isWrapped = true
        // 사각형 내부에 텍스트 레이어를 위치시키기 위해 bounds를 조정합니다. 상하 여백을 고려하여 조정합니다.
        textLayer.bounds = CGRect(x: 0, y: 0, width: overlayWidth, height: overlayHeight)
        // 텍스트 레이어의 위치를 사각형 내부 중앙으로 설정합니다. 높이의 절반 지점에 위치하게 합니다.
        // 사실 왜인지는 모르겠지만 높이값(y)의 0점이 회색박스 상단이 기준임 그래서 레이어 박스 크기만큼 빼준것
        textLayer.position = CGPoint(x: overlayWidth/2, y: overlayHeight/2)
        // 레티나 디스플레이에 대응하기 위해 contentsScale을 설정합니다.
        textLayer.contentsScale = UIScreen.main.scale
        // 텍스트 레이어를 x축을 기준으로 반전시킵니다.
        textLayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
        
        // 텍스트 레이어에 테두리 추가 확인용
        // textLayer.borderColor = UIColor.red.cgColor //빨간테두리
        // textLayer.borderWidth = 2.0 // 테두리 두께 설정

        // 설정된 텍스트 레이어를 반환합니다.
        return textLayer
    }
    
    
}

    

