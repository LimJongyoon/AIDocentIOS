import UIKit
import CoreML
import Vision

class ACameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var selectedImage: UIImage?
    var originalImage: UIImage?
    var editedText: String?
    var editedTextColor: UIColor?
    var editedTextAlignment: NSTextAlignment?
    var editedBackgroundColor: UIColor?
    var autoOpenCamera = false // 자동으로 카메라를 열지 여부를 결정하는 플래그
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "라벨 카메라"
        
        imagePicker.delegate = self
        
        if let image = selectedImage {
            imageView.image = image
            classifyImage(image: image)
        }
        
        setupCustomNavigationButtons()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // UILabel을 인비지블하게 설정
        label.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // autoOpenCamera가 true이면 takePhoto 메서드를 호출하여 카메라를 자동으로 엽니다.
        if autoOpenCamera {
            autoOpenCamera = false
            takePhoto()
        }
    }
    
    func setupCustomNavigationButtons() {
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
    
    @IBAction func moveToTextViewController(_ sender: UIButton) {
        // 텍스트 수정으로 들어가기 전에 캡션을 제거
        if let originalImage = originalImage {
            imageView.image = originalImage
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let textViewController = storyboard.instantiateViewController(withIdentifier: "TextViewController") as? TextViewController {
            textViewController.currentText = self.label.text
            textViewController.currentTextColor = self.label.textColor
            textViewController.currentTextAlignment = self.label.textAlignment
            textViewController.currentBackgroundColor = self.label.backgroundColor

            textViewController.completionHandler = { [weak self] text, textColor, textAlignment, backgroundColor in
                guard let self = self else { return }
                self.editedText = text
                self.editedTextColor = textColor
                self.editedTextAlignment = textAlignment
                self.editedBackgroundColor = backgroundColor
                
                self.label.text = text
                self.label.textColor = textColor ?? .black
                self.label.textAlignment = textAlignment ?? .center
                self.label.backgroundColor = backgroundColor ?? .white

                // 텍스트가 수정된 후 이미지를 다시 그려서 캡션을 업데이트합니다.
                if let updatedText = text {
                    self.addCaptionToImage(updatedText)
                }
            }
            
            textViewController.modalPresentationStyle = .fullScreen
            textViewController.modalTransitionStyle = .coverVertical
            
            self.present(textViewController, animated: true, completion: nil)
        }
    }
    
    func classifyImage(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else { return }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self.label.text = "분류할 수 없음"
                }
                return
            }
            DispatchQueue.main.async {
                let classification = "\(topResult.identifier) - \(Int(topResult.confidence * 100))%"
                self.label.text = classification
                self.addCaptionToImage(classification)
            }
        }
        guard let ciImage = CIImage(image: image) else { return }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
    
    func addCaptionToImage(_ text: String) {
        guard let image = imageView.image else { return }
        let textColor = editedTextColor ?? .black
        let textAlignment = editedTextAlignment ?? .center
        let backgroundColor = editedBackgroundColor ?? label.backgroundColor ?? UIColor(white: 0.9, alpha: 1.0)
        
        self.imageView.image = self.drawTextOnImage(
            text: text,
            inImage: image,
            textColor: textColor,
            textAlignment: textAlignment,
            backgroundColor: backgroundColor
        )
    }
    
    func drawTextOnImage(text: String, inImage: UIImage, textColor: UIColor, textAlignment: NSTextAlignment, backgroundColor: UIColor) -> UIImage {
        let textSize: CGFloat = 120
        let textFont = UIFont.boldSystemFont(ofSize: textSize)
        
        let scale = UIScreen.main.scale
        let padding: CGFloat = 80
        let bottomPadding: CGFloat = 400
        let textPadding: CGFloat = 120
        
        let imageSize = CGSize(width: inImage.size.width + padding * 2, height: inImage.size.height + padding + bottomPadding)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: imageSize))
        
        inImage.draw(in: CGRect(x: padding, y: padding, width: inImage.size.width, height: inImage.size.height))
        
        let textRect = CGRect(x: padding, y: inImage.size.height + padding + textPadding, width: inImage.size.width, height: bottomPadding)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attributedString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
        
        attributedString.draw(in: textRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    @IBAction func reTakePhoto(_ sender: UIButton) {
        takePhoto()
    }
    
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
            let alert = UIAlertController(title: "저장 완료", message: "이미지에 라벨을 달아서 저장했습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func goToHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let _ = presentedViewController as? UIImagePickerController {
                // 이미 UIImagePickerController가 표시되어 있는 경우 다시 표시하지 않음
                return
            }
            
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "카메라 사용 불가", message: "카메라를 사용할 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        self.selectedImage = image
        self.originalImage = image
        self.imageView.image = image
        classifyImage(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
