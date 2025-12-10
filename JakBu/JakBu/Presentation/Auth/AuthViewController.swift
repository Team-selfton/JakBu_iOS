import UIKit
import SnapKit
import Then
import Combine

class AuthViewController: UIViewController {

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private var isLoginMode: Bool = true {
        didSet {
            updateUIForAuthMode()
        }
    }

    // MARK: - UI Components

    private let emojiLabel = UILabel().then {
        $0.text = "👊"
        $0.font = .systemFont(ofSize: 56) // text-7xl in Android is large, but need to fit
        $0.textAlignment = .center
    }

    private let appNameLabel = UILabel().then {
        $0.text = "JakBu"
        $0.font = .systemFont(ofSize: 36, weight: .black) // text-4xl font-black
        $0.textAlignment = .center
        $0.textColor = UIColor(red: 107/255, green: 155/255, blue: 216/255, alpha: 1.0) // Solid color instead of gradient for simplicity
    }

    private let sloganLabel = UILabel().then {
        $0.text = "작심삼일 부수기"
        $0.font = .systemFont(ofSize: 14) // text-sm
        $0.textColor = UIColor(white: 1.0, alpha: 0.8) // text-white/80
        $0.textAlignment = .center
    }
    
    private let formContainerView = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.05) // bg-white/5
        $0.layer.cornerRadius = 24 // rounded-3xl
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor // border-white/10
        $0.layer.borderWidth = 1
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
        $0.layer.shadowOpacity = 0.25
    }
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then { // backdrop-blur-sm
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private let loginToggleButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
    }
    
    private let signupToggleButton = UIButton(type: .system).then {
        $0.setTitle("회원가입", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
    }
    
    private let nameTextField = UITextField().then {
        $0.placeholder = "이름"
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.textColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "이름", attributes: [.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.1) // bg-white/10
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor // border-white/20
        $0.layer.borderWidth = 1
        $0.font = .systemFont(ofSize: 16)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.rightViewMode = .always
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true // py-6, text-base approx
    }
    
    private let accountIdTextField = UITextField().then { // Renamed from accountIdTextField in original
        $0.placeholder = "이메일"
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.textColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "이메일", attributes: [.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.1) // bg-white/10
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor // border-white/20
        $0.layer.borderWidth = 1
        $0.font = .systemFont(ofSize: 16)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.rightViewMode = .always
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호"
        $0.isSecureTextEntry = true
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.textColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "비밀번호", attributes: [.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.1) // bg-white/10
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor // border-white/20
        $0.layer.borderWidth = 1
        $0.font = .systemFont(ofSize: 16)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.rightViewMode = .always
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private let confirmPasswordTextField = UITextField().then {
        $0.placeholder = "비밀번호 확인"
        $0.isSecureTextEntry = true
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.textColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "비밀번호 확인", attributes: [.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.1) // bg-white/10
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor // border-white/20
        $0.layer.borderWidth = 1
        $0.font = .systemFont(ofSize: 16)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.rightViewMode = .always
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private let submitButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold) // text-base py-6 font-bold
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12 // rounded-xl
        $0.clipsToBounds = true
        $0.heightAnchor.constraint(equalToConstant: 54).isActive = true // py-6 approx
        $0.layer.shadowColor = UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 0.4).cgColor // shadow-lg
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
        $0.layer.shadowOpacity = 0.5
    }
    
    private let legalTextView = UILabel().then {
        $0.text = "로그인하면 서비스 약관에 동의하게 됩니다"
        $0.font = .systemFont(ofSize: 10) // text-xs
        $0.textColor = UIColor(white: 1.0, alpha: 0.4) // text-white/40
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    // MARK: - Gradient Layers
    private let backgroundGradientLayer = CAGradientLayer()
    private let loginButtonGradientLayer = CAGradientLayer()
    private let signupButtonGradientLayer = CAGradientLayer()
    private let submitButtonGradientLayer = CAGradientLayer()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardDismiss()
        updateUIForAuthMode() // Initial UI update
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
        updateToggleButtonGradients()
        submitButtonGradientLayer.frame = submitButton.bounds
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

        // Add visual effect view for blur
        formContainerView.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(emojiLabel)
        view.addSubview(appNameLabel)
        view.addSubview(sloganLabel)
        view.addSubview(formContainerView)
        formContainerView.addSubview(loginToggleButton)
        formContainerView.addSubview(signupToggleButton)
        formContainerView.addSubview(nameTextField)
        formContainerView.addSubview(accountIdTextField)
        formContainerView.addSubview(passwordTextField)
        formContainerView.addSubview(confirmPasswordTextField)
        formContainerView.addSubview(submitButton)
        view.addSubview(legalTextView)
        
        // Setup gradients for toggle buttons (initial state, will be updated)
        loginToggleButton.layer.insertSublayer(loginButtonGradientLayer, at: 0)
        signupToggleButton.layer.insertSublayer(signupButtonGradientLayer, at: 0)
        submitButton.layer.insertSublayer(submitButtonGradientLayer, at: 0)

        // Submit Button Gradient
        submitButtonGradientLayer.colors = [
            UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 1.0).cgColor,
            UIColor(red: 74/255, green: 123/255, blue: 192/255, alpha: 1.0).cgColor
        ]
        submitButtonGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        submitButtonGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        submitButtonGradientLayer.cornerRadius = submitButton.layer.cornerRadius
    }

    private func setupConstraints() {
        emojiLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24) // pt-16 approx
        }

        appNameLabel.snp.makeConstraints {
            $0.top.equalTo(emojiLabel.snp.bottom).offset(4) // mb-4
            $0.centerX.equalToSuperview()
        }

        sloganLabel.snp.makeConstraints {
            $0.top.equalTo(appNameLabel.snp.bottom).offset(4) // mb-2
            $0.centerX.equalToSuperview()
        }
        
        formContainerView.snp.makeConstraints {
            $0.top.equalTo(sloganLabel.snp.bottom).offset(32) // mb-8
            $0.leading.equalToSuperview().offset(32) // px-8 approx
            $0.trailing.equalToSuperview().offset(-32)
        }

        let toggleStack = UIStackView(arrangedSubviews: [loginToggleButton, signupToggleButton]).then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 8 // gap-2
        }
        formContainerView.addSubview(toggleStack)
        toggleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24) // p-6
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(48) // py-3
        }

        // Input fields stack
        let inputStack = UIStackView(arrangedSubviews: [nameTextField, accountIdTextField, passwordTextField, confirmPasswordTextField]).then {
            $0.axis = .vertical
            $0.spacing = 12 // space-y-4
        }
        formContainerView.addSubview(inputStack)
        inputStack.snp.makeConstraints {
            $0.top.equalTo(toggleStack.snp.bottom).offset(24) // mb-6 from toggle buttons
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(inputStack.snp.bottom).offset(24) // space-y-4 for form + padding
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-24) // p-6
        }

        legalTextView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24) // pb-8
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        loginToggleButton.addTarget(self, action: #selector(loginToggleButtonTapped), for: .touchUpInside)
        signupToggleButton.addTarget(self, action: #selector(signupToggleButtonTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func loginToggleButtonTapped() {
        isLoginMode = true
    }
    
    @objc private func signupToggleButtonTapped() {
        isLoginMode = false
    }

    private func updateUIForAuthMode() {
        UIView.animate(withDuration: 0.3) {
            self.nameTextField.isHidden = self.isLoginMode
            self.confirmPasswordTextField.isHidden = self.isLoginMode
            self.submitButton.setTitle(self.isLoginMode ? "로그인" : "회원가입", for: .normal)
            self.updateToggleButtonGradients()
            
            // Adjust layout for changes in hidden views
            self.formContainerView.layoutIfNeeded()
        }
    }
    
    private func updateToggleButtonGradients() {
        // Login Button
        if isLoginMode {
            loginButtonGradientLayer.colors = [
                UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 1.0).cgColor,
                UIColor(red: 74/255, green: 123/255, blue: 192/255, alpha: 1.0).cgColor
            ]
            loginToggleButton.setTitleColor(.white, for: .normal)
        } else {
            loginButtonGradientLayer.colors = [] // No gradient, just clear background
            loginToggleButton.setTitleColor(UIColor(white: 1.0, alpha: 0.6), for: .normal)
            loginToggleButton.backgroundColor = UIColor(white: 1.0, alpha: 0.05) // bg-white/5
        }
        loginButtonGradientLayer.frame = loginToggleButton.bounds
        loginButtonGradientLayer.cornerRadius = loginToggleButton.layer.cornerRadius
        
        // Signup Button
        if !isLoginMode {
            signupButtonGradientLayer.colors = [
                UIColor(red: 91/255, green: 141/255, blue: 213/255, alpha: 1.0).cgColor,
                UIColor(red: 74/255, green: 123/255, blue: 192/255, alpha: 1.0).cgColor
            ]
            signupToggleButton.setTitleColor(.white, for: .normal)
        } else {
            signupButtonGradientLayer.colors = []
            signupToggleButton.setTitleColor(UIColor(white: 1.0, alpha: 0.6), for: .normal)
            signupToggleButton.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        }
        signupButtonGradientLayer.frame = signupToggleButton.bounds
        signupButtonGradientLayer.cornerRadius = signupToggleButton.layer.cornerRadius
    }

    @objc private func actionButtonTapped() {
        if isLoginMode {
            login()
        } else {
            signup()
        }
    }
    
    private func login() {
        guard let accountId = accountIdTextField.text, !accountId.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "이메일과 비밀번호를 입력해주세요.")
            return
        }

        let request = LoginRequest(accountId: accountId, password: password)
        APIService.shared.login(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.showAlert(message: "로그인 실패: \(error.localizedDescription)")
                }
            } receiveValue: { response in
                AuthManager.shared.saveTokens(from: response)
                self.presentMainVC()
            }
            .store(in: &cancellables)
    }

    private func signup() {
        guard let name = nameTextField.text, !name.isEmpty,
              let accountId = accountIdTextField.text, !accountId.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let passwordConfirm = confirmPasswordTextField.text, !passwordConfirm.isEmpty else {
            showAlert(message: "모든 필드를 입력해주세요.")
            return
        }

        guard password == passwordConfirm else {
            showAlert(message: "비밀번호가 일치하지 않습니다.")
            return
        }

        let request = SignupRequest(accountId: accountId, password: password, name: name)
        APIService.shared.signup(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.showAlert(message: "회원가입 실패: \(error.localizedDescription)")
                }
            } receiveValue: { response in
                AuthManager.shared.saveTokens(from: response)
                self.showAlert(message: "회원가입 성공!") {
                    self.presentMainVC()
                }
            }
            .store(in: &cancellables)
    }

    private func presentMainVC() {
        let mainVC = MainTabBarController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}