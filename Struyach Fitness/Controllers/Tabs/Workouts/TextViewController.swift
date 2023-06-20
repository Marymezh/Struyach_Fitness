//
//  TextViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//
import UIKit
import IQKeyboardManagerSwift

final class TextViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    
    var text: String = ""
    var isCreatingNewPostOrWorkout = false
    var onWorkoutSave: ((String, TimeInterval?) -> Void)?
    
    let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.tintColor = .lightGray
        textView.isScrollEnabled = true
        textView.backgroundColor = .white
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 10
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowRadius = 10
        textView.layer.shadowOffset = CGSize(width: 5, height: 5)
        textView.layer.shadowOpacity = 0.7
        textView.toAutoLayout()
        return textView
    }()
    
    private lazy var todayButton: UIButton = {
        let button = UIButton()
        button.setTitle("Today".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .customTabBar
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.7
        button.layer.borderWidth = 0.5
  
        button.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    private lazy var tomorrowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Tomorrow".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .customTabBar
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.7
        button.layer.borderWidth = 0.5
  
        button.addTarget(self, action: #selector(tomorrowButtonTapped), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .customMediumGray
        datePicker.layer.borderColor = UIColor.black.cgColor
        datePicker.layer.borderWidth = 0.5
        datePicker.layer.cornerRadius = 10
        datePicker.clipsToBounds = true
        datePicker.tintColor = .systemGreen
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.toAutoLayout()
        return datePicker
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.toAutoLayout()
        return stackView
    }()
    
    private var selectedDate: Date?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customDarkGray
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
        configureButtons()
        setupTextView()
        setupSubviews()
        toggleDateSelectionViews()
    }
    
    deinit {
        print("text view controller is deallocated")
    }
    
    // MARK: - Setup methods
    
    private func configureButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".localized(), style: .done, target: self, action: #selector(addNewWorkout))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .done, target: self, action: #selector(cancel))
    }
    
    private func setupTextView() {
        if text != "" {
            workoutDescriptionTextView.text = text
            workoutDescriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
            workoutDescriptionTextView.isSelectable = true
            workoutDescriptionTextView.isEditable = true
            workoutDescriptionTextView.isUserInteractionEnabled = true
            workoutDescriptionTextView.dataDetectorTypes = .link
        }
    }
    
    private func setupSubviews() {
        workoutDescriptionTextView.delegate = self
        workoutDescriptionTextView.becomeFirstResponder()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2023, month: 1, day: 1)
        let minimumDate = calendar.date(from: components)
        
        datePicker.minimumDate = minimumDate
        
        view.addSubviews(workoutDescriptionTextView, stackView, datePicker)
        
        stackView.addArrangedSubview(todayButton)
        stackView.addArrangedSubview(tomorrowButton)
        
        let baseInset: CGFloat = 15
        let textViewHeight = self.view.frame.height / 2.4
        
        let constraints = [
            workoutDescriptionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseInset * 2),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            workoutDescriptionTextView.heightAnchor.constraint(equalToConstant: textViewHeight),
            
            stackView.topAnchor.constraint(equalTo: workoutDescriptionTextView.bottomAnchor, constant: baseInset * 2),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            stackView.heightAnchor.constraint(equalToConstant: 44),
            
            datePicker.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: baseInset),
            datePicker.heightAnchor.constraint(equalToConstant: 44),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func toggleDateSelectionViews() {
        if self.title == "Add new workout".localized() || self.title == "Add new post".localized() {
            isCreatingNewPostOrWorkout = true
            todayButton.isHidden = false
            tomorrowButton.isHidden = false
            datePicker.isHidden = false
        } else {
            isCreatingNewPostOrWorkout = false
            todayButton.isHidden = true
            tomorrowButton.isHidden = true
            datePicker.isHidden = true
        }
    }
    
    // MARK: - Buttons action methods
    
    @objc private func addNewWorkout() {
        guard let text = workoutDescriptionTextView.text, !text.isEmpty else {
            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Write some text before saving.".localized(), cancelAction: "Cancel".localized())
            return
        }
        
        if isCreatingNewPostOrWorkout{
            if selectedDate != nil {
                let timestamp = selectedDate!.timeIntervalSince1970
                self.onWorkoutSave?(text, timestamp)
            } else {
                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Please select a date.".localized(), cancelAction: "Cancel".localized())
            }
        } else {
            self.onWorkoutSave?(text, nil)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func todayButtonTapped() {
        setSelectedDate(Date())
        todayButton.backgroundColor = .systemGreen
        tomorrowButton.backgroundColor = .customTabBar
    }
    
    @objc private func tomorrowButtonTapped() {
        setSelectedDate(Date().addingTimeInterval(24 * 60 * 60)) // Add 1 day (24 hours) to the current date
        tomorrowButton.backgroundColor = .systemGreen
        todayButton.backgroundColor = .customTabBar
    }
    
    @objc private func datePickerValueChanged() {
        setSelectedDate(datePicker.date)
        todayButton.backgroundColor = .customTabBar
        tomorrowButton.backgroundColor = .customTabBar
    }
    
    private func setSelectedDate(_ date: Date) {
        selectedDate = date
    }
}
