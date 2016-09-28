//
//  CollapsedSearchBarView.swift
//  Pods
//
//  Created by Matthew Reed on 7/18/16.
//
//

import UIKit

class CollapsedSearchBarView: UIView {
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var chevron: UIImageView!
    
    var hours: Double = 0 {
        didSet {
            let hoursLeftOver = self.hours % 24
            let days = Int(self.hours / 24)
            
            if days > 0 {
                let format = (floor(hoursLeftOver) == hoursLeftOver) ? LocalizedStrings.HoursAndDaysBetweenDatesFormat : LocalizedStrings.HoursAndDaysBetweenDatesFormatDecimal
                self.timeLabel.text = String(format: format, days, hoursLeftOver)
            } else {
                let format = (floor(hoursLeftOver) == hoursLeftOver) ? LocalizedStrings.HoursBetweenDatesFormat : LocalizedStrings.HoursBetweenDatesFormatDecimal
                self.timeLabel.text = String(format: format, hoursLeftOver)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessibilityLabel = AccessibilityStrings.CollapsedSearchBarView
    }
    
    /**
     Show or hide collapsed search bar
     
     - parameter show: pass in true to show, false to hide
     */
    func showCollapsedSearchBar(show: Bool) {
        UIView.animateWithDuration(Constants.ViewAnimationDuration,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
                                    self.alpha = show ? 1 : 0
        }) {
            finished in
            self.hidden = !show
        }
    }
    
    /**
     Show collapsed search bar
     */
    func show() {
        self.showCollapsedSearchBar(true)
    }
    
    /**
     Hide collapsed search bar
     */
    func hide() {
        self.showCollapsedSearchBar(false)
    }
}
