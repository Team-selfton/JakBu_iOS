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

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let todoSectionLabel = UILabel().then {
        $0.text = "할일 추가"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .jakbuTextPrimary
    }

    private let todoTextField = UITextField().then {
        $0.placeholder = "할일을 입력하세요"
        $0.borderStyle = .none
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .jakbuCardBackground
        $0.textColor = .jakbuTextPrimary
        $0.attributedPlaceholder = NSAttributedString(
            string: "할일을 입력하세요",
            attributes: [.foregroundColor: UIColor.jakbuTextPlaceholder]
        )
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.jakbuCardBorder.cgColor
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
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
        setupNavigationBar()
        setupActions()

        addButton.isEnabled = false
        addButton.alpha = 0.5
        
        fetchTodayTodos()
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

        todoSectionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        todoInputStackView.snp.makeConstraints {
            $0.top.equalTo(todoSectionLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(60)
        }

        addButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
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

    private func setupNavigationBar() {
        title = "JakBu"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear

        // Large title styling
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.jakbuTitleStart,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        // Standard title styling
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.jakbuTextPrimary,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - API

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
            }
            .store(in: &cancellables)
    }

    @objc private func textFieldDidChange() {
        addButton.isEnabled = !(todoTextField.text?.isEmpty ?? true)
        addButton.alpha = addButton.isEnabled ? 1.0 : 0.5
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

        containerView.addSubview(checkButton)
        containerView.addSubview(textLabel)

        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        textLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
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
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func handleSessionExpired() {
        showAlert(message: "세션이 만료되었습니다. 다시 로그인해주세요.") {
            AuthManager.shared.clearTokens()
            
            guard let window = self.view.window else { return }
            let authVC = AuthViewController()
            window.rootViewController = authVC
            window.makeKeyAndVisible()
        }
    }
}

