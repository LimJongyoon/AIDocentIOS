import UIKit

// ChatViewController 클래스는 UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate를 상속받습니다.
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    // 테이블뷰, 메시지 입력 바, 메시지 텍스트뷰, 전송 버튼, 추가 버튼을 선언합니다.
    var tableView: UITableView!
    var messageInputBar: UIView!
    var messageTextView: UITextView!
    var sendButton: UIButton!
    var addButton: UIButton!
    
    // 예시 질문 카테고리들을 저장할 배열을 선언합니다.
    var exampleCategories: [String] = ["작품관련", "작가관련", "시대관련"]
    // 예시 질문들을 저장할 딕셔너리를 선언합니다.
    var exampleQuestions: [String: [String]] = [
        "작품관련": ["작품 1", "작품 2", "작품 3", "작품 4", "작품 5"],
        "작가관련": ["작가 1", "작가 2", "작가 3", "작가 4", "작가 5"],
        "시대관련": ["시대 1", "시대 2", "시대 3", "시대 4", "시대 5"]
    ]
    // 메시지들을 저장할 배열을 선언합니다.
    var messages: [String] = []
    
    // viewDidLoad 메서드는 뷰가 로드되었을 때 호출됩니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI() // UI를 설정합니다.
        setupConstraints() // 제약 조건을 설정합니다.
        setupKeyboardObservers() // 키보드 옵저버를 설정합니다.
        setupTapGesture() // 탭 제스처를 설정합니다.
    }
    
    // UI 설정 메서드입니다.
    func setupUI() {
        setupTableView() // 테이블뷰를 설정합니다.
        setupMessageInputBar() // 메시지 입력 바를 설정합니다.
    }
    
    // 테이블뷰 설정 메서드입니다.
    func setupTableView() {
        tableView = UITableView() // 테이블뷰를 초기화합니다.
        tableView.delegate = self // 테이블뷰의 델리게이트를 설정합니다.
        tableView.dataSource = self // 테이블뷰의 데이터소스를 설정합니다.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") // 셀을 등록합니다.
        tableView.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃을 사용합니다.
        view.addSubview(tableView) // 테이블뷰를 뷰에 추가합니다.
    }
    
    // 메시지 입력 바 설정 메서드입니다.
    func setupMessageInputBar() {
        messageInputBar = UIView() // 메시지 입력 바를 초기화합니다.
        messageInputBar.backgroundColor = .lightGray // 배경색을 설정합니다.
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃을 사용합니다.
        view.addSubview(messageInputBar) // 메시지 입력 바를 뷰에 추가합니다.
        
        messageTextView = UITextView() // 메시지 텍스트뷰를 초기화합니다.
        messageTextView.layer.cornerRadius = 8 // 코너 반경을 설정합니다.
        messageTextView.layer.borderColor = UIColor.gray.cgColor // 테두리 색상을 설정합니다.
        messageTextView.layer.borderWidth = 1 // 테두리 너비를 설정합니다.
        messageTextView.font = UIFont.systemFont(ofSize: 16) // 폰트를 설정합니다.
        messageTextView.delegate = self // 텍스트뷰의 델리게이트를 설정합니다.
        messageTextView.isScrollEnabled = false // 스크롤을 비활성화합니다.
        messageTextView.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃을 사용합니다.
        messageInputBar.addSubview(messageTextView) // 메시지 텍스트뷰를 메시지 입력 바에 추가합니다.
        
        sendButton = UIButton(type: .system) // 전송 버튼을 초기화합니다.
        sendButton.setTitle("Send", for: .normal) // 버튼 타이틀을 설정합니다.
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside) // 버튼 액션을 설정합니다.
        sendButton.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃을 사용합니다.
        messageInputBar.addSubview(sendButton) // 전송 버튼을 메시지 입력 바에 추가합니다.
        
        addButton = UIButton(type: .system) // 추가 버튼을 초기화합니다.
        addButton.setTitle("+", for: .normal) // 버튼 타이틀을 설정합니다.
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside) // 버튼 액션을 설정합니다.
        addButton.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃을 사용합니다.
        messageInputBar.addSubview(addButton) // 추가 버튼을 메시지 입력 바에 추가합니다.
    }
    
    // 제약 조건 설정 메서드입니다.
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            messageTextView.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 8),
            messageTextView.topAnchor.constraint(equalTo: messageInputBar.topAnchor, constant: 8),
            messageTextView.bottomAnchor.constraint(equalTo: messageInputBar.bottomAnchor, constant: -8),
            messageTextView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            
            addButton.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            addButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // 키보드 옵저버 설정 메서드입니다.
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 탭 제스처 설정 메서드입니다.
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 키보드 숨기기 메서드입니다.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 키보드가 보여질 때 호출되는 메서드입니다.
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let bottomSafeAreaInset = view.safeAreaInsets.bottom
        view.frame.origin.y = -(keyboardFrame.height - bottomSafeAreaInset + 80)
    }
    
    // 키보드가 숨겨질 때 호출되는 메서드입니다.
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    // 전송 버튼이 탭되었을 때 호출되는 메서드입니다.
    @objc func sendButtonTapped() {
        guard let userInput = messageTextView.text, !userInput.isEmpty else {
            return
        }
        messages.append("Me: \(userInput)")
        messageTextView.text = ""
        tableView.reloadData()
        scrollToBottom()
        fetchChatGPTResponse(for: userInput)
        dismissKeyboard()
    }
    
    // 추가 버튼이 탭되었을 때 호출되는 메서드입니다.
    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "Example Questions", message: "Select a category", preferredStyle: .actionSheet)
        
        for category in exampleCategories {
            let action = UIAlertAction(title: category, style: .default) { _ in
                self.showQuestions(for: category)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 선택된 카테고리에 따라 세부 질문을 표시하는 메서드입니다.
    func showQuestions(for category: String) {
        let alertController = UIAlertController(title: "Example Questions", message: "Select a question", preferredStyle: .actionSheet)
        
        if let questions = exampleQuestions[category] {
            for question in questions {
                let action = UIAlertAction(title: question, style: .default) { _ in
                    self.messageTextView.text = question
                }
                alertController.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 테이블뷰를 맨 아래로 스크롤하는 메서드입니다.
    func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // 테이블뷰의 섹션당 행 수를 반환하는 메서드입니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // 테이블뷰의 셀을 설정하는 메서드입니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

// ChatViewController의 확장입니다.
extension ChatViewController {
    // ChatGPT 응답을 가져오는 메서드입니다.
    func fetchChatGPTResponse(for input: String) {
        let apiKey = "sk-proj-m3YYfcHWA8ove55jR2MQT3BlbkFJDWwKCmdipiMQPDAY7PJQ"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo-16k",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": input]
            ],
            "temperature": 1,
            "max_tokens": 256,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch let error {
            print("Error in creating request body: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.messages.append("Error: \(error.localizedDescription)")
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.messages.append("Error: No data received")
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = json?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let text = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.messages.append("ChatGPT: \(text.trimmingCharacters(in: .whitespacesAndNewlines))")
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.messages.append("Error: Invalid response format")
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.messages.append("Error: \(error.localizedDescription)")
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
        
        task.resume()
    }
}
