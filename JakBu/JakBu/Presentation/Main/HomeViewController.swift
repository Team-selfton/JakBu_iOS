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

        sectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(32)
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
}
