//
//  PlaceSelectViewController.swift
//  MmcaVer2.0
//
//  Created by Lim on 4/15/24.
//

import UIKit

class PlaceSelectViewController: UIViewController {
    
    
    
    @IBOutlet weak var seoulButton: UIButton!
    @IBOutlet weak var gwacheonButton: UIButton!
    @IBOutlet weak var chungjuButton: UIButton!
    @IBOutlet weak var deoksugungButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButton(seoulButton, withBorderColor: UIColor.black.cgColor)
        configureButton(gwacheonButton, withBorderColor: UIColor.black.cgColor)
        configureButton(chungjuButton, withBorderColor: UIColor.black.cgColor)
        configureButton(deoksugungButton, withBorderColor: UIColor.black.cgColor)
        
        func configureButton(_ button: UIButton, withBorderColor borderColor: CGColor) {
            button.layer.cornerRadius = 10  // 원하는 모서리의 반경 설정
            button.layer.borderWidth = 0   // 테두리 두께 설정
            button.layer.borderColor = borderColor  // 테두리 색상 설정
            button.clipsToBounds = true  // 이 속성은 뷰의 콘텐츠가 뷰의 경계를 넘어가지 않도록 합니다.
        }
        
        
        // Do any additional setup after loading the view.
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
