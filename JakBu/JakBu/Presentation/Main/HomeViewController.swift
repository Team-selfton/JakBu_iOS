import UIKit
import SnapKit
import Then

class HomeViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let todoSectionLabel = UILabel().then {
        $0.text = "오늘의 할일을 추가해보세요"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .label
    }

    private let todoTextField = UITextField().then {
        $0.placeholder = "할일을 입력하세요"
        $0.borderStyle = .roundedRect
        $0.font = .systemFont(ofSize: 16)
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 0
    }

    private let addButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = .systemBlue
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
    }

    private let todoInputStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .fill
    }

    private let todoListStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fill
    }

    private var todoItems: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        setupActions()

        // 초기 상태: 버튼 비활성화
        addButton.isEnabled = false
        addButton.alpha = 0.5
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(todoSectionLabel)
        todoInputStackView.addArrangedSubview(todoTextField)
        todoInputStackView.addArrangedSubview(addButton)
        contentView.addSubview(todoInputStackView)
        contentView.addSubview(todoListStackView)
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
            $0.height.equalTo(50)
        }

        addButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }

        todoListStackView.snp.makeConstraints {
            $0.top.equalTo(todoInputStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupNavigationBar() {
        title = "작부"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        guard let text = todoTextField.text, !text.isEmpty else {
            return
        }

        todoItems.append(text)
        addTodoItemToList(text)
        todoTextField.text = ""
        todoTextField.resignFirstResponder()
    }

    @objc private func textFieldDidChange() {
        addButton.isEnabled = !(todoTextField.text?.isEmpty ?? true)
        addButton.alpha = addButton.isEnabled ? 1.0 : 0.5
    }

    private func addTodoItemToList(_ text: String) {
        let todoItemView = createTodoItemView(text: text)
        todoListStackView.addArrangedSubview(todoItemView)
    }

    private func createTodoItemView(text: String) -> UIView {
        let containerView = UIView().then {
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        let checkButton = UIButton(type: .system).then {
            $0.setImage(UIImage(systemName: "circle"), for: .normal)
            $0.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            $0.tintColor = .systemBlue
        }

        let textLabel = UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
            $0.numberOfLines = 0
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
}
