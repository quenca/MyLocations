//
//  MapViewController.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 03/06/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    // As soon as managedObjectContext is given a value – which happens in AppDelegate during app startup – the didSet block tells the NotificationCenter to add an observer for the NSManagedObjectContextObjectsDidChange notification
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { notification in
                    if self.isViewLoaded {
                    // This throws away all the old pins and it makes new pins for all the newly fetched Location objects
                       self.updateLoccations()
                }
            }
        }
    }
    
    var locations = [Location]()
    
    //Mark:- Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView.mapType = .satellite
        updateLoccations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination
                as! LocationDetailsViewController
            controller.manageObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
    
    //MARK:- Private methods
    func updateLoccations() {
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        // Once you’ve obtained the Location objects, you call mapView.addAnnotations() to add a pin for each location on the map
        mapView.addAnnotations(locations)
    }
    
    func region(for annotations: [MKAnnotation]) ->
        MKCoordinateRegion {
            let region: MKCoordinateRegion
            
            switch annotations.count {
            case 0:
                region = MKCoordinateRegionMakeWithDistance(
                    mapView.userLocation.coordinate, 1000, 1000)
                
            case 1:
                let annotation = annotations[annotations.count - 1]
                region = MKCoordinateRegionMakeWithDistance(
                    annotation.coordinate, 1000, 1000)
                
            default:
                var topLeft = CLLocationCoordinate2D(latitude: -90,
                                                     longitude: 180)
                var bottomRight = CLLocationCoordinate2D(latitude: 90,
                                                         longitude: -180)
                
                for annotation in annotations {
                    topLeft.latitude = max(topLeft.latitude,
                                           annotation.coordinate.latitude)
                    topLeft.longitude = min(topLeft.longitude,
                                            annotation.coordinate.longitude)
                    bottomRight.latitude = min(bottomRight.latitude,
                                               annotation.coordinate.latitude)
                    bottomRight.longitude = max(bottomRight.longitude,
                                                annotation.coordinate.longitude)
                }
                
                let center = CLLocationCoordinate2D(latitude: topLeft.latitude -
                    (topLeft.latitude - bottomRight.latitude) / 2,
                                                    longitude: topLeft.longitude -
                                                        (topLeft.longitude - bottomRight.longitude) / 2)
                
                let extraSpace = 1.1
                let span = MKCoordinateSpan(
                    latitudeDelta: abs(topLeft.latitude -
                        bottomRight.latitude) * extraSpace,
                    longitudeDelta: abs(topLeft.longitude -
                        bottomRight.longitude) * extraSpace)
                
                region = MKCoordinateRegion(center: center, span: span)
            }
            return mapView.regionThatFits(region)
    }
    
    @objc func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
}
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                    viewFor annotation: MKAnnotation) ->
        MKAnnotationView? {
        // Because MKAnnotation is a protocol, there may be other objects apart from the Location object that want to be annotations on the map. An example is the blue dot that represents the user’s current location.
          //  You should leave such annotations alone. So, you use the special is type check operator to determine whether the annotation is really a Location object
            guard annotation is Location else {
                return nil
            }
            // You ask the map view to re-use an annotation view object. If it cannot find a recyclable annotation view, then you create a new one
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
            if annotationView == nil {
                let pinView = MKPinAnnotationView(annotation: annotation,
                                                  reuseIdentifier: identifier)
                // This sets some properties to configure the look and feel of the annotation view
                pinView.isEnabled = true
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                pinView.pinTintColor = UIColor(red: 0.32, green: 0.82,
                                               blue: 0.4, alpha: 1)
                
                // You create a new UIButton object that looks like a detail disclosure button
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.addTarget(self,
                                      action: #selector(showLocationDetails),
                                      for: .touchUpInside)
                pinView.rightCalloutAccessoryView = rightButton
                
                annotationView = pinView
            }
            
            if let annotationView = annotationView {
                annotationView.annotation = annotation
                
                // Once the annotation view is constructed and configured, you obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the locations array. That way, you can find the Location object later in showLocationDetails() when the button is pressed
                let button = annotationView.rightCalloutAccessoryView
                    as! UIButton
                if let index = locations.index(of: annotation
                    as! Location) {
                    button.tag = index
                }
            }
            
            return annotationView
    }
}
