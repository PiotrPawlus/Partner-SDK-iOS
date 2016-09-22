//
//  CheckoutTableViewController.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

enum CheckoutSection: Int, CountableIntEnum {
    case
    ReservationInfo,
    PersonalInfo,
    PaymentInfo
    
    func reuseIdentifier() -> String {
        switch self {
        case .ReservationInfo:
            return ReservationInfoTableViewCell.reuseIdentifier
        case .PersonalInfo:
            return PersonalInfoTableViewCell.reuseIdentifier
        case .PaymentInfo:
            return PaymentInfoTableViewCell.reuseIdentifier
        }
    }
}

enum ReservationInfoRow: Int, CountableIntEnum {
    case
    Address,
    Starts,
    Ends
    
    func title() -> String {
        switch self {
        case .Address:
            return LocalizedStrings.Address
        case .Starts:
            return LocalizedStrings.Starts
        case .Ends:
            return LocalizedStrings.Ends
        }
    }
}

enum PersonalInfoRow: Int, CountableIntEnum {
    case
    FullName,
    Email,
    Phone,
    License
    
    func title() -> String {
        switch self {
        case .FullName:
            return LocalizedStrings.FullName
        case .Email:
            return LocalizedStrings.Email
        case .Phone:
            return LocalizedStrings.Phone
        case .License:
            return LocalizedStrings.LicensePlate
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .FullName:
            return LocalizedStrings.EnterFullName
        case .Email:
            return LocalizedStrings.EnterEmailAddress
        case .Phone:
            return LocalizedStrings.EnterPhoneNumber
        case .License:
            return LocalizedStrings.EnterLicensePlate
        }
    }
}

class CheckoutTableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet var toolbar: UIToolbar!
    
    private let reservationCellHeight: CGFloat = 86
    private let paymentButtonHeight: CGFloat = 60
    private let paymentButtonMargin: CGFloat = 0
    
    private lazy var paymentButton: UIButton = {
        let _button = NSBundle.shp_resourceBundle()
            .loadNibNamed(String(PaymentButton),
                          owner: nil,
                          options: nil)
            .first as! UIButton
        _button.addTarget(self,
                          action: #selector(self.paymentButtonPressed),
                          forControlEvents: .TouchUpInside)
        _button.backgroundColor = .shp_mutedGreen()
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    
    var facility: Facility?
    var rate: Rate?
    var indexPathsToValidate = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.setupPaymentButton()
        self.registerForKeyboardNotifications()
    }
    
    private func setupPaymentButton() {
        guard let
            rate = self.rate,
            price = NumberFormatter.dollarNoCentsStringFromCents(rate.price) else {
            return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: self.paymentButtonHeight,
                                                   right: 0)
        self.paymentButton.setTitle(String(format: LocalizedStrings.paymentButtonTitleFormat, price), forState: .Normal)
        self.view.addSubview(self.paymentButton)
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-margin-[paymentButton]-margin-|",
                                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                                   metrics: ["margin": paymentButtonMargin],
                                                                                   views: ["paymentButton": paymentButton])
        let verticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[paymentButton(height)]-margin-|",
                                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                                metrics: ["margin": paymentButtonMargin, "height": paymentButtonHeight],
                                                                                views: ["paymentButton": paymentButton])
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalContraints)
    }
    
    //MARK: Actions
    
    func paymentButtonPressed() {
        ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
        self.getStripeToken {
            [weak self]
            token in
            guard let token = token else {
                ProgressHUD.hideHUDForView(self?.view)
                return
            }
            
            self?.createReservation(token) {
                success in
                ProgressHUD.hideHUDForView(self?.view)
                if success {
                    self?.performSegueWithIdentifier(Constants.Segue.Confirmation, sender: nil)
                } else {
                    AlertView.presentErrorAlertView(message: LocalizedStrings.CreateReservationErrorMessage, from: self)
                }
            }
        }
    }
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    //MARK: Helpers
    
    /**
     Gets a stripe token for the user's credit card
     
     - parameter completion: Passes in stripe token if it is able to create it. Otherwise nil is passed in.
     */
    func getStripeToken(completion: (String?) -> ()) {
        guard let paymentCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: CheckoutSection.PaymentInfo.rawValue)) as? PaymentInfoTableViewCell else {
            assertionFailure("Cannot get payment cell")
            completion(nil)
            return
        }
        
        StripeWrapper.getToken(paymentCell.cardNumber,
                               expirationMonth: paymentCell.expirationMonth,
                               expirationYear: paymentCell.expirationYear,
                               cvc: paymentCell.cvc) {
                                [weak self]
                                token, error in
                                guard let token = token else {
                                    if let error = error as? StripeAPIError {
                                        switch error {
                                        case .CannotGetToken(let message):
                                            AlertView.presentErrorAlertView(message: message, from: self)
                                        }
                                    } else {
                                        AlertView.presentErrorAlertView(message: LocalizedStrings.CreateReservationErrorMessage, from: self)
                                    }
                                    completion(nil)
                                    return
                                }
                                
                                completion(token)
        }
    }
    
    /**
     creates the reservation. ONLY CALL AFTER GETTING STRIPE TOKEN
     
     - parameter token:      Stripe Token
     - parameter completion: Passing in a bool. True if reservation was successfully created, false if an error occured
     */
    func createReservation(token: String, completion: (Bool) -> ()) {
        guard let
            facility = self.facility,
            rate = self.rate else {
                assertionFailure("No facility or rate")
                completion(false)
                return
        }
        
        guard let
            emailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: PersonalInfoRow.Email.rawValue, inSection: CheckoutSection.PersonalInfo.rawValue)) as? PersonalInfoTableViewCell,
            email = emailCell.textField.text else {
                assertionFailure("Cannot get email cell")
                completion(false)
                return
        }
        
        var license: String?
        
        if let
            licenseCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: PersonalInfoRow.Email.rawValue, inSection: CheckoutSection.PersonalInfo.rawValue)) as? PersonalInfoTableViewCell
            where facility.licensePlateRequired {
            license = licenseCell.textField.text
        }
        
        ReservationAPI.createReservation(facility,
                                         rate: rate,
                                         email: email,
                                         stripeToken: token,
                                         license: license,
                                         completion: {
                                            reservation, error in
                                            guard let reservation = reservation else {
                                                completion(false)
                                                return
                                            }
                                            
                                            completion(true)
        })
    }
    
    private func configureCell(cell: ReservationInfoTableViewCell,
                       row: ReservationInfoRow,
                       facility: Facility,
                       rate: Rate) {
        cell.titleLabel.text = row.title()
        
        switch row {
        case ReservationInfoRow.Address:
            cell.primaryLabel.text = facility.streetAddress
            cell.secondaryLabel.text = "\(facility.city), \(facility.state)"
        case ReservationInfoRow.Starts:
            cell.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.starts)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.starts))"
            cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.starts)
        case ReservationInfoRow.Ends:
            cell.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.ends)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.ends))"
            cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.ends)
        }
    }
    
    private func configureCell(cell: PersonalInfoTableViewCell, row: PersonalInfoRow) {
        cell.titleLabel.text = row.title()
        cell.textField.placeholder = row.placeholder()
        cell.textField.inputAccessoryView = self.toolbar
        cell.type = row
        
        switch row {
        case PersonalInfoRow.FullName:
            cell.textField.autocapitalizationType = .Words
            cell.validationClosure = {
                fullName in
                try Validator.validateFullName(fullName)
            }
        case PersonalInfoRow.Email:
            cell.textField.autocapitalizationType = .None
            cell.textField.keyboardType = .EmailAddress
            cell.validationClosure = {
                email in
                try Validator.validateEmail(email)
            }
        case PersonalInfoRow.Phone:
            cell.textField.keyboardType = .PhonePad
            cell.validationClosure = {
                phone in
                try Validator.validatePhone(phone)
            }
        case PersonalInfoRow.License:
            cell.textField.autocapitalizationType = .AllCharacters
            cell.valid = true
            cell.validationClosure = {
                license in
                try Validator.validateLicense(license)
            }
        }
    }
    
    private func setPaymentButtonEnabled(enabled: Bool) {
        self.paymentButton.enabled = enabled
        self.paymentButton.backgroundColor = enabled ? .shp_green() : .shp_mutedGreen()
    }
}

//MARK: UITableViewDataSource

extension CheckoutTableViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CheckoutSection.AllCases.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let checkoutSection = CheckoutSection(rawValue: section) else {
            assertionFailure("Could not create a checkout section. Section number: \(section)")
            return 0
        }
        switch checkoutSection {
        case .ReservationInfo:
            return ReservationInfoRow.AllCases.count
        case .PersonalInfo:
            guard let licensePlateRequired = facility?.licensePlateRequired where licensePlateRequired else {
                return PersonalInfoRow.AllCases.count - 1
            }
            return PersonalInfoRow.AllCases.count
        case .PaymentInfo:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let section = CheckoutSection(rawValue: indexPath.section) {
            cell = tableView.dequeueReusableCellWithIdentifier(section.reuseIdentifier(), forIndexPath: indexPath)
        } else {
            assertionFailure("Cannot get the section")
            cell = UITableViewCell()
        }
        
        if let
            cell = cell as? ReservationInfoTableViewCell,
            facility = self.facility,
            rate = self.rate,
            row = ReservationInfoRow(rawValue: indexPath.row) {
            
            self.configureCell(cell,
                               row: row,
                               facility: facility,
                               rate: rate)
        } else if let
            cell = cell as? PersonalInfoTableViewCell,
            row = PersonalInfoRow(rawValue: indexPath.row) {
            
            self.configureCell(cell, row: row)
        } else if let cell = cell as? PaymentInfoTableViewCell {
            cell.creditCardTextField.inputAccessoryView = self.toolbar
            cell.expirationDateTextField.inputAccessoryView = self.toolbar
            cell.cvcTextField.inputAccessoryView = self.toolbar
        }
        
        if let cell = cell as? ValidatorCell {
            self.indexPathsToValidate.append(indexPath)
            cell.delegate = self
        }
        
        return cell
    }
}

//MARK: UITableViewDelegate

extension CheckoutTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case CheckoutSection.ReservationInfo.rawValue:
            return self.reservationCellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let checkoutSection = CheckoutSection(rawValue: section) else {
            return nil
        }
        
        switch checkoutSection {
        case CheckoutSection.ReservationInfo:
            return LocalizedStrings.ReservationInfo
        case CheckoutSection.PersonalInfo:
            return LocalizedStrings.PersonalInfo
        case CheckoutSection.PaymentInfo:
            return LocalizedStrings.PaymentInfo
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}

//MARK: ValidatorCellDelegate

extension CheckoutTableViewController: ValidatorCellDelegate {
    func didValidateText() {
        var invalidCells = 0
        for indexPath in self.indexPathsToValidate {
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ValidatorCell where !cell.valid {
                invalidCells += 1
            }
        }
        self.setPaymentButtonEnabled(invalidCells == 0)
    }
}

// MARK: - KeyboardNotification

extension CheckoutTableViewController: KeyboardNotification {
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
                                                                object: nil,
                                                                queue: nil) {
                                                                    [weak self]
                                                                    notification in
                                                                    guard let
                                                                        userInfo = notification.userInfo,
                                                                        frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                                                                            return
                                                                    }
                                                                    
                                                                    let rect = frame.CGRectValue()
                                                                    self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
                                                                object: nil,
                                                                queue: nil) {
                                                                    [weak self]
                                                                    notification in
                                                                    guard let paymentButtonHeight = self?.paymentButtonHeight else {
                                                                        return
                                                                    }
                                                                    
                                                                    self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: paymentButtonHeight, right: 0)
        }
    }
}
