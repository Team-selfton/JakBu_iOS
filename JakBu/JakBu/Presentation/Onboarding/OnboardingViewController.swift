import UIKit
import SnapKit
import Then

class OnboardingViewController: UIViewController {

    // MARK: - UI Components

    private let emojiLabel = UILabel().then {
        $0.text = "👊"
        $0.font = .systemFont(ofSize: 140)
        $0.textAlignment = .center
        $0.layer.shadowColor = UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 0.4).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 8)
        $0.layer.shadowRadius = 16
        $0.layer.shadowOpacity = 1.0
    }

    private let appNameLabel = UILabel().then {
        $0.text = "JakBu"
        $0.font = .systemFont(ofSize: 64, weight: .bold)
        $0.textAlignment = .center
        // Use a solid color for the text to ensure visibility. Gradient text is complex and was likely the issue.
        $0.textColor = UIColor(red: 123/255, green: 168/255, blue: 227/255, alpha: 1.0)
        
        $0.layer.shadowColor = UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 0.5).cgColor
        $0.layer.shadowOffset = .zero
        $0.layer.shadowRadius = 30
        $0.layer.shadowOpacity = 1.0
    }

    private let sloganLabel = UILabel().then {
        $0.text = "작심삼일 부수기"
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = UIColor(white: 1.0, alpha: 0.95)
        $0.textAlignment = .center
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "오늘의 할일부터 시작해보세요.\n꾸준함이 습관을 만들고,\n습관이 인생을 바꿉니다."
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = UIColor(white: 1.0, alpha: 0.90)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let startButton = UIButton(type: .system).then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 32 // Half of height 64
        $0.clipsToBounds = true
    }
    
    // MARK: - Gradient Layers
    private let backgroundGradientLayer = CAGradientLayer()
    private let buttonGradientLayer = CAGradientLayer()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradients are sized correctly after layout
        backgroundGradientLayer.frame = view.bounds
        buttonGradientLayer.frame = startButton.bounds
    }

    // MARK: - Setup

    private func setupUI() {
        // Background Gradient
        backgroundGradientLayer.colors = [
            UIColor(red: 30/255, green: 42/255, blue: 63/255, alpha: 1.0).cgColor,
            UIColor(red: 26/255, green: 35/255, blue: 50/255, alpha: 1.0).cgColor,
            UIColor(red: 15/255, green: 21/255, blue: 32/255, alpha: 1.0).cgColor
        ]
        backgroundGradientLayer.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        // Button Gradient
        buttonGradientLayer.colors = [
            UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 1.0).cgColor,
            UIColor(red: 74/255, green: 123/255, blue: 192/255, alpha: 1.0).cgColor
        ]
        buttonGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        buttonGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        buttonGradientLayer.cornerRadius = startButton.layer.cornerRadius
        startButton.layer.insertSublayer(buttonGradientLayer, at: 0)
        
        view.addSubview(emojiLabel)
        view.addSubview(appNameLabel)
        view.addSubview(sloganLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(startButton)
    }

    private func setupConstraints() {
        emojiLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }

        appNameLabel.snp.makeConstraints {
            $0.top.equalTo(emojiLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        sloganLabel.snp.makeConstraints {
            $0.top.equalTo(appNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(sloganLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        startButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            $0.height.equalTo(64)
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
