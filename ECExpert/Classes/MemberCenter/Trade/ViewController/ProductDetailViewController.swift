//
//  ProductDetailViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/26.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

enum ProductDetailPageDataType: Int{
    case Main = 0
    case Gift
}

enum ProductDetailPageEditType: Int{
    case None = 0
    case Dispatch, All
}

class ProductDetailViewController: BasicViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    static let CellIdentifier = "CellIdentifier"
    static let CellLeftTag = 10
    static let CellRightTag = 11
    static let AddButtonTag = 20
    static let MinusButtonTag = 21

    private var pageDataType: ProductDetailPageDataType
    private var pageEditType: ProductDetailPageEditType
    
    private var fromTableView: UITableView
    
    private var product: ProductModel
    private var productArray: NSMutableArray
    
    private var tableView: UITableView!
    private var textField: UITextField!
    
    init(product: ProductModel, productArray: NSMutableArray, fromTableView: UITableView, pageDataType: ProductDetailPageDataType, pageEditType: ProductDetailPageEditType){
        self.product = product
        self.productArray = productArray
        self.fromTableView = fromTableView
        self.pageDataType = pageDataType
        self.pageEditType = pageEditType
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        
        switch pageDataType{
        case .Main:
            self.title = i18n("Product detail")
        case .Gift:
            self.title = i18n("Gift detail")
        }
        
        setUpView()
        
        if pageEditType != ProductDetailPageEditType.None{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "commitChanges")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func commitChanges(){
        let totalCount = (textField.text as NSString).integerValue
        product.totalCount = totalCount
        fromTableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setUpView(){
        tableView = TPKeyboardAvoidingTableView(frame: getVisibleFrame()) as UITableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RGBA(0, 0, 0, 0.3)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.view.addSubview(tableView)
    
    }
    
    override func goback() {
        if pageEditType == ProductDetailPageEditType.All || pageEditType == ProductDetailPageEditType.Dispatch{
            let alertView = UIAlertView(title: i18n("Give up the change?"), message: i18n("Give up modifying data?"), delegate: nil, cancelButtonTitle: i18n("Sure"), otherButtonTitles: i18n("Cancel"))
            alertView.showAlertViewWithCompleteBlock {(buttonIndex) -> Void in
                if buttonIndex == 0{
                    super.goback()
                }
            }
        }else{
            super.goback()
        }
    }
    
    func changeProductCountAction(sender: AnyObject!){
        let btn = sender as! UIButton
        let tag = btn.tag
        var totalCount = (textField.text as NSString).integerValue
        
        if tag == ProductDetailViewController.AddButtonTag{
            totalCount++
        }else if tag == ProductDetailViewController.MinusButtonTag{
            totalCount--
        }
        if totalCount < 0{
            totalCount = 0
        }
        
        textField.text = "\(totalCount)"
        
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch pageDataType{
        case .Main:
            return 7
        case .Gift:
            return 7
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: ProductDetailViewController.CellIdentifier, cellType: UITableViewCellStyle.Subtitle, cleanCellContentView: false) { (tableViewCell: UITableViewCell!) -> Void in
            
            tableViewCell!.backgroundColor = UIColor.clearColor()
            
            let cellFrame = tableViewCell!.frame
            let leftFrame = CGRectMake(0, 0, cellFrame.size.width / 2.0, cellFrame.size.height)
            let leftView = UIView(frame: leftFrame)
            leftView.tag = ProductDetailViewController.CellLeftTag
            leftView.backgroundColor = UIColor.clearColor()
            
            let rightFrame = CGRectMake(0 + leftFrame.size.width , 0, cellFrame.size.width / 2.0, cellFrame.size.height)
            let rightView = UIView(frame: rightFrame)
            rightView.tag = ProductDetailViewController.CellRightTag
            rightView.backgroundColor = UIColor.clearColor()
            
            tableViewCell!.contentView.addSubview(leftView)
            tableViewCell!.contentView.addSubview(rightView)
        }
        
        var leftView = cell?.contentView.viewWithTag(ProductDetailViewController.CellLeftTag)
        var rightView = cell?.contentView.viewWithTag(ProductDetailViewController.CellRightTag)
        
        for view in leftView!.subviews{
            view.removeFromSuperview()
        }
        
        for view in rightView!.subviews{
            view.removeFromSuperview()
        }
        
        let leftLabel = UILabel(frame: leftView!.bounds)
        leftLabel.numberOfLines = 0
        leftLabel.textColor = UIColor.whiteColor()
        
        let rightLabel = UILabel(frame: rightView!.bounds)
        rightLabel.numberOfLines = 0
        rightLabel.textColor = UIColor.whiteColor()
        
        let row = indexPath.row
        
        if row == 0{
            leftLabel.text = i18n("Product name") + ":"
            rightLabel.text = product.productNameZH.isEmpty ? product.productNameEN : product.productNameZH
            
        }else if row == 1{
            leftLabel.text = i18n("Product bar code") + ":"
            rightLabel.text = product.scanCode
        }else if row == 2{
            
            leftLabel.text = i18n("Product count") + ":"
            rightLabel.text = "\(product.totalCount)"
            
            
        }else if row == 3{
            leftLabel.text = i18n("Brand name") + ":"
            rightLabel.text = product.brandName
        }else if row == 4{
            leftLabel.text = i18n("Specifications and models") + ":"
            rightLabel.text = product.specifications
        }else if row == 5{
            leftLabel.text = i18n("Country of origin") + ":"
            rightLabel.text = product.originCountry
        }else{
            leftLabel.text = i18n("Assembly country") + ":"
            rightLabel.text = product.assembleCountry
        }
        
        if (row != 2 && (pageEditType == ProductDetailPageEditType.All || pageEditType == ProductDetailPageEditType.Dispatch ) || pageEditType == ProductDetailPageEditType.None){
            let leftSize = leftLabel.sizeThatFits(CGSizeMake(leftView!.frame.size.width - 10, 0))
            leftLabel.frame = CGRectMake(10, (leftView!.frame.height - leftSize.height) / 2.0, leftSize.width, leftSize.height)
            leftView?.addSubview(leftLabel)
            
            let rightSize = rightLabel.sizeThatFits(CGSizeMake(rightView!.frame.size.width - 10, 0))
            rightLabel.frame = CGRectMake(0, (rightView!.frame.height - rightSize.height) / 2.0, rightSize.width, rightSize.height)
            rightView?.addSubview(rightLabel)
        }else{
            let leftSize = leftLabel.sizeThatFits(CGSizeMake(leftView!.frame.size.width, 0))
            leftLabel.frame = CGRectMake(10, (leftView!.frame.height - leftSize.height) / 2.0, leftSize.width, leftSize.height)
            leftView?.addSubview(leftLabel)
            
            
            let minusFrame = CGRectMake(0, (rightView!.frame.size.height - 22) / 2.0, 22, 22)
            let textFrame = CGRectMake(minusFrame.origin.x + minusFrame.size.width, (rightView!.frame.size.height - 22) / 2.0, 60, 22)
            let addFrame = CGRectMake(textFrame.origin.x + textFrame.size.width, (rightView!.frame.size.height - 30) / 2.0, 30, 30)
            
            let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
            addButton.frame = addFrame
            addButton.tag = ProductDetailViewController.AddButtonTag
            addButton.tintColor = UIColor.redColor()
            addButton.addTarget(self, action: "changeProductCountAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            textField = UITextField(frame: textFrame)
            textField.backgroundColor = UIColor.clearColor()
            textField.delegate = self
            textField.keyboardType = UIKeyboardType.DecimalPad
            textField.text = rightLabel.text
            textField.textAlignment = NSTextAlignment.Center
            
            let minusButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            minusButton.frame = minusFrame
            minusButton.tag = ProductDetailViewController.MinusButtonTag
            minusButton.backgroundColor = UIColor.clearColor()
            minusButton.setImage(UIImage(named: "button_minus"), forState: UIControlState.Normal)
            minusButton.addTarget(self, action: "changeProductCountAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            rightView!.addSubview(minusButton)
            rightView!.addSubview(textField)
            rightView!.addSubview(addButton)
        
        }
        
        return cell!
    }
    
    
    // MARK: - UITableViewDelegate
    
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let intValue: NSInteger? = (string as NSString).integerValue
        if intValue == 0 && string != "0"{
            return false
        }else{
            return true
        }
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
