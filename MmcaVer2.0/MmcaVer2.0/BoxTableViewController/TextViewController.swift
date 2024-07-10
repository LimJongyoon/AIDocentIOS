import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textColorButton: UIButton!
    @IBOutlet weak var textAlignmentButton: UIButton!
    @IBOutlet weak var backgroundColorButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var currentText: String?
    var currentTextColor: UIColor?
    var currentTextAlignment: NSTextAlignment?
    var currentBackgroundColor: UIColor?
    
    var completionHandler: ((String?, UIColor?, NSTextAlignment?, UIColor?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기 값 설정
        textField.text = currentText
        textField.textColor = currentTextColor ?? .black
        textField.textAlignment = currentTextAlignment ?? .center
        textField.backgroundColor = currentBackgroundColor ?? UIColor(white: 0.9, alpha: 1.0) // 기본 배경색 설정
        
        // 텍스트 필드에 연필 아이콘 추가
        let pencilIcon = UIImage(systemName: "pencil")
        let iconView = UIImageView(image: pencilIcon)
        iconView.tintColor = .gray
        
        // 연필 아이콘을 포함한 패딩 뷰 생성
        let iconPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: iconView.frame.width + 10, height: iconView.frame.height))
        iconView.frame.origin.x += -10 // 왼쪽으로 20포인트 이동
        iconPaddingView.addSubview(iconView)
        
        textField.rightView = iconPaddingView
        textField.rightViewMode = .always
        
        // 배경 클릭 시 키보드 숨기기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text
    }
    
    @IBAction func changeTextColor() {
        let alertController = UIAlertController(title: "텍스트 색상 선택", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "빨간색", style: .default, handler: { _ in
            self.textField.textColor = .red
        }))
        alertController.addAction(UIAlertAction(title: "초록색", style: .default, handler: { _ in
            self.textField.textColor = .green
        }))
        alertController.addAction(UIAlertAction(title: "파란색", style: .default, handler: { _ in
            self.textField.textColor = .blue
        }))
        alertController.addAction(UIAlertAction(title: "노란색", style: .default, handler: { _ in
            self.textField.textColor = .yellow
        }))
        alertController.addAction(UIAlertAction(title: "보라색", style: .default, handler: { _ in
            self.textField.textColor = .purple
        }))
        alertController.addAction(UIAlertAction(title: "검은색", style: .default, handler: { _ in
            self.textField.textColor = .black
        }))
        alertController.addAction(UIAlertAction(title: "흰색", style: .default, handler: { _ in
            self.textField.textColor = .white
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeTextAlignment() {
        let alertController = UIAlertController(title: "텍스트 정렬 선택", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "왼쪽 정렬", style: .default, handler: { _ in
            self.textField.textAlignment = .left
        }))
        alertController.addAction(UIAlertAction(title: "가운데 정렬", style: .default, handler: { _ in
            self.textField.textAlignment = .center
        }))
        alertController.addAction(UIAlertAction(title: "오른쪽 정렬", style: .default, handler: { _ in
            self.textField.textAlignment = .right
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeBackgroundColor() {
        let alertController = UIAlertController(title: "배경 색상 선택", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "흰색", style: .default, handler: { _ in
            self.textField.backgroundColor = .white
        }))
        alertController.addAction(UIAlertAction(title: "검은색", style: .default, handler: { _ in
            self.textField.backgroundColor = .black
        }))
        alertController.addAction(UIAlertAction(title: "회색", style: .default, handler: { _ in
            self.textField.backgroundColor = .gray
        }))
        alertController.addAction(UIAlertAction(title: "파란색", style: .default, handler: { _ in
            self.textField.backgroundColor = .blue
        }))
        alertController.addAction(UIAlertAction(title: "녹색", style: .default, handler: { _ in
            self.textField.backgroundColor = .green
        }))
        alertController.addAction(UIAlertAction(title: "노란색", style: .default, handler: { _ in
            self.textField.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0) // 옅은 노란색
        }))
        alertController.addAction(UIAlertAction(title: "옅은 회색", style: .default, handler: { _ in
            self.textField.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // 옅은 회색
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped() {
        completionHandler?(textField.text, textField.textColor, textField.textAlignment, textField.backgroundColor)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
