import UIKit
import SnapKit
import Then
import Combine // 1. Import Combine

class CalendarViewController: UIViewController {

    // MARK: - Properties

    private var selectedDate = Date()
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    private var todosForSelectedDate: [Todo] = []

    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var gradientLayer: CAGradientLayer?

    // MARK: - UI Components

    private let monthLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .jakbuTextPrimary
        $0.textAlignment = .center
    }

    private let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .jakbuSelectedStart
    }

    private let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .jakbuSelectedStart
    }

    private let weekdayStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 0
    }

    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        return collectionView
    }()

    private let eventsLabel = UILabel().then {
        $0.text = "일정"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .jakbuTextPrimary
    }

    private let eventsTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(EventCell.self, forCellReuseIdentifier: "EventCell")
    }

    private let noEventsLabel = UILabel().then {
        $0.text = "등록된 일정이 없습니다"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .jakbuTextQuaternary
        $0.textAlignment = .center
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupNavigationBar()
        setupWeekdays()
        updateMonthLabel()
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        eventsTableView.delegate = self
        eventsTableView.dataSource = self

        fetchTodos(for: selectedDate) // 6. Call fetchTodos on Load
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

        view.addSubview(monthLabel)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(weekdayStackView)
        view.addSubview(calendarCollectionView)
        view.addSubview(eventsLabel)
        view.addSubview(eventsTableView)
        view.addSubview(noEventsLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    private func setupConstraints() {
        monthLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.centerX.equalToSuperview()
        }

        previousButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.trailing.equalTo(monthLabel.snp.leading).offset(-24)
            $0.width.height.equalTo(32)
        }

        nextButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.leading.equalTo(monthLabel.snp.trailing).offset(24)
            $0.width.height.equalTo(32)
        }

        weekdayStackView.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
        }

        calendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekdayStackView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(300)
        }

        eventsLabel.snp.makeConstraints {
            $0.top.equalTo(calendarCollectionView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        eventsTableView.snp.makeConstraints {
            $0.top.equalTo(eventsLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        noEventsLabel.snp.makeConstraints {
            $0.center.equalTo(eventsTableView)
        }
    }

    private func setupActions() {
        previousButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
    }

    private func setupNavigationBar() {
        title = "캘린더"
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

        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addEventTapped))
        addButton.tintColor = .jakbuSelectedStart
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupWeekdays() {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        for weekday in weekdays {
            let label = UILabel().then {
                $0.text = weekday
                $0.font = .systemFont(ofSize: 14, weight: .semibold)
                $0.textColor = .jakbuTextTertiary
                $0.textAlignment = .center
            }
            weekdayStackView.addArrangedSubview(label)
        }
    }

    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        monthLabel.text = formatter.string(from: selectedDate)
    }

    // MARK: - API Calls

    private func fetchTodos(for date: Date) { // 5. Fetch ToDos for selected date
        let formattedDate = apiDateFormatter.string(from: date)
        APIService.shared.getTodosByDate(date: formattedDate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    if let apiError = error as? APIError, apiError == .sessionExpired {
                        self.handleSessionExpired()
                    } else {
                        self.showAlert(message: "일정을 불러오는데 실패했습니다: \(error.localizedDescription)")
                    }
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                self.todosForSelectedDate = todos
                self.eventsTableView.reloadData()
                self.noEventsLabel.isHidden = !todos.isEmpty
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func previousMonthTapped() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateMonthLabel()
            calendarCollectionView.reloadData()
            fetchTodos(for: selectedDate) // Fetch todos for new month
        }
    }

    @objc private func nextMonthTapped() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateMonthLabel()
            calendarCollectionView.reloadData()
            fetchTodos(for: selectedDate) // Fetch todos for new month
        }
    }

    @objc private func addEventTapped() {
        // TODO: 일정 추가 화면으로 이동
    }

    // MARK: - Helper Methods

    private func getDaysInMonth() -> [Date?] {
        var days: [Date?] = []

        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return days
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        for _ in 0..<(firstWeekday - 1) {
            days.append(nil)
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getDaysInMonth().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }

        let days = getDaysInMonth()
        let date = days[indexPath.item]

        if let date = date {
            let day = calendar.component(.day, from: date)
            let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate) // Highlight selected date
            
            cell.configure(with: day, isCurrentMonth: isCurrentMonth)
            cell.setSelected(isSelected)
        } else {
            cell.configure(with: nil, isCurrentMonth: false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 7
        return CGSize(width: width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { // 7. didSelectItemAt
        guard let tappedDate = getDaysInMonth()[indexPath.item] else { return }
        selectedDate = tappedDate
        collectionView.reloadData() // Reload to highlight new selected date
        fetchTodos(for: selectedDate) // Fetch todos for new selected date
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 8. Update data source
        return todosForSelectedDate.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 8. Update data source
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell else {
            return UITableViewCell()
        }
        let todo = todosForSelectedDate[indexPath.row]
        cell.configure(with: todo) // 9. Configure EventCell
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - CalendarCell

class CalendarCell: UICollectionViewCell {

    private let dayLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
    }

    private var isCurrentMonth: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }

    func configure(with day: Int?, isCurrentMonth: Bool) {
        self.isCurrentMonth = isCurrentMonth
        if let day = day {
            dayLabel.text = "\(day)"
            dayLabel.textColor = isCurrentMonth ? .jakbuTextPrimary : .jakbuTextTertiary
        } else {
            dayLabel.text = ""
        }
        contentView.backgroundColor = .clear
    }

    func setSelected(_ selected: Bool) {
        if selected {
            // Create gradient background
            contentView.backgroundColor = .jakbuSelectedStart
            dayLabel.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = isCurrentMonth ? .jakbuTextPrimary : .jakbuTextTertiary
        }
    }
}

// MARK: - EventCell

class EventCell: UITableViewCell {

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .jakbuTextPrimary
        $0.numberOfLines = 1
    }

    private let statusLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .jakbuTextSecondary
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .jakbuCardBackground
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.jakbuCardBorder.cgColor
        $0.clipsToBounds = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(statusLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        statusLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
    
    func configure(with todo: Todo) {
        titleLabel.text = todo.title
        statusLabel.text = todo.status == .DONE ? "완료" : "미완료"

        if todo.status == .DONE {
            let attributeString = NSMutableAttributedString(string: todo.title)
            attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
            titleLabel.attributedText = attributeString
            titleLabel.textColor = .jakbuTextTertiary
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = todo.title
            titleLabel.textColor = .jakbuTextPrimary
        }
    }
}
