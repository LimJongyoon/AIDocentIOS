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
            // 캡션이 활성화된 경우 현재 이미지를 다시 그려서 캡션을 추가합니다.
            self.imageView.image = self.drawTextOnImage(text: label.text ?? "", inImage: image)
        } else if let image = imageView.image {
            // 캡션이 비활성화된 경우 이미지를 다시 로드하여 캡션을 제거합니다.
            imageView.image = image // 원본 이미지를 다시 설정 (실제 구현에서는 원본 이미지를 저장해두는 것이 필요할 수 있음)
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
        // 텍스트 색상을 흰색으로 설정합니다.
        let textColor = UIColor.white
        // 텍스트 폰트를 굵고 크기가 40인 시스템 폰트로 설정합니다.
        let textFont = UIFont.boldSystemFont(ofSize: 200)
        // 텍스트 배경색을 반투명 검정색으로 설정합니다.
        let backgroundColor = UIColor.black.withAlphaComponent(0.2)

        // 현재 화면의 스케일을 가져옵니다. 이는 레티나 디스플레이의 해상도를 지원하기 위해 사용됩니다.
        let scale = UIScreen.main.scale
        // 새로운 그래픽 컨텍스트를 생성합니다. 이 컨텍스트는 이미지를 그리고 텍스트를 덧붙이기 위해 사용됩니다.
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

        // 텍스트의 폰트 속성과 색상 속성을 설정합니다.
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont, // 폰트 설정
            NSAttributedString.Key.foregroundColor: textColor, // 텍스트 색상 설정
            NSAttributedString.Key.backgroundColor: backgroundColor // 텍스트 배경색 설정
        ] as [NSAttributedString.Key : Any]

        // 원본 이미지를 그래픽 컨텍스트에 그립니다.
        inImage.draw(in: CGRect(origin: CGPoint.zero, size: inImage.size))

        // 텍스트가 그려질 위치와 크기를 설정합니다.
        // CGRect는 사각형을 정의하는 구조체로, (x, y) 좌표와 너비(width), 높이(height)를 포함합니다.
        let textRect = CGRect(x: 20, y: inImage.size.height - 270, width: inImage.size.width - 40, height: 250)
        // 배경 사각형의 위치와 크기를 텍스트 사각형과 동일하게 설정합니다.
        //let backgroundRect = CGRect(x: 20, y: inImage.size.height - 270, width: inImage.size.width - 40, height: 250)
        
        // 현재 그래픽 컨텍스트를 가져옵니다.
        let context = UIGraphicsGetCurrentContext()
        // 배경 사각형의 색상을 설정합니다.
        context?.setFillColor(backgroundColor.cgColor)
        // 배경 사각형을 그래픽 컨텍스트에 그립니다.
        //context?.fill(backgroundRect)
        context?.fill(textRect)
        
        // 텍스트를 그래픽 컨텍스트에 그립니다.
        // 이 함수는 지정된 사각형(textRect) 내에 텍스트를 그리며, 주어진 폰트 속성과 색상 속성을 적용합니다.
        text.draw(in: textRect, withAttributes: textFontAttributes)

        // 그래픽 컨텍스트에 그려진 이미지를 가져옵니다.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // 그래픽 컨텍스트를 종료합니다.
        UIGraphicsEndImageContext()

        // 새로 생성된 이미지가 nil이 아닌지 확인하기 위한 로그 출력입니다.
        if let newImage = newImage {
            print("이미지 생성 성공: \(newImage.size)") // 이미지 생성이 성공했음을 출력합니다.
        } else {
            print("이미지 생성 실패") // 이미지 생성이 실패했음을 출력합니다.
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
