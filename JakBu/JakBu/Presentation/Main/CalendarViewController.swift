import UIKit
import SnapKit
import Then

class CalendarViewController: UIViewController {

    // MARK: - Properties

    private var selectedDate = Date()
    private let calendar = Calendar.current

    // MARK: - UI Components

    private let monthLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .label
        $0.textAlignment = .center
    }

    private let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .systemBlue
    }

    private let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .systemBlue
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
        $0.textColor = .label
    }

    private let eventsTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(EventCell.self, forCellReuseIdentifier: "EventCell")
    }

    private let noEventsLabel = UILabel().then {
        $0.text = "등록된 일정이 없습니다"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
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
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(monthLabel)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(weekdayStackView)
        view.addSubview(calendarCollectionView)
        view.addSubview(eventsLabel)
        view.addSubview(eventsTableView)
        view.addSubview(noEventsLabel)
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
            $0.top.equalTo(calendarCollectionView.snp.bottom).offset(32)
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

        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addEventTapped))
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupWeekdays() {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        for weekday in weekdays {
            let label = UILabel().then {
                $0.text = weekday
                $0.font = .systemFont(ofSize: 14, weight: .semibold)
                $0.textColor = .secondaryLabel
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

    // MARK: - Actions

    @objc private func previousMonthTapped() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateMonthLabel()
            calendarCollectionView.reloadData()
        }
    }

    @objc private func nextMonthTapped() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateMonthLabel()
            calendarCollectionView.reloadData()
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
            cell.configure(with: day)

            let isToday = calendar.isDateInToday(date)
            cell.setSelected(isToday)
        } else {
            cell.configure(with: nil)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 7
        return CGSize(width: width, height: 44)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell else {
            return UITableViewCell()
        }
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

    func configure(with day: Int?) {
        if let day = day {
            dayLabel.text = "\(day)"
            dayLabel.textColor = .label
        } else {
            dayLabel.text = ""
        }
        contentView.backgroundColor = .clear
    }

    func setSelected(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = .systemBlue
            dayLabel.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = .label
        }
    }
}

// MARK: - EventCell

class EventCell: UITableViewCell {

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
    }
}
