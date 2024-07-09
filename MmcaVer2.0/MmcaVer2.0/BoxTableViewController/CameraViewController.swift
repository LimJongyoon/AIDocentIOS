import UIKit
import CoreML
import Vision

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UIImageView를 IBOutlet으로 연결하여 인터페이스 빌더에서 설정할 수 있도록 합니다.
    @IBOutlet weak var imageView: UIImageView!
    
    // UILabel을 IBOutlet으로 연결하여 인터페이스 빌더에서 설정할 수 있도록 합니다.
    @IBOutlet weak var label: UILabel!
    
    // UIImagePickerController 인스턴스를 생성합니다.
    let imagePicker = UIImagePickerController()
    
    // 원본 이미지를 저장할 변수
    var originalImage: UIImage?
    
    // 캡션 기능 활성화 여부를 나타내는 변수
    var captionEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 이미지 피커의 델리게이트를 설정합니다.
        imagePicker.delegate = self
    }
    
    // 사진 업로드 버튼의 액션 메서드입니다.
    @IBAction func uploadPhoto(_ sender: UIButton) {
        
        // 사진첩을 소스 타입으로 설정합니다.
        imagePicker.sourceType = .photoLibrary
        // 이미지 피커를 화면에 표시합니다.
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 사진 촬영 버튼의 액션 메서드입니다.
    @IBAction func takePhoto(_ sender: UIButton) {
        // 카메라가 사용 가능한 경우에만 실행됩니다.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 카메라를 소스 타입으로 설정합니다.
            imagePicker.sourceType = .camera
            // 이미지 피커를 화면에 표시합니다.
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // 캡션 버튼의 액션 메서드입니다.
    @IBAction func toggleCaption(_ sender: UIButton) {
        // 캡션 기능의 활성화 상태를 토글합니다.
        captionEnabled.toggle()
        
        if captionEnabled, let image = imageView.image {
            // 원본 이미지를 저장합니다.
            originalImage = image
            // 캡션이 활성화된 경우 현재 이미지를 다시 그려서 캡션을 추가합니다.
            self.imageView.image = self.drawTextOnImage(text: label.text ?? "", inImage: image)
        } else if let originalImage = originalImage {
            // 캡션이 비활성화된 경우 원본 이미지를 다시 설정합니다.
            imageView.image = originalImage
        }
    }

    
    // 사용자가 이미지를 선택하거나 촬영하면 호출됩니다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 피커를 닫습니다.
        picker.dismiss(animated: true, completion: nil)
        // 선택된 이미지를 가져옵니다.
        guard let image = info[.originalImage] as? UIImage else { return }
        // 이미지 뷰에 이미지를 설정합니다.
        imageView.image = image
        // 이미지를 분류합니다.
        classifyImage(image: image)
    }
    
    // 이미지를 분류하는 메서드입니다.
    func classifyImage(image: UIImage) {
        // CoreML 모델을 로드합니다.
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else { return }
        // Vision 요청을 생성합니다.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // 요청 결과를 가져옵니다.
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    // 결과가 없으면 라벨에 에러 메시지를 표시합니다.
                    self.label.text = "분류할 수 없음"
                }
                return
            }
            // 가장 높은 확률의 결과를 라벨에 표시합니다.
            DispatchQueue.main.async {
                // 분류된 텍스트를 생성합니다.
                let classification = "\(topResult.identifier) - \(Int(topResult.confidence * 100))%"
                // UILabel에 분류 결과를 설정합니다.
                self.label.text = classification
                // 텍스트를 이미지에 그려서 imageView에 설정합니다.
                if self.captionEnabled {
                    self.imageView.image = self.drawTextOnImage(text: classification, inImage: self.imageView.image!)
                }
            }
        }
        // UIImage를 CIImage로 변환합니다.
        guard let ciImage = CIImage(image: image) else { return }
        // Vision 요청 핸들러를 생성합니다.
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            // Vision 요청을 수행합니다.
            try? handler.perform([request])
        }
    }
    
    // 이미지에 텍스트를 덮어씌우는 메서드입니다.
    func drawTextOnImage(text: String, inImage: UIImage) -> UIImage {
        // 텍스트 색상을 설정합니다.
        let textColor = UIColor.black
        // 텍스트 사이즈를 설정합니다.
        let textSize: CGFloat = 120
        // 텍스트 폰트를 설정합니다.
        let textFont = UIFont.boldSystemFont(ofSize: textSize)
        // 텍스트 정렬
        let textAlignment: NSTextAlignment = .center
        // 배경 색상을 밝은 회색으로 설정합니다.
        let backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        // 현재 화면의 스케일을 가져옵니다.
        let scale = UIScreen.main.scale
        // 상하좌우 기본 여백을 설정합니다.
        let padding: CGFloat = 40
        // 하단 여백을 더 크게 설정합니다.
        let bottomPadding: CGFloat = 400
        // 텍스트 상하 위치 조정 패딩
        let textPadding: CGFloat = 100
        
        // 새로운 이미지 크기를 설정합니다. 원본 이미지의 크기에 상하좌우 여백을 더합니다.
        let imageSize = CGSize(width: inImage.size.width + padding * 2, height: inImage.size.height + padding + bottomPadding)
        
        // 새로운 그래픽 컨텍스트를 생성합니다. 이 컨텍스트는 이미지를 그리고 텍스트를 덧붙이기 위해 사용됩니다.
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        // 텍스트의 폰트 속성과 색상 속성을 설정합니다.
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont, // 폰트 설정
            NSAttributedString.Key.foregroundColor: textColor, // 텍스트 색상 설정
        ] as [NSAttributedString.Key : Any]

        // 배경 색상을 설정합니다.
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        // 배경 색상을 전체 이미지 크기로 채웁니다.
        context?.fill(CGRect(origin: CGPoint.zero, size: imageSize))
        
        // 원본 이미지를 그래픽 컨텍스트에 그립니다.
        inImage.draw(in: CGRect(x: padding, y: padding, width: inImage.size.width, height: inImage.size.height))
        
        // 텍스트가 그려질 위치와 크기를 설정합니다.
        let textRect = CGRect(x: padding, y: inImage.size.height + padding + textPadding, width: inImage.size.width, height: bottomPadding)
        
        // 텍스트 정렬 스타일을 중앙 정렬로 설정합니다.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        // 텍스트 속성에 정렬 스타일을 추가합니다.
        let attributedString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
        
        // 텍스트를 지정된 사각형 영역에 그립니다.
        attributedString.draw(in: textRect)
        
        // 그래픽 컨텍스트에 그려진 이미지를 가져옵니다.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // 그래픽 컨텍스트를 종료합니다.
        UIGraphicsEndImageContext()

        // 새로 생성된 이미지가 있는지 확인합니다.
        if let newImage = newImage {
            print("이미지 생성 성공: \(newImage.size)")
        } else {
            print("이미지 생성 실패")
        }

        // 새로 생성된 이미지를 반환합니다.
        return newImage!
    }


    
    // 저장 버튼의 액션 메서드입니다.
    @IBAction func savePhoto(_ sender: UIButton) {
        guard let image = imageView.image else {
            let alert = UIAlertController(title: "저장 실패", message: "저장할 이미지가 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "저장 실패", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "저장 끝ㅎ", message: "이미지에 라벨달아서 저장함 ㅎ.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}
