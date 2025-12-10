import UIKit
import SnapKit
import Then
import Combine

class HomeViewController: UIViewController {

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private var todoItems: [Todo] = []
    private var doneItems: [Todo] = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var gradientLayer: CAGradientLayer?

    private let logoutButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        $0.tintColor = .jakbuTextSecondary
    }


    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let titleLabel = UILabel().then {
        $0.text = "JakBu"
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.textColor = .jakbuTitleStart
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "작심삼일 부수기"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .jakbuTextSecondary
    }

    private let testNotificationButton = UIButton(type: .system).then {
        $0.setTitle("알림 테스트", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        $0.setTitleColor(.jakbuTextTertiary, for: .normal)
        $0.backgroundColor = .jakbuCardBackground
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.jakbuCardBorder.cgColor
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }

    private let todoSectionLabel = UILabel().then {
        $0.text = "할일 추가"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .jakbuTextPrimary
    }

    private let todoTextField = UITextField().then {
        $0.placeholder = "할일을 입력하세요"
        $0.borderStyle = .none
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.backgroundColor = .jakbuCardBackground
        $0.textColor = .jakbuTextPrimary
        $0.attributedPlaceholder = NSAttributedString(
            string: "할일을 입력하세요",
            attributes: [.foregroundColor: UIColor.jakbuTextPlaceholder]
        )
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.jakbuCardBorder.cgColor
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        $0.rightViewMode = .always
    }

    private let addButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = .jakbuSelectedStart
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
    }

    private let todoInputStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let todayTodoSectionLabel = UILabel().then {
        $0.text = "오늘의 할일"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .jakbuTextPrimary
    }

    private let todoListStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fill
    }

    private let doneSectionLabel = UILabel().then {
        $0.text = "완료된 할일"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .jakbuTextPrimary
    }

    private let doneListStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fill
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()

        addButton.isEnabled = false
        addButton.alpha = 0.5

        fetchTodayTodos()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup

    private func setupUI() {
        // Add gradient background
        let gradient = UIColor.jakbuGradientLayer(
            colors: [.jakbuBackgroundTop, .jakbuBackgroundMiddle, .jakbuBackgroundBottom],
            frame: view.bounds
        )
        gradientLayer = gradient
        view.layer.insertSublayer(gradient, at: 0)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(logoutButton)
        contentView.addSubview(testNotificationButton)
        contentView.addSubview(todoSectionLabel)
        todoInputStackView.addArrangedSubview(todoTextField)
        todoInputStackView.addArrangedSubview(addButton)
        contentView.addSubview(todoInputStackView)
        contentView.addSubview(todayTodoSectionLabel)
        contentView.addSubview(todoListStackView)
        contentView.addSubview(doneSectionLabel)
        contentView.addSubview(doneListStackView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }

        logoutButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }

//        testNotificationButton.snp.makeConstraints {
//            $0.centerY.equalTo(subtitleLabel)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.equalTo(32)
//        }

        todoSectionLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        todoTextField.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        todoInputStackView.snp.makeConstraints {
            $0.top.equalTo(todoSectionLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        addButton.snp.makeConstraints {
            $0.width.height.equalTo(65)
        }

        todayTodoSectionLabel.snp.makeConstraints {
            $0.top.equalTo(todoInputStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        todoListStackView.snp.makeConstraints {
            $0.top.equalTo(todayTodoSectionLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        doneSectionLabel.snp.makeConstraints {
            $0.top.equalTo(todoListStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        doneListStackView.snp.makeConstraints {
            $0.top.equalTo(doneSectionLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        testNotificationButton.addTarget(self, action: #selector(testNotificationTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        present(alert, animated: true)
    }
    
    private func performLogout() {
        // Clear tokens
        AuthManager.shared.clearTokens()

        // 위젯 데이터 초기화
        SharedDataManager.shared.saveTodos([])

        // Navigate to Onboarding
        guard let window = view.window else { return }
        let onboardingVC = OnboardingViewController()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = onboardingVC
        })
        window.makeKeyAndVisible()
    }

    private func fetchTodayTodos() {
        APIService.shared.getTodayTodos()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    if let apiError = error as? APIError, apiError == .sessionExpired {
                        self.handleSessionExpired()
                    } else {
                        self.showAlert(message: "할일 목록을 불러오는데 실패했습니다: \(error.localizedDescription)")
                    }
                }
            } receiveValue: { todos in
                self.todoItems = todos.filter { $0.status == .TODO }
                self.doneItems = todos.filter { $0.status == .DONE }
                self.updateUI()

                // 위젯 데이터 업데이트
                SharedDataManager.shared.saveTodos(todos)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions

    @objc private func addButtonTapped() {
        guard let text = todoTextField.text, !text.isEmpty else {
            return
        }
        
        let today = dateFormatter.string(from: Date())
        let request = CreateTodoRequest(title: text, date: today)

        APIService.shared.createTodo(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    if let apiError = error as? APIError, apiError == .sessionExpired {
                        self.handleSessionExpired()
                    } else {
                        self.showAlert(message: "할일 추가에 실패했습니다: \(error.localizedDescription)")
                    }
                }
            } receiveValue: { _ in
                self.todoTextField.text = ""
                self.todoTextField.resignFirstResponder()
                self.fetchTodayTodos()

                // 위젯 새로고침
                SharedDataManager.shared.reloadAllWidgets()
            }
            .store(in: &cancellables)
    }

    @objc private func textFieldDidChange() {
        addButton.isEnabled = !(todoTextField.text?.isEmpty ?? true)
        addButton.alpha = addButton.isEnabled ? 1.0 : 0.5
    }

    @objc private func testNotificationTapped() {
        NotificationManager.shared.sendTestNotification()

        // 피드백 제공
        let alert = UIAlertController(
            title: "테스트 알림 예약됨",
            message: "5초 후에 알림이 표시됩니다.\n앱을 백그라운드로 전환하면 알림을 확인할 수 있습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func updateUI() {
        UIView.transition(with: todoListStackView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.todoListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            if self.todoItems.isEmpty {
                self.addPlaceholder(to: self.todoListStackView, withText: "할일이 없습니다.")
            } else {
                self.removePlaceholder(from: self.todoListStackView)
                for item in self.todoItems {
                    let itemView = self.createTodoItemView(item: item)
                    self.todoListStackView.addArrangedSubview(itemView)
                }
            }
        }, completion: nil)

        UIView.transition(with: doneListStackView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.doneListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            if self.doneItems.isEmpty {
                self.addPlaceholder(to: self.doneListStackView, withText: "완료된 할일이 없습니다.")
            } else {
                self.removePlaceholder(from: self.doneListStackView)
                for item in self.doneItems {
                    let itemView = self.createTodoItemView(item: item)
                    self.doneListStackView.addArrangedSubview(itemView)
                }
            }
        }, completion: nil)
    }

    private func createPlaceholderView(withText text: String) -> UIView {
        let placeholderLabel = UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .jakbuTextQuaternary
            $0.textAlignment = .center
        }

        let containerView = UIView().then {
            $0.backgroundColor = .jakbuCardBackgroundSecondary
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.jakbuCardBorder.cgColor
            $0.clipsToBounds = true
            $0.tag = -1 // Assign a unique negative tag for placeholders
        }

        containerView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        containerView.snp.makeConstraints {
            $0.height.equalTo(56)
        }

        return containerView
    }

    private func createTodoItemView(item: Todo) -> UIView {
        let containerView = UIView().then {
            $0.backgroundColor = .jakbuCardBackground
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.jakbuCardBorder.cgColor
            $0.clipsToBounds = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoItemTapped(_:)))
            $0.addGestureRecognizer(tapGesture)
            $0.isUserInteractionEnabled = true
            $0.tag = item.id
        }

        let checkButton = UIButton(type: .system).then {
            let isDone = item.status == .DONE
            let imageName = isDone ? "checkmark.circle.fill" : "circle"
            $0.setImage(UIImage(systemName: imageName), for: .normal)
            $0.tintColor = isDone ? .systemGreen : .jakbuSelectedStart
            $0.isUserInteractionEnabled = false
            $0.tag = 101 // Unique tag for checkButton
        }

        let textLabel = UILabel().then {
            $0.text = item.title
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .jakbuTextPrimary
            $0.numberOfLines = 0
            if item.status == .DONE {
                let attributeString = NSMutableAttributedString(string: item.title)
                attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
                $0.attributedText = attributeString
                $0.textColor = .jakbuTextTertiary
            }
            $0.tag = 102 // Unique tag for textLabel
        }

        let deleteButton = UIButton(type: .system).then {
            $0.setImage(UIImage(systemName: "xmark"), for: .normal)
            $0.tintColor = .jakbuTextTertiary
            $0.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            $0.tag = item.id
        }

        containerView.addSubview(checkButton)
        containerView.addSubview(textLabel)
        containerView.addSubview(deleteButton)

        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        textLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-12)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }

        containerView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(56)
        }

        return containerView
    }

    @objc private func todoItemTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let tappedId = view.tag

        APIService.shared.toggleTodoStatus(id: tappedId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    if let apiError = error as? APIError, apiError == .sessionExpired {
                        self.handleSessionExpired()
                    } else {
                        self.showAlert(message: "상태 변경에 실패했습니다: \(error.localizedDescription)")
                    }
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }

                // Update the data source
                if let index = self.todoItems.firstIndex(where: { $0.id == tappedId }) {
                    self.todoItems.remove(at: index)
                    self.doneItems.append(updatedTodo)
                } else if let index = self.doneItems.firstIndex(where: { $0.id == tappedId }) {
                    self.doneItems.remove(at: index)
                    self.todoItems.append(updatedTodo)
                }
                // Re-render UI after data source update
                self.updateUI()

                // 위젯 데이터 업데이트
                let allTodos = self.todoItems + self.doneItems
                SharedDataManager.shared.saveTodos(allTodos)
            }
            .store(in: &cancellables)
    }

    private func updateItemView(_ view: UIView, isDone: Bool) {
        guard let checkButton = view.viewWithTag(101) as? UIButton,
              let textLabel = view.viewWithTag(102) as? UILabel else {
            return
        }

        let imageName = isDone ? "checkmark.circle.fill" : "circle"
        checkButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkButton.tintColor = isDone ? .systemGreen : .jakbuSelectedStart

        // Ensure textLabel.text is not nil before attempting to get its string value
        let originalText = (textLabel.attributedText?.string ?? textLabel.text) ?? ""

        if isDone {
            let attributeString = NSMutableAttributedString(string: originalText)
            attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
            textLabel.attributedText = attributeString
            textLabel.textColor = .jakbuTextTertiary
        } else {
            textLabel.attributedText = nil
            textLabel.text = originalText
            textLabel.textColor = .jakbuTextPrimary
        }
    }
    
    private func addPlaceholder(to stackView: UIStackView, withText text: String) {
        // Only add if there isn't one already
        if stackView.arrangedSubviews.first(where: { $0.tag == -1 }) == nil {
            let placeholder = createPlaceholderView(withText: text)
            placeholder.alpha = 0 // Start invisible for animation
            stackView.addArrangedSubview(placeholder)
            UIView.animate(withDuration: 0.3) {
                placeholder.alpha = 1
            }
        }
    }

    private func removePlaceholder(from stackView: UIStackView) {
        if let placeholder = stackView.arrangedSubviews.first(where: { $0.tag == -1 }) {
            UIView.animate(withDuration: 0.3, animations: {
                placeholder.alpha = 0
            }) { _ in
                stackView.removeArrangedSubview(placeholder)
                placeholder.removeFromSuperview()
            }
        }
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let todoId = sender.tag

        let alert = UIAlertController(title: "할일 삭제", message: "이 할일을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.deleteTodo(id: todoId)
        }))
        present(alert, animated: true)
    }

    private func deleteTodo(id: Int) {
        APIService.shared.deleteTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    if let apiError = error as? APIError, apiError == .sessionExpired {
                        self.handleSessionExpired()
                    } else {
                        self.showAlert(message: "할일 삭제에 실패했습니다: \(error.localizedDescription)")
                    }
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }

                // Remove from data source
                self.todoItems.removeAll { $0.id == id }
                self.doneItems.removeAll { $0.id == id }

                // Re-render UI
                self.updateUI()

                // 위젯 데이터 업데이트
                let allTodos = self.todoItems + self.doneItems
                SharedDataManager.shared.saveTodos(allTodos)
                SharedDataManager.shared.reloadAllWidgets()
            }
            .store(in: &cancellables)
    }

    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    private func handleSessionExpired() {
        showAlert(message: "세션이 만료되었습니다. 다시 로그인해주세요.") {
            self.performLogout()
        }
    }
}

