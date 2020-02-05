//
//  ViewController.swift
//  Mapping
//
//  Created by THOTA NAGARAJU on 2/4/20.
//  Copyright © 2020 THOTA NAGARAJU. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON


class ViewController: UIViewController,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {
    
    
    var gmav = GMSAutocompleteViewController()
    
    @IBOutlet weak var sourceTF: UITextField!
    
    @IBOutlet weak var destinationTF: UITextField!
    
    var  selectedTf:String = ""
    var  sorceLoc = CLLocation()
    var  destinatioLoc = CLLocation()

    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        gmav.delegate = self
        sourceTF.delegate = self
        destinationTF.delegate = self
        let camera = GMSCameraPosition.init(latitude: -33.86, longitude: 151.20, zoom: 15.0)
        mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Juffa"
        marker.map = mapView
        
        
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("success")
        dismiss(animated: true, completion: nil)
        if(selectedTf  == "source")
        {
            sourceTF.text = place.name
            sorceLoc  = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        else
        {
                
            (selectedTf == "destination")
            destinationTF.text = place.name
            destinatioLoc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Failed")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Cancel")
    }
    

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
        
        
    {
        
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) // became first responder
    {
        if(textField == sourceTF)
        {
            selectedTf = "source"
            textField.resignFirstResponder()
            
            present(gmav, animated: true, completion: nil)
            
            
        }else if(textField == destinationTF)
        {
            selectedTf = "destination"
            textField.resignFirstResponder()
            
            present(gmav, animated: true, completion: nil)
            
        }
        
    }

    @IBAction func goBTN(_ sender: Any) {
        
        drawPath(startLocation: sorceLoc, endLocation: destinatioLoc)
        
    }
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
      let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: startLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        marker.snippet = sourceTF.text
        marker.title = sourceTF.text
        marker.map = mapView
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: startLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude )
        marker2.snippet = destinationTF.text
        marker2.title = destinationTF.text
        marker2.map = mapView
        
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
       let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
             
             
             
             let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDuBvXGuYzrnh51qC3brdG0OQCsXFHCNLU"
             
             Alamofire.request(url).responseJSON { response in
                 
                 print(response.request as Any)  // original URL request
                 print(response.response as Any) // HTTP URL response
                 print(response.data as Any)     // server data
                 print(response.result as Any)   // result of response serialization
                 do{
                 let json = try JSON(data: response.data!)
                 let routes = json["routes"].arrayValue
                 
                 // print route using Polyline
                 for route in routes
                 {
                     let routeOverviewPolyline = route["overview_polyline"].dictionary
                     let points = routeOverviewPolyline?["points"]?.stringValue
                     let path = GMSPath.init(fromEncodedPath: points!)
                     let polyline = GMSPolyline.init(path: path)
                     polyline.strokeWidth = 4
                     polyline.strokeColor = UIColor.red
                     polyline.map = self.mapView
                 }
                     
                     let camera = GMSCameraPosition.camera(withLatitude: self.sorceLoc.coordinate.latitude, longitude: self.sorceLoc.coordinate.longitude, zoom: 5.0
                 )
                     
                     self.mapView.camera = camera
                 }catch
                 {
                     print("unable to create route")
                 }
                 
             }
         }
         
    }
    


