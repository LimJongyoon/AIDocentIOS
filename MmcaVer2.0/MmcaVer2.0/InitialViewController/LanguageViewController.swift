//
//  LanguageViewController.swift
//  MmcaVer2.0
//
//  Created by Lim on 4/15/24.
//

import UIKit

class LanguageViewController: UIViewController {

    
    
    @IBOutlet weak var koreaButton: UIButton!
    @IBOutlet weak var USAButton: UIButton!
    @IBOutlet weak var japanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
