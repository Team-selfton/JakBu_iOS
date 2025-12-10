import UIKit
import SnapKit
import Then

class AuthViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let titleLabel = UILabel().then {
        $0.text = "작부에 오신 것을\n환영합니다"
        $0.font = .systemFont(ofSize: 32, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    private let segmentedControl = UISegmentedControl(items: ["로그인", "회원가입"]).then {
        $0.selectedSegmentIndex = 0
    }

    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
        $0.font = .systemFont(ofSize: 16)
    }

    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호"
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
        $0.font = .systemFont(ofSize: 16)
    }

    private let passwordConfirmTextField = UITextField().then {
        $0.placeholder = "비밀번호 확인"
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
        $0.font = .systemFont(ofSize: 16)
        $0.isHidden = true
    }

    private let nameTextField = UITextField().then {
        $0.placeholder = "이름"
        $0.borderStyle = .roundedRect
        $0.font = .systemFont(ofSize: 16)
        $0.isHidden = true
    }

    private let actionButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let forgotPasswordButton = UIButton(type: .system).then {
        $0.setTitle("비밀번호를 잊으셨나요?", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardDismiss()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(passwordConfirmTextField)
        contentView.addSubview(nameTextField)
        contentView.addSubview(actionButton)
        contentView.addSubview(forgotPasswordButton)
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
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(36)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(50)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(50)
        }

        passwordConfirmTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(50)
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalTo(passwordConfirmTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(50)
        }

        actionButton.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(56)
        }

        forgotPasswordButton.snp.makeConstraints {
            $0.top.equalTo(actionButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }
    }

    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        let isSignUp = segmentedControl.selectedSegmentIndex == 1

        UIView.animate(withDuration: 0.3) {
            self.passwordConfirmTextField.isHidden = !isSignUp
            self.nameTextField.isHidden = !isSignUp
            self.forgotPasswordButton.isHidden = isSignUp

            self.actionButton.setTitle(isSignUp ? "회원가입" : "로그인", for: .normal)
        }
    }

    @objc private func actionButtonTapped() {
        let mainVC = MainTabBarController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
