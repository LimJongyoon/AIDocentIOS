import UIKit
import CoreBluetooth
//import SQLite3 // SQLite.swift 라이브러리를 임포트합니다.


// InfoViewController 클래스 선언
class InfoViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    // CBCentralManager 인스턴스 생성
    var centralManager: CBCentralManager!
    // 스캔된 주변 기기 목록을 저장하는 배열
    var discoveredPeripherals: [CBPeripheral] = []
    // 각 주변 기기의 RSSI 값을 저장하는 딕셔너리
    var rssiValues: [CBPeripheral: NSNumber] = [:]
    
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
        titleLabel.frame = CGRect(x: 20, y: 100, width: self.view.bounds.width, height: 100)  // 레이블의 위치와 크기 설정
        // x: 0, y: 0 시작 지점은 뷰의 상단 왼쪽 모서리
        // width: 뷰의 전체 너비와 동일하게 설정하여 화면 가로를 꽉 채움
        // height: 300으로 설정하여 높이가 300픽셀이 됨
        self.view.addSubview(titleLabel)  // 생성된 레이블을 뷰의 서브뷰로 추가

        // 테이블 뷰 프레임 설정
        tableView.frame = CGRect(x: 0, y: 200, width: self.view.bounds.width, height: self.view.bounds.height - 300)
        // x: 0, y: 200 시작 지점은 뷰의 상단에서부터 200픽셀 아래
        // 이는 titleLabel의 하단 바로 아래에서 시작
        // width: 뷰의 전체 너비와 동일하게 설정하여 화면 가로를 꽉 채움
        // height: 전체 뷰 높이에서 300픽셀 빼기 (titleLabel의 높이만큼)
        // 이 설정으로 테이블 뷰는 화면의 나머지 높이를 차지함
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // 뷰 크기가 변경될 때 (예: 기기 회전 시) 테이블 뷰의 너비와 높이가 자동으로 조정됨
        tableView.delegate = self  // 테이블 뷰의 델리게이트 설정
        tableView.dataSource = self  // 테이블 뷰의 데이터 소스 설정

        // 뷰에 테이블 뷰 추가
        self.view.addSubview(tableView)
        
    }
    
    // CBCentralManagerDelegate 프로토콜 메소드 - 블루투스 상태 업데이트 시 호출
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 블루투스가 켜져 있으면 주변 기기 스캔 시작
            // 중복을 허용 시켜서 빈번한 업데이트 발생
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true] as [String: Any]
            central.scanForPeripherals(withServices: nil, options: options)        }
        else {
                // 블루투스가 켜져 있지 않은 경우 추가 처리
            }
    }
    
    // CBCentralManagerDelegate 프로토콜 메소드 - 주변 기기 발견 시 호출
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            // 발견된 기기가 기존에 없는 경우에만 추가
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
        return discoveredPeripherals.filter { $0.name != nil && !$0.name!.isEmpty }.count
    }
    
    // UITableViewDataSource 프로토콜 메소드 - 테이블 뷰 셀 반환
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 이름이 있는 주변 기기만 필터링
        let namedPeripherals = discoveredPeripherals.filter { $0.name != nil && !$0.name!.isEmpty }
        // 재사용 가능한 셀 가져오거나 없으면 새로운 셀 생성
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "BLECell")
        
        let peripheral = namedPeripherals[indexPath.row]
        
        // 주변 기기의 이름 및 RSSI 값 설정
        let peripheralName = peripheral.name ?? ""
        let rssiValue = rssiValues[peripheral] ?? 0
        
        // 이미지 파일을 Assets에서 찾기
        var image: UIImage? = UIImage(named: peripheralName)
        
        // 이미지가 없을 경우, 시스템의 기본 이미지 사용
        if image == nil {
            image = UIImage(named: "EmptyQuestionMark") // 빈 이미지에 적합한 이미지
        }
        
        // 이미지뷰 설정
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true // 이미지뷰 내의 콘텐츠를 이미지뷰 크기에 맞춰 자름
        
        
        // 셀의 왼쪽에 이미지뷰 추가
        cell.imageView?.image = image
        
        
        // 텍스트 라벨 설정
        cell.textLabel?.text = peripheralName
        cell.detailTextLabel?.text = "RSSI: \(rssiValue)"
        
        
        return cell
    }
    
    
    private func tableView(_ tableView: UITableView, heightForRowAt indexPath: Int) -> CGFloat {
        return 100 // 셀 높이 설정
    }
    
    
    // UITableViewDelegate 프로토콜 메소드 - 셀 선택 시 호출
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: Int) {
        // 셀 선택 시 수행할 작업
    }
    
}

/*
 비콘의 정보를 읽어와서 database의 id 값과 비교한다음
 비콘의 이름과 database의 id 값이 같으면
 이름 작가 년도 이미지를 가져오는 방식으로
 id     | name  | artist | year  |     imagePath   |
 MMCA001| 유제류  | 신현중   | 1980  |~/image/ujr.png  |
 
 */
