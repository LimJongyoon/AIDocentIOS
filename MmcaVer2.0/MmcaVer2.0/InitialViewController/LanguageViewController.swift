import UIKit

class LanguageViewController: UIViewController {
    
    
    
    @IBOutlet weak var koreaButton: UIButton!
    @IBOutlet weak var USAButton: UIButton!
    @IBOutlet weak var japanButton: UIButton!
    @IBOutlet weak var languageLabel: UILabel!
    
    let lastSelectedLanguageKey = "lastSelectedLanguage"
    let lastSelectedLabelTextKey = "lastSelectedLabelText"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전에 저장된 마지막 선택한 언어와 해당 언어에 대한 라벨 불러오기
        if let lastSelectedLanguage = UserDefaults.standard.string(forKey: lastSelectedLanguageKey),
           let lastSelectedLabelText = UserDefaults.standard.string(forKey: lastSelectedLabelTextKey) {
            updateTitleAndLabel(title: lastSelectedLanguage, text: lastSelectedLabelText)
        }
        
        // 모든 버튼의 테두리를 둥글게 설정하는 함수 호출
        configureButton(koreaButton, withBorderColor: UIColor.black.cgColor)
        configureButton(USAButton, withBorderColor: UIColor.black.cgColor)
        configureButton(japanButton, withBorderColor: UIColor.black.cgColor)
    }
    
    // 버튼의 모양을 구성하는 함수
    func configureButton(_ button: UIButton, withBorderColor borderColor: CGColor) {
        button.layer.cornerRadius = 5  // 원하는 모서리의 반경 설정
        button.layer.borderWidth = 0.5    // 테두리 두께 설정
        button.layer.borderColor = borderColor  // 테두리 색상 설정
        button.clipsToBounds = true  // 이 속성은 뷰의 콘텐츠가 뷰의 경계를 넘어가지 않도록 합니다.
    }
    
    
    // 각 버튼을 눌렀을 때 실행될 액션들
    
    @IBAction func koreaButton(_ sender: UIButton) {
        updateTitleAndLabel(title: "언어", text: "한국어")
    }
    
    @IBAction func USAButton(_ sender: UIButton) {
        updateTitleAndLabel(title: "Language", text: "English")
    }
    
    @IBAction func japanButton(_ sender: UIButton) {
        updateTitleAndLabel(title: "言語", text: "日本語")
    }
    
    
    // 타이틀과 라벨을 업데이트하는 함수
    func updateTitleAndLabel(title: String, text: String ) {
        self.navigationItem.title = title  // 뷰 컨트롤러의 타이틀 업데이트
        languageLabel.text = text  // 라벨의 텍스트 업데이트
        
        // 선택한 언어와 해당 언어에 대한 라벨을 UserDefaults에 저장
        UserDefaults.standard.set(title, forKey: lastSelectedLanguageKey)
        UserDefaults.standard.set(text, forKey: lastSelectedLabelTextKey)
    }
}

