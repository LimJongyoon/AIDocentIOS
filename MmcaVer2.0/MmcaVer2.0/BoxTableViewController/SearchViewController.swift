import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let tableView = UITableView()
    let searchBar = UISearchBar()
    var filteredDeviceInfo: [String: (title: String, artist: String, size: String, material: String, description: String)] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "작품 검색하기"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.frame = CGRect(x: 20, y: 100, width: self.view.bounds.width, height: 50)
        view.addSubview(titleLabel)
        
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 160, width: self.view.bounds.width, height: 50)
        view.addSubview(searchBar)
        
        tableView.frame = CGRect(x: 0, y: 220, width: self.view.bounds.width, height: self.view.bounds.height - 220)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
        view.addSubview(tableView)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredDeviceInfo.removeAll()
            tableView.reloadData()
            return
        }
        
        filteredDeviceInfo = InfoViewController().deviceInfo.filter { key, value in
            return key.contains(searchText) ||
                   value.title.contains(searchText) ||
                   value.artist.contains(searchText) ||
                   value.description.contains(searchText)
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDeviceInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        let key = Array(filteredDeviceInfo.keys)[indexPath.row]
        let info = filteredDeviceInfo[key]!
        
        cell.textLabel?.text = info.title
        cell.detailTextLabel?.text = "\(info.artist), \(info.size), \(info.material)"
        
        var image: UIImage? = UIImage(named: key)
        
        if image == nil {
            image = UIImage(named: "EmptyQuestionMark")
        }
        
        cell.imageView?.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        
        let key = Array(filteredDeviceInfo.keys)[indexPath.row]
        detailVC.deviceInfo = [key: filteredDeviceInfo[key]!]
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
