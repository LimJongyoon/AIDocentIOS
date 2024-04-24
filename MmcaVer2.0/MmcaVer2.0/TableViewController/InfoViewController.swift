import UIKit
import CoreBluetooth

// 'UITableViewDataSource' 및 'UITableViewDelegate' 프로토콜 준수
class InfoViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    var centralManager: CBCentralManager! // 블루투스 센트럴 매니저 선언
    var discoveredPeripherals: [CBPeripheral] = [] // 스캔된 주변 기기 목록
    var rssiValues: [CBPeripheral: NSNumber] = [:] // 각 기기의 RSSI 값을 저장
    
    let tableView = UITableView() // 테이블뷰 선언
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil) // 센트럴 매니저 초기화
        
        // 테이블뷰의 위치와 크기 설정
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self // 테이블뷰 델리게이트 설정
        tableView.dataSource = self // 테이블뷰 데이터 소스 설정
        
        // 테이블뷰에 셀을 재사용할 수 있도록 식별자 등록
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BLECell")
        
        self.view.addSubview(tableView) // 테이블뷰를 현재 뷰에 추가
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // 추가 처리
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
        rssiValues[peripheral] = RSSI
        tableView.reloadData() // 테이블뷰 갱신
    }
    
    // 'UITableViewDataSource' 프로토콜 필수 메소드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count // 섹션의 행 수
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell", for: indexPath)
        let peripheral = discoveredPeripherals[indexPath.row] // 해당 인덱스의 주변 기기
        
        let peripheralName = peripheral.name ?? ""
        let rssiValue = rssiValues[peripheral] ?? 0
        
        // 이미지뷰 생성 및 추가
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        imageView.image = UIImage(named: peripheralName) ?? UIImage()
        
        // 셀에 추가
        cell.contentView.addSubview(imageView)
        
        cell.textLabel?.text = peripheralName
        cell.detailTextLabel?.text = "RSSI: \(rssiValue)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 선택 시 동작 구현
    }
    func sortedPeripherals() -> [CBPeripheral] {
        return discoveredPeripherals.sorted { (peripheral1, peripheral2) -> Bool in
            let rssi1 = rssiValues[peripheral1] ?? 0
            let rssi2 = rssiValues[peripheral2] ?? 0
            return rssi1.intValue > rssi2.intValue // RSSI 값이 큰 순으로 정렬
        }
    }
}
