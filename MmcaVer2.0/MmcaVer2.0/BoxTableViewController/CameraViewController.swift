import UIKit
import CoreML
import Vision

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    // UIImageView를 IBOutlet으로 연결하여 인터페이스 빌더에서 설정할 수 있도록 합니다.
    @IBOutlet weak var imageView: UIImageView!
    
    // UILabel을 IBOutlet으로 연결하여 인터페이스 빌더에서 설정할 수 있도록 합니다.
    @IBOutlet weak var label: UILabel!
        
    // UIImagePickerController 인스턴스를 생성합니다.
    let imagePicker = UIImagePickerController()
    
    // 원본 이미지를 저장할 변수
    var selectedImage: UIImage?
    var originalImage: UIImage?
    
    // 캡션 기능 활성화 여부를 나타내는 변수
    var captionEnabled = false
    var editedText: String?
    var editedTextColor: UIColor?
    var editedTextAlignment: NSTextAlignment?
    var editedBackgroundColor: UIColor?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "라벨 카메라"

        // 이미지 피커의 델리게이트를 설정합니다.
        imagePicker.delegate = self
        // 버튼 초기 상태 설정
        if let captionButton = view.viewWithTag(100) as? UIButton {
            captionButton.setTitle("캡션 달기", for: .normal)
            captionButton.backgroundColor = UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0) // 연한 파란색
            captionButton.layer.cornerRadius = 5 // 모서리를 둥글게
            captionButton.clipsToBounds = true
        }
        
        // savePhoto 버튼에 테두리 설정
        if let savePhoto = view.viewWithTag(99) as? UIButton {
            savePhoto.layer.borderColor = UIColor.black.cgColor
            savePhoto.layer.borderWidth = 2
            savePhoto.layer.cornerRadius = 15 // 모서리를 둥글게
            savePhoto.clipsToBounds = true
        }
        setupCustomNavigationButton()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupCustomNavigationButton() {
        // 홈 버튼과 chevron.left 이미지 추가
        let homeChevron = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goToHome))
        let homeButton = createCustomButton(title: " 홈 ", image: nil, action: #selector(goToHome))
        let customHomeButton = UIBarButtonItem(customView: homeButton)
        
        self.navigationItem.leftBarButtonItems = [homeChevron, customHomeButton]
    }
    
    func createCustomButton(title: String, image: String?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .black
        config.background.backgroundColor = .white
        config.background.strokeColor = .gray
        config.background.strokeWidth = 1
        config.background.cornerRadius = 5
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        if let imageName = image {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
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
            // 수정된 값이 있으면 이를 사용
            let text = editedText ?? label.text ?? ""
            let textColor = editedTextColor ?? .black
            let textAlignment = editedTextAlignment ?? .center
            let backgroundColor = editedBackgroundColor ?? label.backgroundColor ?? UIColor(white: 0.9, alpha: 1.0)

            // 캡션이 활성화된 경우 현재 이미지를 다시 그려서 캡션을 추가합니다.
            self.imageView.image = self.drawTextOnImage(
                text: text,
                inImage: image,
                textColor: textColor,
                textAlignment: textAlignment,
                backgroundColor: backgroundColor
            )
            // 버튼 제목과 색상 변경
            sender.setTitle("캡션 취소", for: .normal)
            sender.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0) // 연한 빨간색
            sender.layer.cornerRadius = 10 // 모서리를 둥글게
            sender.clipsToBounds = true
        } else if let originalImage = originalImage {
            // 캡션이 비활성화된 경우 원본 이미지를 다시 설정합니다.
            imageView.image = originalImage
            // 버튼 제목과 색상 변경
            sender.setTitle("캡션 달기", for: .normal)
            sender.backgroundColor = UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0) // 연한 파란색
            sender.layer.cornerRadius = 10 // 모서리를 둥글게
            sender.clipsToBounds = true
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
                    self.imageView.image = self.drawTextOnImage(
                        text: classification,
                        inImage: self.imageView.image!,
                        textColor: .black,
                        textAlignment: .center,
                        backgroundColor: UIColor(white: 0.9, alpha: 1.0)
                    )
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
    
    //수정버튼
    @IBAction func moveToTextViewController(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let textViewController = storyboard.instantiateViewController(withIdentifier: "TextViewController") as? TextViewController {
            // 데이터 전달
            textViewController.currentText = self.label.text
            textViewController.currentTextColor = self.label.textColor
            textViewController.currentTextAlignment = self.label.textAlignment
            textViewController.currentBackgroundColor = self.label.backgroundColor

            // 데이터 수정 후 받기
            textViewController.completionHandler = { [weak self] text, textColor, textAlignment, backgroundColor in
                guard let self = self else { return }
                // 수정된 값을 저장
                self.editedText = text
                self.editedTextColor = textColor
                self.editedTextAlignment = textAlignment
                self.editedBackgroundColor = backgroundColor
                
                // UILabel에도 수정된 값 반영
                self.label.text = text
                self.label.textColor = textColor ?? .black
                self.label.textAlignment = textAlignment ?? .center
                self.label.backgroundColor = backgroundColor ?? .white
            }
            
            textViewController.modalPresentationStyle = .fullScreen
            textViewController.modalTransitionStyle = .coverVertical
            
            self.present(textViewController, animated: true, completion: nil)
        }
    }
    
    // 이미지에 텍스트를 덮어씌우는 메서드입니다.
    func drawTextOnImage(text: String, inImage: UIImage, textColor: UIColor, textAlignment: NSTextAlignment, backgroundColor: UIColor) -> UIImage {
        // 텍스트 사이즈를 설정합니다.
        let textSize: CGFloat = 120
        // 텍스트 폰트를 설정합니다.
        let textFont = UIFont.boldSystemFont(ofSize: textSize)
        
        // 현재 화면의 스케일을 가져옵니다.
        let scale = UIScreen.main.scale
        // 상하좌우 기본 여백을 설정합니다.
        let padding: CGFloat = 80
        // 하단 여백을 더 크게 설정합니다.
        let bottomPadding: CGFloat = 400
        // 텍스트 상하 위치 조정 패딩 클수록 아래로 내려감
        let textPadding: CGFloat = 120
        
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
    @objc func goToHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
