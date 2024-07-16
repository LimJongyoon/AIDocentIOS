import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var filteredDeviceInfo: [(key: String, value: (title: String, artist: String, size: String, material: String, description: String))] = []
    var deviceInfo: [String: (title: String, artist: String, size: String, material: String, description: String)] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavigationButton()
        
        self.title = "소장품 검색"

        
        // 배경색을 흰색으로 설정
        self.view.backgroundColor = .white
        
        // "작품 검색하기" 레이블 설정
//        let searchLabel = UILabel()
//        searchLabel.text = "작품 검색하기"
//        searchLabel.textAlignment = .left
//        searchLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
//        searchLabel.frame = CGRect(x: 20, y: 100, width: self.view.bounds.width, height: 50)
//        self.view.addSubview(searchLabel)
        
        // 검색 바 설정
        searchBar.frame = CGRect(x: 0, y: 160, width: self.view.bounds.width, height: 50)
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        
        // 테이블 뷰 설정
        tableView.frame = CGRect(x: 0, y: 220, width: self.view.bounds.width, height: self.view.bounds.height - 220)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
        self.view.addSubview(tableView)
        
        // 디바이스 정보를 설정
        deviceInfo = [
            "MMCA001": ("우제류를 위하여(01)", "신현중(1995)", "195x155x45mm", "청동", "신현중(1953- )의 <뿔 있는 우제류를 위하여>(1995)는 인류 문명의 원형에 대한 탐구를 우제류 연작을 통하여 형상화한 작품이다."),
            "MMCA002": ("마두(02)", "권진규(1952)", "31.4×64.2×15.6mm", "안산암", "권진규(권진규, 1922-1973)는 함경남도 함흥에서 태어났다."),
            "MMCA003": ("트리(03)", "권오상(2013)", "274x184x167mm", "종이,에폭시,폴리스티렌", "소조는 무언가를 붙여서 형태를 만드는 것이다."),
            "작품3": ("작품3", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다"),
            "작품4": ("작품4", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다"),
            "작품5": ("작품5", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다"),
            "작품6": ("작품6", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다"),
            "작품7": ("작품7", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다"),
            "작품8": ("작품8", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다")
        ]
        
        // 필터된 데이터 초기화
        filteredDeviceInfo = Array(deviceInfo)
        
        // 화면 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    // 키보드 숨기기 메소드
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func setupCustomNavigationButton() {
        // 홈 버튼만 설정
        let homeButton = createCustomButton(title: "홈", image: "chevron.left", action: #selector(goToHome))
        let customHomeButton = UIBarButtonItem(customView: homeButton)
        
        self.navigationItem.leftBarButtonItem = customHomeButton
    }
    
    func createCustomButton(title: String, image: String?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        if let imageName = image {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // 폰트 종류와 크기 설정
        button.titleLabel?.font = UIFont(name: "San Francisco", size: 17) // 폰트 종류와 크기 설정
        button.setTitleColor(.black, for: .normal) // 버튼 텍스트 색상 설정
        
        return button
    }
    
    // UISearchBarDelegate 메소드 - 검색 바 텍스트가 변경될 때 호출
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    // UISearchBarDelegate 메소드 - 검색 버튼 클릭 시 호출
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // 검색 텍스트에 따라 데이터 필터링
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredDeviceInfo = Array(deviceInfo)
        } else {
            filteredDeviceInfo = deviceInfo.filter {
                $0.value.title.contains(searchText) ||
                $0.value.artist.contains(searchText) ||
                $0.value.size.contains(searchText) ||
                $0.value.material.contains(searchText)
            }
        }
        tableView.reloadData()
    }
    
    // UITableViewDataSource 메소드 - 섹션 수 반환
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableViewDataSource 메소드 - 행 수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDeviceInfo.count
    }
    
    // UITableViewDataSource 메소드 - 셀 반환
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let device = filteredDeviceInfo[indexPath.row]
        
        let highlightedText = searchBar.text ?? ""
        
        // 타이틀에 강조 표시 추가
        let attributedTitle = NSMutableAttributedString(string: device.value.title)
        let titleRange = (device.value.title as NSString).range(of: highlightedText)
        attributedTitle.addAttribute(.backgroundColor, value: UIColor.yellow, range: titleRange)
        
        // 작가에 강조 표시 추가
        let attributedArtist = NSMutableAttributedString(string: device.value.artist)
        let artistRange = (device.value.artist as NSString).range(of: highlightedText)
        attributedArtist.addAttribute(.backgroundColor, value: UIColor.yellow, range: artistRange)
        
        // 셀의 텍스트 라벨 설정
        cell.textLabel?.attributedText = attributedTitle
        
        // 작가, 크기, 재료 정보를 detailTextLabel에 설정
        let detailText = "\(device.value.artist), \(device.value.size), \(device.value.material)"
        let attributedDetailText = NSMutableAttributedString(string: detailText)
        let detailTextRange = (detailText as NSString).range(of: highlightedText)
        attributedDetailText.addAttribute(.backgroundColor, value: UIColor.yellow, range: detailTextRange)
        cell.detailTextLabel?.attributedText = attributedDetailText
        
        // 이미지 파일을 Assets에서 찾기
        var image: UIImage? = UIImage(named: device.key)
        
        // 이미지가 없을 경우, 시스템의 기본 이미지 사용
        if image == nil {
            image = UIImage(named: "EmptyQuestionMark")
        }
        
        // 셀의 왼쪽에 이미지뷰 추가
        cell.imageView?.image = image
        
        return cell
    }
    
    // UITableViewDelegate 메소드 - 셀 높이 반환
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // UITableViewDelegate 메소드 - 셀 선택 시 호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        let selectedDevice = filteredDeviceInfo[indexPath.row]
        
        // 선택된 디바이스의 정보를 DetailViewController에 전달
        detailVC.peripheral = nil
        detailVC.rssiValue = nil
        detailVC.deviceInfo = deviceInfo // 이 부분을 선택된 디바이스의 정보로 설정
        detailVC.selectedDeviceInfo = selectedDevice.value
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    @objc func goToHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
