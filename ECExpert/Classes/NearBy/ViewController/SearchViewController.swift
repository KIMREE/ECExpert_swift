//
//  SearchViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/18.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class SearchViewController: BasicViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    weak var rootMapViewController: NearByViewController!
    var currentLocation: MKUserLocation!
    var dealerArray:NSArray!
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    private var dealerArrayWithDistance: NSArray!
    private var tableViewDataArray: NSArray!
    private var pageSize = 10
    private var pageNo = 0
    
    private var filterKeyArray: NSArray!
    static let cellIdentifier = "CellIdentifier"
    
    deinit{
        KMLog("SearchViewController deinit")
    }
    
    override func goback() {
        // 如果界面正在加载数据，此时不能goback
        if self.navigationItem.leftBarButtonItem != nil && self.navigationItem.leftBarButtonItem!.enabled{
            super.goback()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = i18n("Search")
        
        let viewFrame = getVisibleFrame()
        var searchBarFrame = viewFrame
        searchBarFrame.size.height = 44
        setUpSearchBar(searchBarFrame)
        
        var tableViewFrame = viewFrame
        tableViewFrame.origin.y += 44
        tableViewFrame.size.height -= 44
        setUpTableView(tableViewFrame)
        
        // 界面加载数据时不允许返回上级界面
        self.navigationItem.leftBarButtonItem?.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpSearchBar(frame: CGRect){
        searchBar = UISearchBar(frame: frame)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        self.view.addSubview(searchBar)
    }
    
    func setUpTableView(frame: CGRect){
        tableView = UITableView(frame: frame, style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tableView)
        
        tableView.tableHeaderView = UIView(frame: CGRectZero)
        
        tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "refresh")
        tableView.footer.beginRefreshing()
    }
    
    // 上拉刷新
    func refresh(){
        // 界面加载数据时不允许返回上级界面
        self.navigationItem.leftBarButtonItem?.enabled = false
        
        if dealerArrayWithDistance == nil{
            setUpDistanceArray()
        }
        
        // 模拟网络延迟
        let random = UInt64(arc4random_uniform(3))
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * random))
        
        // 注意： 这里在gcd里面对界面ui有影响，必须在主线程中执行， 如果在after执行过程中销毁了self，程序会崩溃
        dispatch_after(delay, dispatch_get_main_queue()) {[unowned self] () -> Void in
            let totalPageNo: Int = self.tableViewDataArray.count % self.pageSize == 0 ?  self.tableViewDataArray.count / self.pageSize : self.tableViewDataArray.count % self.pageSize + 1
            if self.pageNo < totalPageNo{
                self.pageNo++
//                self.tableView.reloadData()
                self.tableViewReloadData()
            }
            self.tableView.footer.endRefreshing()
            
            // 界面刷新完毕后， 返回按钮可以点击
            self.navigationItem.leftBarButtonItem?.enabled = true
        }
    }
    
    func setUpDistanceArray(){
        var unsorted = NSMutableArray()
        if dealerArray != nil && currentLocation.location != nil{
            unsorted = DealerHelper.distanceFromCurrentLocation(currentLocation.location, dealerArray: dealerArray)
            filterKeyArray = ["dealer_name","dealer_desc","dealer_address","dealer_distance"]
        }else{
            unsorted = NSMutableArray(array: dealerArray)
            filterKeyArray = ["dealer_name","dealer_desc","dealer_address","dealer_province","dealer_city","dealer_area"]
        }
        dealerArrayWithDistance = NSArray(array: unsorted)
        tableViewDataArray = dealerArrayWithDistance
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewDataArray == nil{
            return 0
        }
        
        var rowNums = pageSize*(pageNo)
        if rowNums > self.tableViewDataArray.count{
            rowNums = self.tableViewDataArray.count
        }
        
        return rowNums
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: SearchViewController.cellIdentifier, cellType: UITableViewCellStyle.Subtitle) {(tableViewCell: UITableViewCell!) -> Void in
            // 调整显示cell imageview下面的分割线
            tableViewCell!.separatorInset = UIEdgeInsetsZero
            // 左边图片
            tableViewCell!.imageView!.image = UIImage(named: "dealerSearch")
            // title
            tableViewCell!.textLabel!.numberOfLines = 0
            tableViewCell!.textLabel!.font = UIFont(name: "Arial-BoldItalicMT", size: 14)
            // subtitle
            tableViewCell!.detailTextLabel!.textColor = RGB(26,188,156)
            tableViewCell!.detailTextLabel!.font = UIFont.systemFontOfSize(14)
            // select background
            tableViewCell!.selectedBackgroundView = UIView(frame: tableViewCell!.frame)
            tableViewCell!.selectedBackgroundView.backgroundColor = RGB(200, 200, 200)
        }
        
        let cellInfo = self.tableViewCellInfoWithIndexPath(indexPath)
        cell!.textLabel!.text = cellInfo.title
        cell!.detailTextLabel?.text = cellInfo.subtitle
        
        return cell!
    }
    
    func tableViewCellInfoWithIndexPath(indexPath: NSIndexPath) -> (title: String!, subtitle: String!){
        var title = ""
        var subtitle = ""
        let dealer = tableViewDataArray[indexPath.row] as! NSDictionary
        
        let dealerName = dealer["dealer_name"] as? String ?? ""
        let dealerAddress = dealer["dealer_address"] as? String ?? ""
        title = "\(dealerName)\n\(dealerAddress)"
        
        let distance = dealer["dealer_distance"] as? String
        if distance != nil{
            let unit = i18n("km")
            subtitle = "\(distance!)\(unit)"
        }else{
            let province = dealer["dealer_province"] as? String ?? ""
            let city = dealer["dealer_city"] as? String ?? ""
            let area = dealer["dealer_area"] as? String ?? ""
            subtitle = "\(province)\(city)\(area)"
        }
        return (title: title, subtitle: subtitle)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellInfo = tableViewCellInfoWithIndexPath(indexPath)
        let titleLabel = UILabel(frame: CGRectZero)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "Arial-BoldItalicMT", size: 14)
        titleLabel.text = cellInfo.title
        
        let subtitleLabel = UILabel(frame: CGRectZero)
        subtitleLabel.font = UIFont.systemFontOfSize(14)
        subtitleLabel.text = cellInfo.subtitle
        
        let titleSize = titleLabel.sizeThatFits(CGSizeMake(KM_FRAME_SCREEN_WIDTH - 60, 0))
        let subtitleSize = subtitleLabel.sizeThatFits(CGSizeMake(KM_FRAME_SCREEN_WIDTH - 60, 0))
        
        var result = titleSize.height + subtitleSize.height + 30
        if result < 44{
            result = 44
        }
        return result
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dealer = tableViewDataArray[indexPath.row] as! NSDictionary
        if rootMapViewController != nil{
            if rootMapViewController.dealerViewController == nil{
                rootMapViewController.dealerViewController = DealerDetailViewController()
                rootMapViewController.dealerViewController.delegate = rootMapViewController
            }
            
            rootMapViewController.dealerViewController.dealer = dealer
            rootMapViewController.dealerViewController.tableView?.reloadData()
            
            KMLog("\(dealer)")
            
            self.navigationController?.pushViewController(rootMapViewController.dealerViewController, animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchInfoInArray(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchInfoInArray(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
//        searchBar.text = ""
//        searchInfoInArray(searchBar.text)
    }
    
    func searchInfoInArray(filter: String!){
        // 去掉前后空格和换行
        let filter = filter.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let array = NSMutableArray()
        if filter != ""{
            for item in dealerArrayWithDistance{
                var isMatch = false
                let dealer = item as! NSDictionary
                for key in filterKeyArray{
                    let value = dealer.objectForKey(key)?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
                    if value.rangeOfString(filter) != nil{
                        isMatch = true
                        break
                    }
                }
                if isMatch{
                    array.addObject(dealer)
                }
            }
        }else{
            array.addObjectsFromArray(dealerArrayWithDistance as! [AnyObject])
        }
        
        tableViewDataArray = array
        pageNo = 0 // 重置页码
//        self.tableView.reloadData()
        self.tableViewReloadData()
        self.tableView.footer.beginRefreshing()
    }
    
    func tableViewReloadData(){
        self.tableView.reloadData()
        // reloadData后， 
        // 如果 footer 是 MJRefreshBackNormalFooter 类型
        // scroll会向下移动，导致第一行的 cell 无法显示完全
        // 如果pageNo = 1 ,即刚加载完第一页内容时， 需要控制scroll移动到第一行cell的顶部去
        if pageNo - 1 == 0 && self.tableView.footer is MJRefreshBackNormalFooter{
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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
