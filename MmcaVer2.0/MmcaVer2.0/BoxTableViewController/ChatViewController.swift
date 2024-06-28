import UIKit
import AVFoundation // 음성 합성을 위한 프레임워크

// ChatViewController 클래스는 UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate를 상속받습니다.
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, AVSpeechSynthesizerDelegate {
    
    // 테이블뷰, 메시지 입력 바, 메시지 텍스트뷰, 전송 버튼, 추가 버튼을 선언합니다.
    var tableView: UITableView!
    var messageInputBar: UIView!
    var messageTextView: UITextView!
    var sendButton: UIButton!
    var addButton: UIButton!
    
    // 자동완성 테이블뷰와 관련된 변수들
    var autocompleteTableView: UITableView!
    var autocompleteResults: [String] = []
    
    // 예시 질문 카테고리들을 저장할 배열을 선언합니다.
    var exampleCategories: [String] = ["작품관련", "작가관련", "시대관련"]
    // 예시 질문들을 저장할 딕셔너리를 선언합니다.
    var exampleQuestions: [String: [String]] = [
        "작품관련": [
            "관련된 작품에는 어떤 것들이 있나요?",
            "작품의 주제가 무엇인가요?",
            "비슷한 작품은 무엇이 있나요?",
            "작품에서 사용된 기법은 무엇인가요?",
            "작품이 전달하고자 하는 메시지는 무엇인가요?"
        ],
        "작가관련": [
            "작가의 다른 대표작은 무엇인가요?",
            "작가의 생애는 어떠했나요?",
            "작가가 이 작품을 만든 동기는 무엇인가요?",
            "작가의 주요 영향력은 무엇인가요?",
            "작가가 속한 예술 사조는 무엇인가요?"
        ],
        "시대관련": [
            "작품이 만들어진 시대는 어떤가요?",
            "시대상과 관련된 작품인가요?",
            "그 시대의 주요 예술적 흐름은 무엇인가요?",
            "그 시대의 사회적 배경은 어떠했나요?",
            "그 시대의 다른 주요 작품들은 무엇인가요?"
        ]
    ]
    // 모든 예시 질문들을 하나의 배열로 합칩니다.
    var allExampleQuestions: [String] {
        return exampleQuestions.flatMap { $0.value }
    }
    
    // 메시지들을 저장할 배열을 선언합니다.
    var messages: [String] = []
    
    // 음성 합성을 위한 변수 선언
    var speechSynthesizer = AVSpeechSynthesizer()
    var isSpeaking = false // 현재 음성 재생 여부를 저장하는 변수
    var lastSpokenMessage: String? // 마지막으로 읽었던 메시지를 저장하는 변수
    
    // viewDidLoad 메서드는 뷰가 로드되었을 때 호출됩니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // 뷰의 배경색을 흰색으로 설정합니다.
        setupUI() // UI를 설정합니다.
        setupConstraints() // 제약 조건을 설정합니다.
        setupKeyboardObservers() // 키보드 옵저버를 설정합니다.
        setupTapGesture() // 탭 제스처를 설정합니다.
        speechSynthesizer.delegate = self // 음성 합성기의 델리게이트를 설정합니다.
    }
    
    // UI 설정 메서드입니다.
    func setupUI() {
        setupTableView() // 테이블뷰를 설정합니다.
        setupMessageInputBar() // 메시지 입력 바를 설정합니다.
        setupAutocompleteTableView() // 자동완성 테이블뷰를 설정합니다.
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
    
    // 자동완성 테이블뷰 설정 메서드입니다.
    func setupAutocompleteTableView() {
        autocompleteTableView = UITableView() // 자동완성 테이블뷰를 초기화합니다.
        autocompleteTableView.delegate = self // 테이블뷰의 델리게이트를 설정합니다.
        autocompleteTableView.dataSource = self // 테이블뷰의 데이터소스를 설정합니다.
        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutocompleteCell") // 셀을 등록합니다.
        autocompleteTableView.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃을 사용합니다.
        view.addSubview(autocompleteTableView) // 자동완성 테이블뷰를 뷰에 추가합니다.
        
        // 자동완성 테이블뷰의 제약 조건을 설정합니다.
        NSLayoutConstraint.activate([
            autocompleteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            autocompleteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            autocompleteTableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            autocompleteTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        autocompleteTableView.isHidden = true // 초기에는 자동완성 테이블뷰를 숨깁니다.
    }
    
    // 제약 조건 설정 메서드입니다.
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor), // 테이블뷰의 상단을 뷰의 상단에 맞춥니다.
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 테이블뷰의 왼쪽을 뷰의 왼쪽에 맞춥니다.
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor), // 테이블뷰의 오른쪽을 뷰의 오른쪽에 맞춥니다.
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor), // 테이블뷰의 하단을 메시지 입력 바의 상단에 맞춥니다.
            
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 메시지 입력 바의 왼쪽을 뷰의 왼쪽에 맞춥니다.
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor), // 메시지 입력 바의 오른쪽을 뷰의 오른쪽에 맞춥니다.
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), // 메시지 입력 바의 하단을 뷰의 안전 영역 하단에 맞춥니다.
            
            messageTextView.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 8), // 메시지 텍스트뷰의 왼쪽을 메시지 입력 바의 왼쪽에 여유 공간을 두고 맞춥니다.
            messageTextView.topAnchor.constraint(equalTo: messageInputBar.topAnchor, constant: 8), // 메시지 텍스트뷰의 상단을 메시지 입력 바의 상단에 여유 공간을 두고 맞춥니다.
            messageTextView.bottomAnchor.constraint(equalTo: messageInputBar.bottomAnchor, constant: -8), // 메시지 텍스트뷰의 하단을 메시지 입력 바의 하단에 여유 공간을 두고 맞춥니다.
            messageTextView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8), // 메시지 텍스트뷰의 오른쪽을 추가 버튼의 왼쪽에 여유 공간을 두고 맞춥니다.
            
            addButton.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8), // 추가 버튼의 오른쪽을 전송 버튼의 왼쪽에 여유 공간을 두고 맞춥니다.
            addButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor), // 추가 버튼을 메시지 입력 바의 수직 중앙에 맞춥니다.
            addButton.widthAnchor.constraint(equalToConstant: 40), // 추가 버튼의 너비를 40으로 설정합니다.
            addButton.heightAnchor.constraint(equalToConstant: 40), // 추가 버튼의 높이를 40으로 설정합니다.
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -8), // 전송 버튼의 오른쪽을 메시지 입력 바의 오른쪽에 여유 공간을 두고 맞춥니다.
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor), // 전송 버튼을 메시지 입력 바의 수직 중앙에 맞춥니다.
            sendButton.widthAnchor.constraint(equalToConstant: 60), // 전송 버튼의 너비를 60으로 설정합니다.
            sendButton.heightAnchor.constraint(equalToConstant: 40) // 전송 버튼의 높이를 40으로 설정합니다.
        ])
    }
    
    // 키보드 옵저버 설정 메서드입니다.
    func setupKeyboardObservers() {
        // 키보드가 보여질 때와 숨겨질 때 호출될 메서드를 설정합니다.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 탭 제스처 설정 메서드입니다.
    func setupTapGesture() {
        // 뷰를 탭했을 때 키보드를 숨기는 제스처를 추가합니다.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 키보드 숨기기 메서드입니다.
    @objc func dismissKeyboard() {
        view.endEditing(true) // 현재 포커스를 잃고 키보드를 숨깁니다.
    }
    
    // 키보드가 보여질 때 호출되는 메서드입니다.
    @objc func keyboardWillShow(notification: NSNotification) {
        // 키보드의 높이를 가져와서 뷰를 올립니다.
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let bottomSafeAreaInset = view.safeAreaInsets.bottom
        view.frame.origin.y = -(keyboardFrame.height - bottomSafeAreaInset + 34)
    }
    
    // 키보드가 숨겨질 때 호출되는 메서드입니다.
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0 // 뷰를 원래 위치로 되돌립니다.
    }
    
    // 전송 버튼이 탭되었을 때 호출되는 메서드입니다.
    @objc func sendButtonTapped() {
        guard let userInput = messageTextView.text, !userInput.isEmpty else {
            return
        }
        // 사용자가 입력한 메시지를 배열에 추가합니다.
        messages.append("Me: \(userInput)")
        messageTextView.text = "" // 메시지 입력란을 비웁니다.
        tableView.reloadData() // 테이블뷰를 리로드합니다.
        scrollToBottom() // 테이블뷰를 맨 아래로 스크롤합니다.
        fetchChatGPTResponse(for: userInput) // ChatGPT 응답을 가져옵니다.
        dismissKeyboard() // 키보드를 숨깁니다.
    }
    
    // 추가 버튼이 탭되었을 때 호출되는 메서드입니다.
    @objc func addButtonTapped() {
        // 예시 질문을 선택할 수 있는 액션 시트를 표시합니다.
        let alertController = UIAlertController(title: "Example Questions", message: "Select a category", preferredStyle: .actionSheet)
        
        for category in exampleCategories {
            let action = UIAlertAction(title: category, style: .default) { _ in
                self.showQuestions(for: category) // 선택된 카테고리에 대한 질문을 표시합니다.
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
                    self.messageTextView.text = question // 선택된 질문을 메시지 입력란에 입력합니다.
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
        if tableView == autocompleteTableView {
            return autocompleteResults.count // 자동완성 테이블뷰의 행 수를 반환합니다.
        }
        return messages.count // 메시지 테이블뷰의 행 수를 반환합니다.
    }
    
    // 테이블뷰의 셀을 설정하는 메서드입니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == autocompleteTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteCell", for: indexPath)
            cell.textLabel?.text = autocompleteResults[indexPath.row] // 자동완성 결과를 셀에 설정합니다.
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row] // 메시지를 셀에 설정합니다.
        cell.textLabel?.numberOfLines = 0 // 셀의 텍스트 라인을 제한하지 않습니다.
        return cell
    }
    
    // 테이블뷰의 셀이 선택되었을 때 호출되는 메서드입니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == autocompleteTableView {
            if indexPath.row < autocompleteResults.count {
                let selectedText = autocompleteResults[indexPath.row] // 선택된 자동완성 텍스트를 가져옵니다.
                messageTextView.text = selectedText // 메시지 입력란에 자동완성 텍스트를 입력합니다.
                autocompleteResults.removeAll() // 자동완성 결과를 초기화합니다.
                autocompleteTableView.reloadData() // 자동완성 테이블뷰를 리로드합니다.
                autocompleteTableView.isHidden = true // 자동완성 테이블뷰를 숨깁니다.
            }
        } else {
            let message = messages[indexPath.row]
            if message.starts(with: "ChatGPT: ") {
                let content = String(message.dropFirst("ChatGPT: ".count))
                if isSpeaking && lastSpokenMessage == content {
                    speechSynthesizer.stopSpeaking(at: .immediate) // 현재 음성을 즉시 멈춥니다.
                    isSpeaking = false
                } else {
                    speakText(content) // 선택된 메시지를 음성으로 읽어줍니다.
                    lastSpokenMessage = content
                }
            }
        }
    }
    
    // 텍스트뷰의 텍스트가 변경될 때 호출되는 메서드입니다.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 현재 텍스트뷰의 텍스트를 대체할 텍스트로 업데이트합니다.
        let currentText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if currentText.isEmpty {
            autocompleteResults.removeAll() // 자동완성 결과를 초기화합니다.
            autocompleteTableView.reloadData() // 자동완성 테이블뷰를 리로드합니다.
            autocompleteTableView.isHidden = true // 자동완성 테이블뷰를 숨깁니다.
        } else {
            filterAutocompleteResults(with: currentText) // 자동완성 결과를 필터링합니다.
        }
        return true
    }
    
    // 자동완성 결과를 필터링하는 메서드입니다.
    func filterAutocompleteResults(with query: String) {
        // 예시 질문들 중 쿼리와 일치하는 결과를 필터링합니다.
        autocompleteResults = allExampleQuestions.filter { $0.lowercased().contains(query.lowercased()) || $0.hasPrefix(query) || containsConsonant(query: query, word: $0) }
        autocompleteTableView.reloadData() // 자동완성 테이블뷰를 리로드합니다.
        autocompleteTableView.isHidden = autocompleteResults.isEmpty // 자동완성 결과가 없으면 테이블뷰를 숨깁니다.
    }
    
    // 초성 검색을 지원하는 메서드입니다.
    func containsConsonant(query: String, word: String) -> Bool {
        let consonants = "ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ"
        let wordConsonants = word.map { getInitialConsonant(of: $0) }.joined()
        return wordConsonants.contains(query)
    }
    
    // 초성을 가져오는 메서드입니다.
    func getInitialConsonant(of character: Character) -> String {
        let unicodeScalar = character.unicodeScalars.first!.value
        if unicodeScalar >= 0xAC00 && unicodeScalar <= 0xD7A3 {
            let index = (unicodeScalar - 0xAC00) / 28 / 21
            let consonants = "ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ"
            let consonantIndex = consonants.index(consonants.startIndex, offsetBy: Int(index))
            return String(consonants[consonantIndex])
        } else {
            return String(character)
        }
    }
}

// ChatViewController의 확장입니다.
extension ChatViewController {
    // ChatGPT 응답을 가져오는 메서드입니다.
    func fetchChatGPTResponse(for input: String) {
        let apiKey = "sk-proj-m3YYfcHWA8ove55jR2MQT3BlbkFJDWwKCmdipiMQPDAY7PJQ" // API 키를 설정합니다.
        let url = URL(string: "https://api.openai.com/v1/chat/completions")! // API URL을 설정합니다.
        
        var request = URLRequest(url: url) // URL 요청을 초기화합니다.
        request.httpMethod = "POST" // HTTP 메서드를 POST로 설정합니다.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // 요청 헤더에 Content-Type을 설정합니다.
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // 요청 헤더에 인증 토큰을 설정합니다.
        
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
        ] // 요청 본문에 포함될 파라미터를 설정합니다.
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: []) // 요청 본문을 JSON 데이터로 변환합니다.
        } catch let error {
            print("Error in creating request body: \(error.localizedDescription)") // 변환 중 오류가 발생하면 출력합니다.
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.messages.append("Error: \(error.localizedDescription)") // 오류 메시지를 추가합니다.
                    self.tableView.reloadData() // 테이블뷰를 리로드합니다.
                    self.scrollToBottom() // 테이블뷰를 맨 아래로 스크롤합니다.
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.messages.append("Error: No data received") // 데이터가 없으면 오류 메시지를 추가합니다.
                    self.tableView.reloadData() // 테이블뷰를 리로드합니다.
                    self.scrollToBottom() // 테이블뷰를 맨 아래로 스크롤합니다.
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = json?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let text = message["content"] as? String {
                    DispatchQueue.main.async {
                        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.messages.append("ChatGPT: \(trimmedText)") // ChatGPT 응답을 메시지 배열에 추가합니다.
                        self.tableView.reloadData() // 테이블뷰를 리로드합니다.
                        self.scrollToBottom() // 테이블뷰를 맨 아래로 스크롤합니다.
                        self.speakText(trimmedText) // 응답을 음성으로 읽어줍니다.
                    }
                } else {
                    DispatchQueue.main.async {
                        self.messages.append("Error: Invalid response format") // 응답 형식이 잘못된 경우 오류 메시지를 추가합니다.
                        self.tableView.reloadData() // 테이블뷰를 리로드합니다.
                        self.scrollToBottom() // 테이블뷰를 맨 아래로 스크롤합니다.
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.messages.append("Error: \(error.localizedDescription)") // JSON 파싱 중 오류가 발생하면 출력합니다.
                    self.tableView.reloadData() // 테이블뷰를 리로드합니다.
                    self.scrollToBottom() // 테이블뷰를 맨 아래로 스크롤합니다.
                }
            }
        }
        
        task.resume() // 데이터 태스크를 시작합니다.
    }
    
    // 텍스트를 음성으로 읽어주는 메서드입니다.
    func speakText(_ text: String) {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate) // 현재 음성을 즉시 멈춥니다.
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR") // 한국어 음성으로 설정합니다.
        speechSynthesizer.speak(utterance)
        isSpeaking = true // 음성 재생 여부를 true로 설정합니다.
    }
    
    // 음성 합성이 완료되었을 때 호출됩니다.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false // 음성 합성이 완료되면 isSpeaking을 false로 설정합니다.
    }
}
