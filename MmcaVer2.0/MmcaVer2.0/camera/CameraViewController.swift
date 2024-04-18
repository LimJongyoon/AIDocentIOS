import UIKit            //UIKit: iOS 앱의 사용자 인터페이스를 관리하고 이벤트를 처리합니다.
import AVFoundation     //AVFoundation: 오디오 및 비디오 처리를 위한 프레임워크입니다. 여기서는 카메라 입력과 비디오 데이터 출력을 관리하는 데 사용됩니다.
import Vision           //Vision: 이미지 분석 및 인식 기능을 제공하는 프레임워크입니다. 이 코드에서는 직접적으로 사용되지 않지만, 비디오 스트림을 처리하거나 머신 러닝 모델을 적용할 때 사용할 수 있습니다.


// ViewController 클래스는 AVCaptureVideoDataOutputSampleBufferDelegate 프로토콜을 채택하여,
// 카메라 비디오 데이터의 샘플 버퍼를 받고, AVFoundation 프레임워크를 사용해 비디오 스트림을 처리합니다.
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // 카메라로부터 받은 비디오의 현재 프레임 크기를 저장합니다.
    var bufferSize: CGSize = .zero
    // 최상위 뷰 레이어를 참조하기 위한 변수입니다. 비디오 프리뷰를 표시하는데 사용됩니다.
    var rootLayer: CALayer! = nil
    
    // 스토리보드에서 연결한 비디오 프리뷰 뷰입니다.
    @IBOutlet weak private var previewView: UIView!
    // AVCaptureSession 객체는 입력(카메라)과 출력(비디오 데이터) 사이의 데이터 흐름을 관리합니다.
    private let session = AVCaptureSession()
    // 실시간으로 카메라 비디오를 표시하는 레이어입니다.
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    // 카메라로부터 비디오 데이터를 출력하기 위한 객체입니다.
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // 비디오 데이터 출력을 처리하기 위한 별도의 큐입니다. 비디오 프레임 처리를 UI 작업과 분리하여 실행 속도를 향상시킵니다.
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // AVCaptureVideoDataOutputSampleBufferDelegate 프로토콜의 메소드. 새로운 비디오 프레임(샘플 버퍼)이 도착할 때마다 호출됩니다.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 구현은 서브클래스나 이 클래스에서 추가로 작성할 수 있습니다. 예를 들어, 프레임에서 얼굴을 인식하는 코드를 추가할 수 있습니다.
    }
    
    // 뷰가 메모리에 로드된 후 호출됩니다. 여기서 카메라 설정 및 초기화를 시작합니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture() // 카메라 설정 및 초기화 메소드 호출
    }
    
    // 메모리 경고를 받았을 때 호출됩니다. 필요한 경우 추가 메모리 정리 작업을 수행할 수 있습니다.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 카메라와 관련된 설정을 초기화하고 세션을 구성하는 메소드입니다.
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // 사용 가능한 카메라 장치 중 후면 카메라를 선택합니다.
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        // 세션 구성을 시작합니다. 여기서는 비디오 품질을 VGA로 설정합니다.
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // 모델 이미지 크기가 작기 때문에 VGA 품질로 설정합니다.
        
        // 세션에 비디오 입력을 추가합니다. 성공적으로 추가되지 않으면 구성을 커밋하지 않고 종료합니다.
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        // 비디오 데이터 출력을 세션에 추가하고 구성합니다. 지연된 프레임은 버립니다.
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            // 비디오 데이터 처리를 위한 큐에 델리게이트를 설정합니다.
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        // 비디오 프레임을 항상 처리하도록 설정합니다.
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        
        // 비디오 장치의 해상도를 기반으로 bufferSize를 설정합니다.
        do {
            try videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        // 세션 구성을 커밋합니다.
        session.commitConfiguration()
        
        // 비디오 프리뷰 레이어를 초기화하고, 루트 레이어에 추가합니다.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    // 카메라 세션을 시작하는 메소드입니다. 이는 사용자가 직접 호출할 수 있습니다.
    func startCaptureSession() {
        session.startRunning()
    }
    
    // 카메라 세션 설정을 해제하고 리소스를 정리하는 메소드입니다.
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer() // 프리뷰 레이어를 루트 레이어에서 제거합니다.
        previewLayer = nil
    }
    
    // 비디오 프레임이 드랍될 때 호출되는 메소드입니다. 드랍된 프레임에 대한 처리를 구현할 수 있습니다.
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 예: "프레임 드랍됨"을 로깅할 수 있습니다.
    }
    
    // 디바이스 방향에 따라 적절한 EXIF 이미지 방향을 반환하는 함수입니다.
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // 디바이스가 세로 방향으로 뒤집혀 있을 때
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // 디바이스가 가로 방향으로 왼쪽으로 기울어져 있을 때
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // 디바이스가 가로 방향으로 오른쪽으로 기울어져 있을 때
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // 디바이스가 세로 방향으로 바로 서 있을 때
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}
