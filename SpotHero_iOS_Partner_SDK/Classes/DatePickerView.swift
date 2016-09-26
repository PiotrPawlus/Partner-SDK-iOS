//
//  DatePickerView.swift
//  Pods
//
//  Created by Husein Kareem on 8/2/16.
//
//

import UIKit

protocol DatePickerViewDelegate: class {
    func didPressDoneButton()
    func didChangeDatePickerValue(date: NSDate)
}

protocol DatePickerDoneButtonDelegate: class {
    func didPressDoneButton()
}

class DatePickerView: UIView {
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var toolbar: UIToolbar!
    @IBOutlet weak private var datePickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var toolbarTitleLabel: UILabel!
    
    weak var doneButtonDelegate: DatePickerDoneButtonDelegate?
    weak var delegate: DatePickerViewDelegate?
    
    private let DatePickerViewHeight: CGFloat = 200
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupDatePickerView()
    }
    
    private func setupDatePickerView() {
        self.datePickerViewBottomConstraint.constant = -self.DatePickerViewHeight
        self.datePicker.minimumDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
        self.datePicker.date = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
    }
    
    /**
     Show or hide date picker view
     
     - parameter show: pass in true to show, false to hide
     */
    func showDatePickerView(show: Bool) {
        UIView.animateWithDuration(Constants.ViewAnimationDuration) {
            self.datePickerViewBottomConstraint.constant = show ? 0 : -self.DatePickerViewHeight
            self.layoutIfNeeded()
        }
    }
    
    @IBAction private func doneButtonPressed(sender: AnyObject) {
        self.delegate?.didPressDoneButton()
        self.doneButtonDelegate?.didPressDoneButton()
    }
    
    @IBAction private func datePickerValueDidChange(datePicker: UIDatePicker) {
        self.delegate?.didChangeDatePickerValue(datePicker.date)
    }
    
}

//MARK: TimeSelectionViewDelegate

extension DatePickerView: TimeSelectionViewDelegate {
    func didTapStartView(startDate: NSDate, endDate: NSDate) {
        self.showDatePickerView(true)
        self.datePicker.minimumDate = startDate
        self.datePicker.date = startDate
        self.toolbarTitleLabel.text = LocalizedStrings.SetStartTime
    }
    
    func didTapEndView(startDate: NSDate, endDate: NSDate) {
        self.showDatePickerView(true)
        self.datePicker.minimumDate = startDate.shp_roundDateToNearestHalfHour(roundDown: false)
        self.datePicker.maximumDate = nil
        self.datePicker.date = endDate
        self.toolbarTitleLabel.text = LocalizedStrings.SetEndTime
    }
    
    func timeSelectionViewShouldHide() {
        self.showDatePickerView(false)
    }
}
