//
//  DatePickerViewController.swift
//  ECExpert
//
//  Created by Fran on 15/7/14.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

typealias DatePickerSelectDateStrFunc = ((selectDate: NSDate) -> Void)

class DatePickerViewController: BasicViewController , FSCalendarDataSource, FSCalendarDelegate{
    
    private let PLUS_YEAR_SWIPE_TAG = 10
    private let MINUS_YEAR_SWIPE_TAG = 11
    
    private let dateString = "yyyy-MM-dd"
    private let dateFormatter = NSDateFormatter()
    
    private var fsCalendar: FSCalendar!
    
    private var scrollToSelectButton: UIButton!
    private var scrollToTodayButton: UIButton!
    
    var minDate: NSDate?
    var maxDate: NSDate?
    var autoSelectedDate: NSDate?
    
    private var finishSelect: DatePickerSelectDateStrFunc?

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = dateString
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "selectDate")
        
        setUpPageViews()
        
        // 添加修改年份的手势
        let swipePlusGesture = UISwipeGestureRecognizer(target: self, action: "plusYear")
        if fsCalendar.flow == FSCalendarFlow.Horizontal{
            swipePlusGesture.direction = UISwipeGestureRecognizerDirection.Up
        }else{
            swipePlusGesture.direction = UISwipeGestureRecognizerDirection.Right
        }
        fsCalendar.addGestureRecognizer(swipePlusGesture)
        
        let swipeMinusGesture = UISwipeGestureRecognizer(target: self, action: "minusYear")
        if fsCalendar.flow == FSCalendarFlow.Horizontal{
            swipeMinusGesture.direction = UISwipeGestureRecognizerDirection.Down
        }else{
            swipeMinusGesture.direction = UISwipeGestureRecognizerDirection.Left
        }
        fsCalendar.addGestureRecognizer(swipeMinusGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func plusYear(){
        let currentMonth = fsCalendar.currentMonth
        let year = currentMonth.fs_year
        let month = currentMonth.fs_month
        let day = 1
        
        fsCalendar.scrollToDate(NSDate.fs_dateWithYear(year + 1, month: month, day: day), animate: true)
    }
    
    func minusYear(){
        let currentMonth = fsCalendar.currentMonth
        let year = currentMonth.fs_year
        let month = currentMonth.fs_month
        let day = 1
        
        fsCalendar.scrollToDate(NSDate.fs_dateWithYear(year - 1, month: month, day: day), animate: true)
    }
    
    func setFinishSelect(finishSelect: DatePickerSelectDateStrFunc){
        self.finishSelect = finishSelect
    }
    
    func selectDate(){
        if finishSelect != nil{
            finishSelect!(selectDate: fsCalendar.selectedDate!)
        }
        
        self.goback()
    }
    
    func setUpPageViews(){
        let visible = getVisibleFrame()
        let vH = visible.origin.y
        let vW = visible.size.width
        let calendarH: CGFloat = visible.size.height *  2 / 3
        
        fsCalendar = FSCalendar(frame: CGRectMake(0, vH, vW, calendarH))
        
        fsCalendar.dataSource = self
        fsCalendar.delegate = self
        fsCalendar.headerTitleColor = UIColor.redColor()
        fsCalendar.headerDateFormat = "yyyy-MMMM"
        fsCalendar.selectionColor = RGB(42, 179, 233)
        fsCalendar.firstWeekday = UInt(NSCalendar.currentCalendar().firstWeekday)
        
        fsCalendar.todayColor = RGB(234, 47, 75)
        
        
        fsCalendar.currentDate = NSDate()
        if autoSelectedDate != nil{
            fsCalendar.selectedDate = autoSelectedDate
        }
        
        self.view.addSubview(fsCalendar)
        
        let buttonH: CGFloat = 30
        let buttonPadding: CGFloat = 20
        let buttonW: CGFloat = (vW - 3 * buttonPadding) / 2.0
        let buttonY: CGFloat = vH + calendarH + buttonPadding
        
        let leftButtonFrame = CGRectMake(0 + buttonPadding, buttonY, buttonW, buttonH)
        let leftButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        leftButton.frame = leftButtonFrame
        leftButton.layer.cornerRadius = buttonH / 2.0
        leftButton.layer.masksToBounds = true
        leftButton.setTitle(i18n("Today"), forState: UIControlState.Normal)
        leftButton.backgroundColor = fsCalendar.todayColor
        leftButton.addTarget(self, action: "scrollToDateAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollToTodayButton = leftButton
        self.view.addSubview(scrollToTodayButton)
        
        let rightButtonFrame = CGRectMake(0 + buttonW + buttonPadding * 2, buttonY, buttonW, buttonH)
        let rightButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        rightButton.frame = rightButtonFrame
        rightButton.layer.cornerRadius = buttonH / 2.0
        rightButton.layer.masksToBounds = true
        rightButton.setTitle(i18n("Selected Date"), forState: UIControlState.Normal)
        rightButton.backgroundColor = fsCalendar.selectionColor
        rightButton.addTarget(self, action: "scrollToDateAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollToSelectButton = rightButton
        self.view.addSubview(scrollToSelectButton)
    }
    
    func scrollToDateAction(sender: AnyObject!){
        if sender as! UIButton == scrollToTodayButton{
            fsCalendar.scrollToDate(fsCalendar.currentDate, animate: true)
        }else if sender as! UIButton == scrollToSelectButton{
            fsCalendar.scrollToDate(fsCalendar.selectedDate, animate: true)
        }
    }
    
    // MARK: - FSCalendarDataSource
    func minimumDateForCalendar(calendar: FSCalendar!) -> NSDate! {
        if minDate != nil{
            return minDate!
        }
        return NSDate.fs_dateWithYear(1970, month: 1, day: 1)
    }
    
    func maximumDateForCalendar(calendar: FSCalendar!) -> NSDate! {
        if maxDate != nil{
            return maxDate!
        }
        return NSDate.fs_dateWithYear(2099, month: 12, day: 31)
    }
    
    // MARK: - FSCalendarDelegate
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        KMLog("didSelectDate: \(date.fs_stringWithFormat(dateString))  date: \(date)  today: \(NSDate())")
    }
    
    func calendar(calendar: FSCalendar!, shouldSelectDate date: NSDate!) -> Bool {
        var canSelect = true
        
        if date != nil{
            let selectStr = date.fs_stringWithFormat(dateString)
            var minStr: String?
            var maxStr: String?
            
            if minDate != nil{
                minStr = dateFormatter.stringFromDate(minDate!)
                if minStr!.compare(selectStr!) == NSComparisonResult.OrderedDescending{
                    canSelect = false
                }
            }
            
            if maxDate != nil{
                maxStr = dateFormatter.stringFromDate(maxDate!)
                if maxStr!.compare(selectStr!) == NSComparisonResult.OrderedAscending{
                    canSelect = false
                }
            }
            
            if !canSelect{
                var errorMsg = i18n("The selected date must")
                if minStr != nil{
                    errorMsg = errorMsg + "\n" + i18n(">=") + minStr!
                }
                if maxStr != nil{
                    errorMsg = errorMsg + "\n" + i18n("<=") + maxStr!
                }
                
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.labelText = i18n("")
                self.progressHUD?.detailsLabelText = errorMsg
                self.progressHUD?.show(true)
                self.progressHUD?.hide(true, afterDelay: 2)
            }
        }
        
        return canSelect
    }
    
    func calendarCurrentMonthDidChange(calendar: FSCalendar!) {
        let str = calendar.currentMonth.fs_stringWithFormat("yyyy-MM")
        let selectMonth = calendar.selectedDate.fs_stringWithFormat("yyyy-MM")
        
        KMLog("calendarCurrentMonthDidChange: \(str)    selectMonth :  \(selectMonth)")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
