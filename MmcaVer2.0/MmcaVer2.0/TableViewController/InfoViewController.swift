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
    
    // 테이블 뷰 인스턴스 생성
    let tableView = UITableView()

    // 뷰가 로드된 후 호출되는 메소드
    override func viewDidLoad() {
        super.viewDidLoad()

        // CBCentralManager 초기화 및 델리게이트 설정
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // 테이블 뷰 프레임 설정
        tableView.frame = self.view.bounds
        // 테이블 뷰 크기가 변경될 때 자동으로 크기 조정
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // 테이블 뷰의 델리게이트 및 데이터 소스 설정
        tableView.delegate = self
        tableView.dataSource = self
        
        // 뷰에 테이블 뷰 추가
        self.view.addSubview(tableView)
        
        //갱신 3초
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.centralManager.state == .poweredOn {
                // 블루투스가 켜져 있으면 주변 기기 스캔 다시 시작
                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            } else {
                // 블루투스가 켜져 있지 않은 경우 추가 처리
                print("Bluetooth is not powered on.")
            }
        }
    }
    
    // CBCentralManagerDelegate 프로토콜 메소드 - 블루투스 상태 업데이트 시 호출
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 블루투스가 켜져 있으면 주변 기기 스캔 시작
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // 블루투스가 켜져 있지 않은 경우 추가 처리
        }
    }

    // CBCentralManagerDelegate 프로토콜 메소드 - 주변 기기 발견 시 호출
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, !discoveredPeripherals.contains(peripheral) {
            // 이름이 있는 경우에만 목록에 추가하고 테이블 뷰 갱신
            discoveredPeripherals.append(peripheral)
            rssiValues[peripheral] = RSSI
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
        
        // 이미지뷰 설정
        let imageView = UIImageView(image: UIImage(named: peripheralName))
        imageView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        
        // 텍스트 라벨 설정
        cell.textLabel?.text = peripheralName
        cell.detailTextLabel?.text = "RSSI: \(rssiValue)"
        
        // 이미지뷰를 셀의 왼쪽에 추가
        cell.imageView?.image = UIImage(named: peripheralName)
        
        return cell
    }



    // UITableViewDelegate 프로토콜 메소드 - 셀 선택 시 호출
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: Int) {
        // 셀 선택 시 수행할 작업
    }
    
    // 주변 기기를 RSSI 값에 따라 정렬하여 반환하는 메소드
    func sortedPeripherals() -> [CBPeripheral] {
        return discoveredPeripherals
            .filter { $0.name != nil && !$0.name!.isEmpty }
            .sorted { (peripheral1, peripheral2) -> Bool in
                let rssi1 = rssiValues[peripheral1] ?? 0
                let rssi2 = rssiValues[peripheral2] ?? 0
                return rssi1.intValue > rssi2.intValue // RSSI 값이 큰 순으로 정렬
            }
    }
}
