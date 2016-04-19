//
//  ViewController.swift
//  Map Demo
//
//  Daniel Lorenzo 2640 - 001
//  Created by [ r∆ven ] on 4/3/16.
//  Copyright © 2016 Salt Lake Community College. All rights reserved.
//

import UIKit
import MapKit
// For custom search option.
import CoreLocation
// For custom sound effect from segue entrance touch.
import AVFoundation

// Added one more class.
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    
    // Variables for search bar.
    var pinAnnotationView:MKPinAnnotationView!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var annotation:MKAnnotation!
    var pointAnnotation:MKPointAnnotation!
    var searchController:UISearchController!
    var error:NSError!
    var magicSound: AVAudioPlayer!
    
    // Called search method when pressed.
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    // Location attribute.
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom magic sound effect.
        magicButtonSound()
        
        //** HOW TO : Get users location.
        locationManager.delegate = self // Set delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set accuracy level / power.
        locationManager.requestWhenInUseAuthorization() // Set authorization level.
        locationManager.startUpdatingLocation() // Start updating user's location.
        
        //** HOW TO: Construct map Region with detail variables. ***
        
        // Typed variables to hold lat and long of SLCC.
        
        let latitude:CLLocationDegrees = 37.773972
        
        let longitude:CLLocationDegrees = -122.431297
        
        // Delta variables to hold the differences of lat and long from one side of the screen to the other.
        // This controls the zoomed level of lat and long. The lower the value it zooms in.
        
        let latDelta:CLLocationDegrees = 0.5    // Set lat zoom.
        
        let lonDelta: CLLocationDegrees = 0.5   // Set lon zoom.
        
        // Set both lat and long zoom.
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // Sets the lat and long on the map itself (of SLCC).
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Build region with variables.
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // Set our map to the region.
        map.setRegion(region, animated: true)
        
        //*** HOW TO: Add annotations to the map. ***
        
        // Create annotation object from MapKik.
        let annotation = MKPointAnnotation()
        
        // Use annotation object and set it's attributes.
        annotation.coordinate = location    // Location of SLCC already created above.
        
        annotation.title = "Salt Lake Community College."   // Set title attribute.
        
        annotation.subtitle = "CSIS-2640 iOS Programming."   // Set subtitle attribute.
        
        map.addAnnotation(annotation)   // Add the annotation (RED PIN) object to the map object.
        
        //*** HOW TO: Add a LONG PRESS recogniser.
        
        // Create variable to hold long press object.
        // Target: Is self or this ViewController.
        // Action: Is the function to run when long press is recognized.
        let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        
        // Set press duration attribute of the longPress object.
        longPress.minimumPressDuration = 2
        
        // Add the long press recognizer to the map.
        map.addGestureRecognizer(longPress)
        
    }
    
    // Function performed when a long press is recognized on the map.
    // theLongPress: Is the gesture sent from action: (with the colon:)
    func action(theLongPress:UIGestureRecognizer)
    {
        // Test that is working...
        print("User Long Pressed.")
        
        // userTouch relative point on current map.
        let userTouch = theLongPress.locationInView(self.map)
        
        // Convert userTouch to coordinate.
        let userCoordinate: CLLocationCoordinate2D = map.convertPoint(userTouch, toCoordinateFromView: self.map)
        
        // Create annotation object from MapKik.
        let annotation = MKPointAnnotation()
        
        // Use annotation object and set it's attributes.
        annotation.coordinate = userCoordinate    // Location of SLCC already created above.
        
        annotation.title = "McDonlad's"   // Set title attribute.
        
        annotation.subtitle = "Lunch Time"   // Set subtitle attribute.
        
        map.addAnnotation(annotation)   // Add the annotation (RED PIN) object to the map object.
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        // Called every time a new location is registered by the phone.
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Extract lat and lon.
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        //print(latitude)
        //print(longitude)
        
        let latDelta:CLLocationDegrees = 0.1    // Set lat zoom.
        
        let lonDelta: CLLocationDegrees = 0.1   // Set lon zoom.
        
        // Set both lat and long zoom.
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // Sets the lat and long on the map itself (of SLCC).
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Build region with variables.
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // Set our map to the region.
        self.map.setRegion(region, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Search bar bar button item function that gets called when clicked.
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.map.annotations.count != 0{
            annotation = self.map.annotations[0]
            self.map.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Could not teleport", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.map.centerCoordinate = self.pointAnnotation.coordinate
            self.map.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    // Magic sound function.
    private func magicButtonSound(){
        let path = NSBundle.mainBundle().URLForResource("FairyDustMagicSoundEffect", withExtension: "mp3")
        do {
            try magicSound = AVAudioPlayer(contentsOfURL: path!)
        } catch {
            print("AUDIO PROBLEM?!")
        }
        magicSound.play()
    }
    
    
}


