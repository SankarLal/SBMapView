
import UIKit
import MapKit
import Foundation

class SBMapViewAnnotation: NSObject, MKAnnotation {
    
    let title : String?
    let subtitle : String?
    let locationName : String
    let discipline : String
    let coordinate: CLLocationCoordinate2D
    
    init(title : String, subTitle : String, locationName : String, discipline : String, coordinate: CLLocationCoordinate2D ) {
        
        self.title = title
        self.subtitle = subTitle
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
        
    }


}
