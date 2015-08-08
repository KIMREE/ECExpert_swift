//
//  DealerDetailViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/18.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

protocol DealerDetailViewControllerDelegate: NSObjectProtocol{
    func dealerDetailShowCalloutInMapView(coordinate: CLLocationCoordinate2D)
}

class DealerDetailViewController: BasicViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let cellIdentifier = "CellIdentifier"
    
    var dealer: NSDictionary!
    
    var tableView: UITableView!
    
    weak var delegate: DealerDetailViewControllerDelegate!
    
    private var logoImageView: UIImageView!
    private var gotoMapLabel: UILabel!
    private var callImageView: UIImageView!
    private var uselessWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = i18n("Dealer information")
        
        setUpOtherView()
        
        setUpTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpOtherView(){
        logoImageView = UIImageView(frame: CGRectMake(0, 0, KM_FRAME_SCREEN_WIDTH, 150))
        let logoStr = dealer["dealer_logo"] as! String
        logoImageView.sd_setImageWithURL(NSURL(string: logoStr), placeholderImage: UIImage(named: "dealerLogo.jpg"))
        
        gotoMapLabel = UILabel(frame: CGRectMake(0, 0, KM_FRAME_SCREEN_WIDTH, 40))
        gotoMapLabel.backgroundColor = KM_COLOR_BUTTON_MAIN
        gotoMapLabel.textColor = UIColor.whiteColor()
        gotoMapLabel.textAlignment = NSTextAlignment.Center
        gotoMapLabel.font = UIFont.systemFontOfSize(13)
        gotoMapLabel.text = i18n("Directions to Here")
        
        callImageView = UIImageView(frame: CGRectMake(KM_FRAME_SCREEN_WIDTH - 44 - 20, 0, 44, 44))
        callImageView.image = UIImage(named: "callImage")
    }
    
    func setUpTableView(){
        let tableViewFrame = getVisibleFrame()
        tableView = UITableView(frame: tableViewFrame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tableView)
    }
    
    func getDealerDistance() -> Double?{
        let dist: AnyObject? = dealer["dealer_distance"]
        if dist == nil {
            return nil
        }else{
            return (dist as! NSString).doubleValue
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            let distance = getDealerDistance()
            if distance == nil{
                return 2
            }else{
                return 3
            }
        }else if section == 1{
            return 3
        }else if section == 2{
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: DealerDetailViewController.cellIdentifier, cellType: UITableViewCellStyle.Subtitle, cleanTextAndImage: true, cleanCellContentView: true) { (tableViewCell: UITableViewCell!) -> Void in
            
            tableViewCell!.selectionStyle = UITableViewCellSelectionStyle.None
            tableViewCell!.userInteractionEnabled = true
        }
        
        // 重置 textLabel
        cell!.textLabel?.font = UIFont.systemFontOfSize(17)
        
        // 重置 textLabel
        cell?.detailTextLabel?.font = UIFont.systemFontOfSize(14)
        
        let section = indexPath.section
        let row = indexPath.row
        cell!.textLabel?.numberOfLines = 0
        
        if section == 0{
            if row == 0{
                cell!.contentView.addSubview(logoImageView)
            }else if row == 1{
                cell!.textLabel?.textColor = RGB(26,188,156)
                let addressDesc = i18n("Dealer address")
                let dealerAddress = dealer["dealer_address"] as! String
                let title = "\(addressDesc):\(dealerAddress)"
                cell!.textLabel?.text = title
                
                cell!.detailTextLabel?.textColor = RGB(17,127,239)
                if let distance = getDealerDistance(){
                    let unit = i18n("km")
                    cell!.detailTextLabel?.text = "\(distance)\(unit)"
                }
            }else if row == 2{
                cell!.contentView.addSubview(gotoMapLabel)
            }
        }else if section == 1{
            if row == 0{
                let nameDesc = i18n("Dealer name")
                let dealerName = dealer["dealer_name"] as! String
                cell!.textLabel?.text = "\(nameDesc):\(dealerName)"
            }else if row == 1{
                let contactDesc = i18n("Contact")
                let dealerContact = dealer["dealer_connector"] as! String
                cell!.textLabel?.text = "\(contactDesc):\(dealerContact)"
            }else if row == 2{
                let phoneDesc = i18n("Phone")
                var dealerPhone = dealer["dealer_tel"] as! NSString
                if dealerPhone.length == 0{
                    dealerPhone = dealer["dealer_phone"] as! NSString
                }
                cell!.textLabel?.text = "\(phoneDesc):\(dealerPhone)"
                cell!.contentView.addSubview(callImageView)
            }
        }else if section == 2{
            cell!.textLabel?.font = UIFont(name: "Arial-BoldItalicMT", size: 14)
            let desc = i18n("Dealer description")
            let dealerDesc = dealer["dealer_address"] as! String
            cell!.textLabel?.text = "\(desc):\(dealerDesc)"
        }
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0{
            if row == 0{
                return logoImageView.frame.size.height
            }else if row == 1{
                return 100
            }else{
                return gotoMapLabel.frame.size.height
            }
        }else if section == 1{
            if row == 2{
                return callImageView.frame.size.height
            }
            return 44.0
        }else if section == 2{
            return 100.0
        }
        
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0{
            let lat = (dealer["dealer_lat"] as! NSString).doubleValue
            let lng = (dealer["dealer_lng"] as! NSString).doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            if row == 1{
                delegate?.dealerDetailShowCalloutInMapView(coordinate)
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            }else if row == 2{
                let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()
                
                let toLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
                toLocationMapItem.name = i18n("Destination")
                MKMapItem.openMapsWithItems([currentLocationMapItem, toLocationMapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: NSNumber(bool: true)])
                
            }
        }else if section == 1{
            if row == 2{
                var dealerPhone = dealer["dealer_tel"] as! NSString
                if dealerPhone.length == 0{
                    dealerPhone = dealer["dealer_phone"] as! NSString
                }

                var phoneStr = "tel://\(dealerPhone)"
                let phoneURL = NSURL(string: phoneStr)
                
                if uselessWebView == nil{
                    uselessWebView = UIWebView(frame: CGRectZero)
                }
                uselessWebView.loadRequest(NSURLRequest(URL: phoneURL!))
            }
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
