//
//  NearByViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/15.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class NearByViewController: BasicViewController, CLLocationManagerDelegate, KMAnnotationManagerDelegate, DealerDetailViewControllerDelegate{
    
    var manager: KMAnnotationManager!
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var locationBtn: UIButton!
    
    private var netManager = AFNetworkingFactory.networkingManager()
    private var dealerArray: NSMutableArray!
    
    var dealerViewController: DealerDetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpLoactionManager()
        self.setUpMap()
        
        // 此时开始定位
        self.location()
        
        // 加载数据
        self.loadData()
        
        // 数据逻辑处理完成之后，才允许点击搜索按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: i18n("Search"), style: UIBarButtonItemStyle.Plain, target: self, action: "search")
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: "tapPress:")
        mapView.addGestureRecognizer(singleTap)
    }
    
    func tapPress(gesture: UIGestureRecognizer){
        let touchPoint = gesture.locationInView(mapView)
        let touchCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        KMLog("point: \(touchPoint) \ncoordinate latitude: \(touchCoordinate.latitude),longitude: \(touchCoordinate.longitude)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func search(){
        KMLog("search")
        
        let searchViewController = SearchViewController()
        searchViewController.rootMapViewController = self
        searchViewController.currentLocation = mapView.userLocation
        searchViewController.dealerArray = NSArray(array: dealerArray)
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    // MARK: - 加载数据
    func loadData(){
        let localDealerArray = LocalStroge.sharedInstance().getObject(APP_PATH_DEALER_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory) as? NSArray
        if localDealerArray != nil{
            // 启动地图服务
            dealerArray = NSMutableArray(array: localDealerArray!)
            reloadData()
        }else{
            dealerArray = NSMutableArray()
        }
        
        // 检测数据更新
        netManager.GET(APP_URL_DEALER, parameters: nil, success: {[unowned self] (operation:AFHTTPRequestOperation!, responseObj:AnyObject!) -> Void in
            let rootDic = responseObj as? NSDictionary
            let code = rootDic?["code"] as? Int
            if code == 1{
                let remoteDealerArray = DealerHelper.getMapShowDealerArray(rootDic?["data"] as! NSArray)
                
                if localDealerArray == nil || !remoteDealerArray.isEqualToArray(localDealerArray as! [AnyObject]){
                    self.dealerArray = NSMutableArray(array: remoteDealerArray)
                    LocalStroge.sharedInstance().deleteFile(APP_PATH_DEALER_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
                    LocalStroge.sharedInstance().addObject(remoteDealerArray, fileName: APP_PATH_DEALER_INFO, searchPathDirectory: NSSearchPathDirectory.CachesDirectory)
                    self.reloadData()
                }
            }
            // 数据逻辑处理完成之后，才允许点击搜索按钮
//            self.navigationItem.rightBarButtonItem?.enabled = true
            }) {[unowned self] (operation:AFHTTPRequestOperation!, error: NSError!) -> Void in
                KMLog("\(error.localizedDescription)")
                // 数据逻辑处理完成之后，才允许点击搜索按钮
//                self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func reloadData(){
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.manager.startManage(self.mapView)
    }
    
    // MARK: - 定位
    func setUpLoactionManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
        
        if APP_SYS_DEVICE_VERSION >= 8.0{
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    // MARK: - 初始化地图
    func setUpMap(){
        let mapFrame = getVisibleFrame()
        self.mapView = MKMapView(frame: mapFrame)
        mapView.mapType = MKMapType.Standard
        self.view.addSubview(self.mapView)
        
        // 设置代理
        manager = KMAnnotationManager()
        manager.delegate = self
        mapView.delegate = manager
        
        // locationButton
        locationBtn = UIButton()
        locationBtn.addTarget(self, action: "location", forControlEvents: UIControlEvents.TouchUpInside)
        locationBtn.setImage(UIImage(named: "location"), forState: UIControlState.Normal)
        locationBtn.setImage(UIImage(named: "location_higlight"), forState: UIControlState.Disabled)
        locationBtn.frame = CGRectMake(5, KM_FRAME_SCREEN_HEIGHT - KM_FRAME_VIEW_TABBAR_HEIGHT - 50 - 20 , 50, 50)
        self.view.addSubview(locationBtn)
    }
    
    func location(){
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied{
            let alertView = UIAlertView(title: i18n("Unable to locate"), message: i18n("Your phone is not currently open location service, if you want to open the location service, please refer to the privacy Settings->Privacy->Location, open Location Services"), delegate: nil, cancelButtonTitle: i18n("Cancel"), otherButtonTitles: i18n("Sure"))
            alertView.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                // iOS现在无法跳转到设置界面
            })
            return;
        }
        
        locationManager.startUpdatingLocation()
        
        
        // 地图上显示用户位置， 蓝点
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        KMLog("didUpdateLocations")
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        KMLog("\(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        KMLog("didChangeAuthorizationStatus")
        switch status {
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertView = UIAlertView(title: nil, message: i18n("Please open the location service!"), delegate: nil, cancelButtonTitle: i18n("Sure"))
            alertView.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                //
            })
        default:
            break
        }
    }
    
    // MARK: - KMAnnotationManagerDelegate
    func annotationManagerNumersOfCalloutAnnotationViewForMap() -> Int {
        let num = self.dealerArray?.count
        return num ?? 0
    }
    
    func annotationManagerInfoWithIndex(index: Int) -> (coordinate: CLLocationCoordinate2D, title: String, image: UIImage) {
        let data = self.dealerArray[index] as! NSDictionary
        let lat = (data["dealer_lat"] as! NSString).doubleValue
        let lng = (data["dealer_lng"] as! NSString).doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let image = UIImage(named: "pin_1")
        let title = data["dealer_name"] as! String
        
        return (coordinate, title, image!)
    }
    
    func annotationManagerDidSelectCalloutWithIndex(index: Int!, calloutAnnotationView: KMCalloutAnnotationView!) {
        let data = self.dealerArray[index] as! NSDictionary
        var dealer = NSMutableDictionary(dictionary: data)
        if self.mapView.userLocation.location != nil{
            let dealerLocation = CLLocation(latitude: (dealer["dealer_lat"] as! NSString).doubleValue, longitude: (dealer["dealer_lng"] as! NSString).doubleValue)
            let distance = self.mapView.userLocation.location.distanceFromLocation(dealerLocation)
            dealer["dealer_distance"] = NSString(format: "%.3f", Double(distance / 1000.0))
        }
        
        if self.dealerViewController == nil{
            self.dealerViewController = DealerDetailViewController()
            self.dealerViewController.delegate = self
        }
        
        self.dealerViewController.dealer = dealer
        self.dealerViewController.tableView?.reloadData()
        
        self.navigationController?.pushViewController(self.dealerViewController, animated: true)
        
    }
    
    func annotationManagerContainerViewInMapToShow(index: Int!, calloutAnnotationView: KMCalloutAnnotationView!) {
        let data = self.dealerArray[index] as! NSDictionary
        var containerView = calloutAnnotationView.getContainerView() as? KMMapCalloutCellView
        if containerView == nil{
            containerView = KMMapCalloutCellView()
            containerView?.backgroundColor = UIColor.whiteColor()
            calloutAnnotationView.addContainerView(containerView!)
        }
        containerView?.titleLabel.text = data["dealer_name"] as? String
        containerView?.leftImageView.image = UIImage(named: "ecigInformation")
    }
    
    // MARK: - DealerDetailViewControllerDelegate
    func dealerDetailShowCalloutInMapView(coordinate: CLLocationCoordinate2D) {
        var annotation: MKAnnotation!
        for item in self.mapView.annotations{
            let anno = item as! MKAnnotation
            if anno.coordinate.latitude == coordinate.latitude && anno.coordinate.longitude == coordinate.longitude{
                annotation = anno
                break
            }
        }
        if annotation != nil{
            self.mapView.selectAnnotation(annotation, animated: true)
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
