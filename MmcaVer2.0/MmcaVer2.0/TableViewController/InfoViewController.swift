import UIKit
import CoreBluetooth

class InfoViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []
    var rssiValues: [CBPeripheral: NSNumber] = [:]
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // 블루투스가 켜지지 않은 경우 추가 처리
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, !discoveredPeripherals.contains(peripheral) {
            // 이름이 있는 경우에만 목록에 추가
            discoveredPeripherals.append(peripheral)
            rssiValues[peripheral] = RSSI
            tableView.reloadData() // 테이블뷰 갱신
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 섹션 수는 하나
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.filter { $0.name != nil && $0.name!.isEmpty == false }.count
        // 이름이 있는 주변 기기 수만 반환
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let namedPeripherals = discoveredPeripherals.filter { $0.name != nil && !$0.name!.isEmpty }
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell") ?? UITableViewCell(style: .default, reuseIdentifier: "BLECell")
        
        let peripheral = namedPeripherals[indexPath.row]
        
        let peripheralName = peripheral.name ?? ""
        let rssiValue = rssiValues[peripheral] ?? 0
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        imageView.image = UIImage(named: peripheralName) ?? UIImage()
        
        cell.contentView.addSubview(imageView)
        
        cell.textLabel?.text = peripheralName
        cell.detailTextLabel?.text = "RSSI: \(rssiValue)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: Int) {
        // 셀 선택 시 수행할 작업
    }
    
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
