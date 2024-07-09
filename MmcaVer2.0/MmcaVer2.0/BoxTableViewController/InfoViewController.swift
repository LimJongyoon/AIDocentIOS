import UIKit
import CoreBluetooth

// InfoViewController 클래스 선언
class InfoViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    // CBCentralManager 인스턴스 생성
    var centralManager: CBCentralManager!
    // 스캔된 주변 기기 목록을 저장하는 배열
    var discoveredPeripherals: [CBPeripheral] = []
    // 각 주변 기기의 RSSI 값을 저장하는 딕셔너리
    var rssiValues: [CBPeripheral: NSNumber] = [:]
    
    // 허용된 디바이스 이름을 정의한 배열
    let allowedDeviceNames: [String] = ["MMCA001", "MMCA002", "MMCA003", "우제류"]
    
    // 디바이스 정보 데이터 구조
    public let deviceInfo: [String: (title: String, artist: String, size: String, material: String, description: String)] = [
        "MMCA001": ("우제류를 위하여(01)",
                    "신현중(1995)",
                    "195x155x45mm",
                    "청동",
                    "신현중(1953- )의 <뿔 있는 우제류를 위하여>(1995)는 인류 문명의 원형에 대한 탐구를 우제류 연작을 통하여 형상화한 작품이다. 작가는 인류가 살기 좋은 조건이 되게끔 인간에게 고기와 젖, 뿔과 털 그리고 노동력까지 제공해 온 우제류 동물 중에서, 사슴, 산양, 영양, 가젤, 임팔라 등 7마리를 작품의 주제로 하고 있다. 이 작품은 오늘날 우제류 동물들의 인류를 위한 헌신에 감사하는 마음으로 제작된 것으로, 2년여에 걸쳐 나무로 원형을 만든 후 청동 주물로 뜨고 군집형태로 설치하여 더욱 현장감있게 주제를 전달하고 있다."),
        "MMCA002": ("마두(02)",
                    "권진규(1952)",
                    "31.4×64.2×15.6mm",
                    "안산암",
                    "권진규(權鎭圭, 1922-1973)는 함경남도 함흥에서 태어났다. 1947-1948년경에 이쾌대가 운영하는 성북회화연구소에서 미술을 배웠으며 속리산 법주사 대불 제작에 참가하였다. 1948년에 일본으로 건너간 후 1949년 9월에 무사시노미술대학(武蔵野美術大学) 조각과에 입학하여 시미즈 다카시(淸水多嘉示, 1897-1981)를 사사했다. 1953년부터 1955년까지 니카텐(二科展, 이과전)에 말을 주제로 한 작품을 지속적으로 출품하였고, 《제38회 니카텐》(1953)에서 특대(特待)를 수상하였다. 1959년에 귀국 후 동선동에 정착하여 작업 활동을 시작하였다. 첫 개인전 《권진규 조각전》(1965)을 비롯하여 한국과 일본을 오가며 활동하였다. 권진규는 말, 여인의 누드, 인물 흉상과 두상 등을 소재로 했으며, 주로 석재, 테라코타(terra-cotta), 건칠, 목재 등의 재료를 사용하여 환조와 부조 형태의 작품을 제작했다."),
        "MMCA003": ("트리(03)",
                    "권오상(2013)",
                    "274x184x167mm",
                    "종이,에폭시,폴리스티렌",
                    "소조는 무언가를 붙여서 형태를 만드는 것이다. 따라서 사진을 붙여서 형태를 만드는 그의 ‘사진조각’도 어떤 의미에서는 소조에 해당된다. 2010년대에 들어 그는 사진조각에 여러 물건을 붙여 복잡한 구성을 만드는데, 이것도 소조의 개념이라고 볼 수 있다. 더불어 그러한 물건들은 모두 부피가 있는 ‘덩어리’들이다. 사실 조각에 있어 중요한 요소 중 하나가 덩어리이다.위와 같은 소조와 덩어리에 대한 그의 생각이 가장 잘 반영된 작품이 바로 <트리>이다. <트리>는 크리스마스트리를 소재로 한 작업이다. 보통 크리스마스트리에는 전등, 종, 공, 장식품 등 많은 소품들이 붙어 있다. 권오상은 이 소품들을 대신해 다른 물건들을 트리에 붙였다. 그 물건 중에는 예전 작업에 등장했던 물건과 사람도 있다. 작가는 로댕의 <지옥의 문>에서 바글거리는 것을 생각하며 이 작업을 만들었다고 한다."),
        "우제류": ("유유유", "작가4(2023)", "000x000mm", "재료4", "설명입니다 설명입니다 설명입니다 설명입니다 설명입니다")
    ]
    
    // 테이블 뷰 인스턴스 생성
    let tableView = UITableView()
    
    // 뷰가 로드된 후 호출되는 메소드
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CBCentralManager 초기화 및 델리게이트 설정
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // 페이지 타이틀을 위한 레이블 생성
        let titleLabel = UILabel()
        titleLabel.text = "주변에 근접한 작품"  // 레이블에 표시될 텍스트 설정
        titleLabel.textAlignment = .left   // 텍스트 정렬을 왼쪽으로 설정
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold) // 폰트 크기 30, 볼드체로 설정
        titleLabel.frame = CGRect(x: 20, y: 100, width: self.view.bounds.width, height: 150)  // 레이블의 위치와 크기 설정
        self.view.addSubview(titleLabel)  // 생성된 레이블을 뷰의 서브뷰로 추가

        // 테이블 뷰 프레임 설정
        tableView.frame = CGRect(x: 0, y: 200, width: self.view.bounds.width, height: self.view.bounds.height - 300)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self  // 테이블 뷰의 델리게이트 설정
        tableView.dataSource = self  // 테이블 뷰의 데이터 소스 설정
        self.view.addSubview(tableView) // 뷰에 테이블 뷰 추가
    }
    
    // CBCentralManagerDelegate 프로토콜 메소드 - 블루투스 상태 업데이트 시 호출
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 블루투스가 켜져 있으면 주변 기기 스캔 시작
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true] as [String: Any]
            central.scanForPeripherals(withServices: nil, options: options)
        } else {
            // 블루투스가 켜져 있지 않은 경우 추가 처리
        }
    }
    
    // CBCentralManagerDelegate 프로토콜 메소드 - 주변 기기 발견 시 호출
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name, !peripheralName.isEmpty else { return }
        
        // 발견된 기기가 허용된 이름 목록에 있는 경우에만 추가
        if allowedDeviceNames.contains(peripheralName) {
            if !discoveredPeripherals.contains(peripheral) {
                discoveredPeripherals.append(peripheral)
            }
            // RSSI 값 갱신
            rssiValues[peripheral] = RSSI
            // 주변 기기를 RSSI 값에 따라 정렬
            discoveredPeripherals.sort { (peripheral1, peripheral2) -> Bool in
                let rssi1 = rssiValues[peripheral1] ?? 0
                let rssi2 = rssiValues[peripheral2] ?? 0
                return rssi1.intValue > rssi2.intValue // RSSI 값이 큰 순으로 정렬
            }
            // 테이블 뷰 갱신
            tableView.reloadData()
        }
    }
    
    // UITableViewDataSource 프로토콜 메소드 - 섹션 수 반환
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableViewDataSource 프로토콜 메소드 - 주변 기기 수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 허용된 이름을 가진 주변 기기의 수를 반환
        return discoveredPeripherals.filter { allowedDeviceNames.contains($0.name ?? "") }.count
    }
    
    // UITableViewDataSource 프로토콜 메소드 - 테이블 뷰 셀 반환
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 이름이 있는 주변 기기만 필터링
        let namedPeripherals = discoveredPeripherals.filter { allowedDeviceNames.contains($0.name ?? "") }
        
        // 재사용 가능한 셀 가져오거나 없으면 새로운 셀 생성
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "BLECell")
        
        // 현재 인덱스에 해당하는 주변 기기 가져오기
        let peripheral = namedPeripherals[indexPath.row]
        
        // 주변 기기의 이름을 가져옴
        let peripheralName = peripheral.name ?? ""
        
        // 디바이스 정보에 해당 주변 기기의 정보가 있는지 확인
        if let info = deviceInfo[peripheralName] {
            // 정보가 있는 경우 셀의 텍스트 라벨과 세부 텍스트 라벨 설정
            cell.textLabel?.text = info.title // 작품의 제목 설정
            cell.detailTextLabel?.text = "\(info.artist), \(info.size), \(info.material)" // 작가, 크기, 재질 정보를 설정
        } else {
            // 정보가 없는 경우 기본 텍스트 설정
            cell.textLabel?.text = peripheralName // 주변 기기의 이름 설정
            cell.detailTextLabel?.text = "RSSI: \(rssiValues[peripheral] ?? 0)" // RSSI 값을 표시
        }
        
        // 이미지 파일을 Assets에서 찾기
        var image: UIImage? = UIImage(named: peripheralName)
        
        // 이미지가 없을 경우, 시스템의 기본 이미지 사용
        if image == nil {
            image = UIImage(named: "EmptyQuestionMark") // 빈 이미지에 적합한 이미지
        }
        
        // 셀의 왼쪽에 이미지뷰 추가
        cell.imageView?.image = image
        
        return cell
    }
    
    // UITableViewDelegate 프로토콜 메소드 - 셀 높이 반환
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // 셀 높이 설정
    }
    
    // UITableViewDelegate 프로토콜 메소드 - 셀 선택 시 호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // DetailViewController 인스턴스 생성
        let detailVC = DetailViewController()
        
        // 선택된 주변 기기 정보 전달
        let namedPeripherals = discoveredPeripherals.filter { allowedDeviceNames.contains($0.name ?? "") }
        let selectedPeripheral = namedPeripherals[indexPath.row]
        detailVC.peripheral = selectedPeripheral // 선택된 주변 기기를 DetailViewController에 전달
        detailVC.rssiValue = rssiValues[selectedPeripheral] ?? 0 // 선택된 주변 기기의 RSSI 값을 전달
        detailVC.deviceInfo = deviceInfo // deviceInfo 딕셔너리를 DetailViewController로 전달
        
        // DetailViewController로 전환
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
