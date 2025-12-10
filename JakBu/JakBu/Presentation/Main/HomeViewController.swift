import UIKit
import SnapKit
import Then

class HomeViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let headerView = UIView().then {
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }

    private let greetingLabel = UILabel().then {
        $0.text = "안녕하세요! 👋"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .white
    }

    private let statsContainerView = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.2)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let statsLabel = UILabel().then {
        $0.text = "9기 대마고 학생들의 취업률"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white.withAlphaComponent(0.9)
    }

    private let statsValueLabel = UILabel().then {
        $0.text = "0.0%"
        $0.font = .systemFont(ofSize: 32, weight: .bold)
        $0.textColor = .white
    }

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

    private let sectionTitleLabel = UILabel().then {
        $0.text = "최근 활동"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .label
    }

    private let activityStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        setupActivityCards()
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
        contentView.addSubview(headerView)
        headerView.addSubview(greetingLabel)
        headerView.addSubview(statsContainerView)
        statsContainerView.addSubview(statsLabel)
        statsContainerView.addSubview(statsValueLabel)

        contentView.addSubview(todoSectionLabel)
        todoInputStackView.addArrangedSubview(todoTextField)
        todoInputStackView.addArrangedSubview(addButton)
        contentView.addSubview(todoInputStackView)
        contentView.addSubview(todoListStackView)

        contentView.addSubview(sectionTitleLabel)
        contentView.addSubview(activityStackView)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(200)
        }

        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        statsContainerView.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }

        statsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        statsValueLabel.snp.makeConstraints {
            $0.top.equalTo(statsLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        todoSectionLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(32)
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
        }

        sectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(todoListStackView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        activityStackView.snp.makeConstraints {
            $0.top.equalTo(sectionTitleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupNavigationBar() {
        title = "작부"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupActivityCards() {
        let activities = [
            ("이력서 작성", "오늘 오후 2시", "doc.text.fill"),
            ("면접 준비", "내일 오전 10시", "person.fill.questionmark"),
            ("포트폴리오 업데이트", "이번 주", "folder.fill")
        ]

        for activity in activities {
            let card = createActivityCard(title: activity.0, subtitle: activity.1, iconName: activity.2)
            activityStackView.addArrangedSubview(card)
        }
    }

    private func createActivityCard(title: String, subtitle: String, iconName: String) -> UIView {
        let containerView = UIView().then {
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        let iconImageView = UIImageView().then {
            $0.image = UIImage(systemName: iconName)
            $0.tintColor = .systemBlue
            $0.contentMode = .scaleAspectFit
        }

        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
        }

        let subtitleLabel = UILabel().then {
            $0.text = subtitle
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
        }

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }

        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }

        containerView.snp.makeConstraints {
            $0.height.equalTo(72)
        }

        return containerView
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
