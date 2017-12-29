
import UIKit
import MapKit

class SBMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var mapView : MKMapView!
    var currentLocationManager : CLLocationManager!
    
    // MARK: Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "SB MAP VIEW DEMO"
        let plotRouteButton : UIBarButtonItem = UIBarButtonItem (title: "Plot Route", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.plotRoute))
        
        self.navigationItem.setRightBarButton(plotRouteButton, animated: true)
                
        initializeLocationManager()
        setUpMapView()
        addAnnotationsOnMap()
        //        plotRoute()
        
    }
    
    // MARK: Initialize Location Manager
    func initializeLocationManager () {
        currentLocationManager = CLLocationManager ()
        currentLocationManager.delegate = self
        currentLocationManager.requestWhenInUseAuthorization()
        currentLocationManager.requestAlwaysAuthorization()
        currentLocationManager.startUpdatingLocation()
        
    }
    
    // MARK: SetUp Map View
    func setUpMapView () {
        
        mapView = MKMapView (frame: self.view.bounds)
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        
        let location = CLLocationCoordinate2D(
            latitude: 53.7709505,
            longitude: 12.5753569
        )
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: Add Annotations OnMap
    func addAnnotationsOnMap () {
        let annotations : SBMapViewAnnotation = SBMapViewAnnotation (title: "Title", subTitle: "SubTitle", locationName: "LocationName", discipline: "Description of Location", coordinate: CLLocationCoordinate2DMake(53.7709505 , 12.5753569))
        mapView.addAnnotation(annotations)
        
        let annotations1 : SBMapViewAnnotation = SBMapViewAnnotation (title: "Title 1", subTitle: "SubTitle 1", locationName: "LocationName 1", discipline: "Description of Location 1", coordinate: CLLocationCoordinate2DMake(53.822817 , 12.7905515))
        mapView.addAnnotation(annotations1)
        
        
    }
    
    // MARK: Plot Route
   @objc func plotRoute () {
        
        let _srcCoord : CLLocationCoordinate2D = CLLocationCoordinate2DMake(53.7709505, 12.5753569)
        let _srcMark : MKPlacemark = MKPlacemark (coordinate: _srcCoord, addressDictionary: nil)
        let _srcItem : MKMapItem = MKMapItem (placemark: _srcMark)
        
        let _destCoord : CLLocationCoordinate2D = CLLocationCoordinate2DMake(53.822817, 12.7905515)
        let _destMark : MKPlacemark = MKPlacemark (coordinate: _destCoord, addressDictionary: nil)
        let _destItem : MKMapItem = MKMapItem (placemark: _destMark)
        
        findDirectionsFrom(_srcItem, destination: _destItem)
        
    }
    
    func findDirectionsFrom (_ source : MKMapItem, destination : MKMapItem) {
        
        let request : MKDirectionsRequest = MKDirectionsRequest ()
        request.source = source
        request.transportType = .automobile
        request.destination = destination;
        
        let directions : MKDirections = MKDirections (request: request)
        
        directions.calculate { (response : MKDirectionsResponse?, error : Error? ) -> Void in
            if let _ = error {
                print("ERROR")
                let alert = UIAlertController (title: "Error!", message: "A route to the nearest road cannot be determined", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    
                    print("OK")
                }))
                
                
                self.navigationController?.present(alert, animated: true, completion: nil)
                
            } else {
                self.didLoadedDirections(response!)
                
                
                
            }
        }
    }
    
    func didLoadedDirections (_ response : MKDirectionsResponse) {
        
        let route : MKRoute = response.routes.first!
        mapView.add(route.polyline, level:.aboveRoads)
        
        var zoomRect : MKMapRect = MKMapRectNull
        
        for annotation in mapView.annotations as [MKAnnotation] {
            
            let annotationPoint : MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect : MKMapRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
    }
    
    // MARK: ALL DELEGATE FUNCTIONS
    // MARK: Location Manager Delegate Function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        UIApplication.shared.sendAction(#selector(CLLocationManager.requestWhenInUseAuthorization),
                                                   to: currentLocationManager,
                                                   from: self,
                                                   for: nil)

        currentLocationManager.startUpdatingLocation()
    }
    
    // MARK: MapView Delegate Function
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        if annotation.isKind(of: SBMapViewAnnotation.self)  {
            let reuseId = "test"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView!.image = UIImage(named:"mapAnnotationImg")
                anView!.canShowCallout = true
            }
            else {
                //we are re-using a view, update its annotation reference...
                anView!.annotation = annotation
            }
            return anView
            
        }
        
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation!.isKind(of: SBMapViewAnnotation.self)  {
            
            let temp  = view.annotation as! SBMapViewAnnotation
            print(temp.discipline)
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Plote Route
        
        let polylineRender : MKPolylineRenderer = MKPolylineRenderer (overlay: overlay)
        polylineRender.lineWidth = 3.0
        polylineRender.strokeColor = UIColor.blue
        return polylineRender
        
    }
    
    
    // MARK: Receive Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
