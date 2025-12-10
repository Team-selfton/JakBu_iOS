import UIKit
import SnapKit
import Then

struct TodoItem {
    let id: UUID
    var text: String
    var isDone: Bool
}

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
    
    private let doneSectionLabel = UILabel().then {
        $0.text = "완료된 할일"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .label
    }

    private let doneListStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fill
    }

    private var todoItems: [TodoItem] = []
    private var doneItems: [TodoItem] = []

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
        
        updateUI()
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
        contentView.addSubview(doneSectionLabel)
        contentView.addSubview(doneListStackView)
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

        todoListStackView.snp.makeConstraints {
            $0.top.equalTo(todoInputStackView.snp.bottom).offset(12)
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

        let newItem = TodoItem(id: UUID(), text: text, isDone: false)
        todoItems.append(newItem)

        updateUI()

        todoTextField.text = ""
        todoTextField.resignFirstResponder()
    }

    @objc private func textFieldDidChange() {
        addButton.isEnabled = !(todoTextField.text?.isEmpty ?? true)
        addButton.alpha = addButton.isEnabled ? 1.0 : 0.5
    }

    private func updateUI() {
        // 스택 뷰의 모든 서브뷰를 제거
        todoListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        doneListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // todoItems에 대한 뷰를 생성하고 스택 뷰에 추가
        if todoItems.isEmpty {
            let placeholder = createPlaceholderView(withText: "할일이 없습니다.")
            todoListStackView.addArrangedSubview(placeholder)
        } else {
            for item in todoItems {
                let itemView = createTodoItemView(item: item)
                todoListStackView.addArrangedSubview(itemView)
            }
        }

        // doneItems에 대한 뷰를 생성하고 스택 뷰에 추가
        if doneItems.isEmpty {
            let placeholder = createPlaceholderView(withText: "완료된 할일이 없습니다.")
            doneListStackView.addArrangedSubview(placeholder)
        } else {
            for item in doneItems {
                let itemView = createTodoItemView(item: item)
                doneListStackView.addArrangedSubview(itemView)
            }
        }
    }

    private func createPlaceholderView(withText text: String) -> UIView {
        let placeholderLabel = UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .systemGray
            $0.textAlignment = .center
        }

        let containerView = UIView().then {
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
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


    private func createTodoItemView(item: TodoItem) -> UIView {
        let containerView = UIView().then {
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(todoItemTapped(_:)))
            $0.addGestureRecognizer(tapGesture)
            $0.isUserInteractionEnabled = true
            $0.tag = item.id.hashValue // id를 태그로 사용하여 어떤 아이템이 탭되었는지 식별
        }

        let checkButton = UIButton(type: .system).then {
            let imageName = item.isDone ? "checkmark.circle.fill" : "circle"
            $0.setImage(UIImage(systemName: imageName), for: .normal)
            $0.tintColor = .systemBlue
            $0.isUserInteractionEnabled = false // 버튼의 탭 액션 대신 컨테이너 뷰의 탭 제스처를 사용
        }

        let textLabel = UILabel().then {
            $0.text = item.text
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
            $0.numberOfLines = 0
            if item.isDone {
                // 취소선 추가
                let attributeString = NSMutableAttributedString(string: item.text)
                attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
                $0.attributedText = attributeString
                $0.textColor = .systemGray
            }
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
        let tappedIdHash = view.tag

        if let index = todoItems.firstIndex(where: { $0.id.hashValue == tappedIdHash }) {
            var item = todoItems.remove(at: index)
            item.isDone = true
            doneItems.append(item)
        } else if let index = doneItems.firstIndex(where: { $0.id.hashValue == tappedIdHash }) {
            var item = doneItems.remove(at: index)
            item.isDone = false
            todoItems.append(item)
        }

        updateUI()
    }
}
