//
//  DatePickerHeaderView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import RxCocoa
import RxSwift
import Then


final class DatePickerHeaderView: UIView {
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private var currentDate = Date()
    private let calendar = Calendar.current
    
    let selectedDate = PublishRelay<Date>()
    private var days: [Date] = []
    
    // MARK: UI Components
    private let titleLabel = UILabel().then {
        $0.text = "오늘의 문화일정"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey90
    }
    
    private let leftButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .grey90
    }
    
    private let rightButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .grey90
    }
    
    private let monthLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .center
        $0.textColor = .grey90
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 50, height: 70)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        updateMonth()
        generateDays(for: currentDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(leftButton)
        addSubview(monthLabel)
        addSubview(rightButton)
        addSubview(daysCollectionView)

        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.identifier)
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.sizeToFit()
        titleLabel.pin.top(0).height(22)

        monthLabel.sizeToFit()
        monthLabel.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally(20)
            .height(40)

        leftButton.sizeToFit()
        rightButton.sizeToFit()

        leftButton.pin.left(0).vCenter(to: monthLabel.edge.vCenter)
        rightButton.pin.right(0).vCenter(to: monthLabel.edge.vCenter)

        daysCollectionView.pin
            .below(of: monthLabel)
            .marginTop(8)
            .horizontally()
            .height(80)

        self.pin.height(daysCollectionView.frame.maxY)
    }
    
    // MARK: Binding
    private func bind() {
        leftButton.rx.tap
            .bind { [weak self] in
                self?.moveMonth(by: -1)
            }
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .bind { [weak self] in
                self?.moveMonth(by: 1)
            }
            .disposed(by: disposeBag)
    }
    
    private func moveMonth(by value: Int) {
        guard let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) else { return }
        currentDate = newDate
        updateMonth()
        generateDays(for: newDate)
    }
    
    private func updateMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        monthLabel.text = formatter.string(from: currentDate)
    }
    
    private func generateDays(for date: Date) {
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return }
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return }
        
        days = range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }
        
        daysCollectionView.reloadData()
        
        if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
            selectToday()
        }
    }
    
    private func selectToday() {
        guard let todayIndex = days.firstIndex(where: { calendar.isDateInToday($0) }) else { return }
        
        let indexPath = IndexPath(item: todayIndex, section: 0)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.daysCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView(daysCollectionView, didSelectItemAt: indexPath)
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension DatePickerHeaderView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DayCell.identifier,
            for: indexPath
        ) as? DayCell else {
            return UICollectionViewCell()
        }
        cell.configure(date: days[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = days[indexPath.item]
        selectedDate.accept(selected)
        
        collectionView.visibleCells.forEach { cell in
            if let index = collectionView.indexPath(for: cell) {
                collectionView.deselectItem(at: index, animated: false)
            }
        }
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }
}
