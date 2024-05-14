import UIKit

class PlaceSelectViewController: UIViewController {
    
    
    
    @IBOutlet weak var seoulButton: UIButton!
    @IBOutlet weak var gwacheonButton: UIButton!
    @IBOutlet weak var chungjuButton: UIButton!
    @IBOutlet weak var deoksugungButton: UIButton!
    
    let lastSelectedTitleKey = "lastSelectedTitle"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전에 저장된 마지막 선택한 타이틀 불러오기
        if let lastSelectedTitle = UserDefaults.standard.string(forKey: lastSelectedTitleKey) {
            self.navigationItem.title = lastSelectedTitle
        }
        
        configureButton(seoulButton, withBorderColor: UIColor.black.cgColor)
        configureButton(gwacheonButton, withBorderColor: UIColor.black.cgColor)
        configureButton(chungjuButton, withBorderColor: UIColor.black.cgColor)
        configureButton(deoksugungButton, withBorderColor: UIColor.black.cgColor)
    }
    
    func configureButton(_ button: UIButton, withBorderColor borderColor: CGColor) {
        button.layer.cornerRadius = 10  // 원하는 모서리의 반경 설정
        button.layer.borderWidth = 0   // 테두리 두께 설정
        button.layer.borderColor = borderColor  // 테두리 색상 설정
        button.clipsToBounds = true  // 이 속성은 뷰의 콘텐츠가 뷰의 경계를 넘어가지 않도록 합니다.
    }
    
    @IBAction func seoulButton(_ sender: UIButton) {
        updateTitleWith("서울관")
    }
    
    @IBAction func gwacheonButton(_ sender: UIButton) {
        updateTitleWith("과천관")
    }
    
    @IBAction func chungjuButton(_ sender: UIButton) {
        updateTitleWith("청주관")
    }
    
    @IBAction func deoksugungButton(_ sender: UIButton) {
        updateTitleWith("덕수궁관")
    }
    
    func updateTitleWith(_ title: String) {
        self.navigationItem.title = title
        // 선택한 타이틀을 UserDefaults에 저장
        UserDefaults.standard.set(title, forKey: lastSelectedTitleKey)
    }
    
}
