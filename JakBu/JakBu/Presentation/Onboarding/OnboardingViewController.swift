import UIKit
import SnapKit
import Then

class OnboardingViewController: UIViewController {

    // MARK: - UI Components

    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "briefcase.fill")
        $0.tintColor = .systemBlue
    }

    private let titleLabel = UILabel().then {
        $0.text = "작부"
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.textColor = .label
        $0.textAlignment = .center
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "작은 부자들의 취업 관리 서비스"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let startButton = UIButton(type: .system).then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(startButton)
    }

    private func setupConstraints() {
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.width.height.equalTo(120)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
        }

        startButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            $0.height.equalTo(56)
        }
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func startButtonTapped() {
        let authVC = AuthViewController()
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }
}
