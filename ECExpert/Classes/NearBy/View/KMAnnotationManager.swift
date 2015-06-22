//
//  KMAnnotationManager.swift
//  ECExpert
//
//  Created by Fran on 15/6/16.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

let KMAnnotationKey = "CustomAnnotation"
let KMCalloutAnnotationKey = "CalloutView"

protocol KMAnnotationManagerDelegate: NSObjectProtocol{
    func annotationManagerNumersOfCalloutAnnotationViewForMap() -> Int
    func annotationManagerInfoWithIndex(index: Int) -> (coordinate: CLLocationCoordinate2D, title: String, image: UIImage)
    func annotationManagerContainerViewInMapToShow(index: Int!, calloutAnnotationView: KMCalloutAnnotationView!)
    func annotationManagerDidSelectCalloutWithIndex(index: Int!, calloutAnnotationView: KMCalloutAnnotationView!)
}

class KMAnnotationManager: NSObject, MKMapViewDelegate {
    
    weak var delegate: KMAnnotationManagerDelegate?
    private var currentSelectedAnnotation: KMCalloutAnnotation!
    private var currentAnnotationView: KMCalloutAnnotationView!
    
    func startManage(mapView: MKMapView){
        if delegate != nil{
            let totalCount = delegate!.annotationManagerNumersOfCalloutAnnotationViewForMap()
            for n in 0..<totalCount{
                let info = delegate!.annotationManagerInfoWithIndex(n)
                let annotation = KMAnnotation(coordinate: info.coordinate, title: info.title, image: info.image)
                annotation.index = n
                mapView.addAnnotation(annotation)
            }
        }
    }

    func calloutAnnotationTapAction(){
        KMLog("calloutAnnotationTapAction")
        
        if self.currentSelectedAnnotation != nil && self.currentAnnotationView != nil{
            delegate?.annotationManagerDidSelectCalloutWithIndex(self.currentSelectedAnnotation.index, calloutAnnotationView: self.currentAnnotationView!)
        }
    }
    
    func removeKMCalloutAnnotation(mapView: MKMapView!){
        for anno in mapView.annotations{
            if anno is KMCalloutAnnotation{
                mapView.removeAnnotation(anno as! MKAnnotation)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation! is KMAnnotation{
            let anno = annotation as! KMAnnotation
            var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(KMAnnotationKey)
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: KMAnnotationKey)
                annotationView!.canShowCallout = false
                annotationView!.image = anno.image
                annotationView?.userInteractionEnabled = true
            }
            return annotationView
        }else if annotation! is KMCalloutAnnotation{
            let anno = annotation as! KMCalloutAnnotation
            var annotationView: KMCalloutAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(KMCalloutAnnotationKey) as? KMCalloutAnnotationView
            if annotationView == nil{
                annotationView = KMCalloutAnnotationView(annotation: annotation, reuseIdentifier: KMCalloutAnnotationKey)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: "calloutAnnotationTapAction")
                mapView.userInteractionEnabled = true
                annotationView?.userInteractionEnabled = true
                annotationView?.addGestureRecognizer(tapGesture)
            }
            
            delegate?.annotationManagerContainerViewInMapToShow(anno.index, calloutAnnotationView: annotationView)
            
            self.currentSelectedAnnotation = anno
            self.currentAnnotationView = annotationView
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let annotation = view.annotation
        if annotation! is KMAnnotation{
            removeKMCalloutAnnotation(mapView)
            let anno = annotation as! KMAnnotation
            let calloutAnnotation = KMCalloutAnnotation(coordinate: anno.coordinate, title: anno.title, image: anno.image)
            calloutAnnotation.index = anno.index
            mapView.addAnnotation(calloutAnnotation)
            mapView.setCenterCoordinate(anno.coordinate, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        KMLog("didDeselectAnnotationView")
    }
    
}
