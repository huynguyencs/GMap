import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate, LocateOnTheMap, UISearchBarDelegate{

var searchResultController:SearchResultsController!
var resultsArray = [String]()
var googleMapsView:GMSMapView!
    
let locationManager = CLLocationManager()
var coordinate = CLLocationCoordinate2D()
var placesClient: GMSPlacesClient?

@IBOutlet weak var mapview: GMSMapView!
@IBOutlet weak var curlocation: UILabel!
@IBOutlet weak var userlocation: UITextField!
@IBOutlet weak var submit: UIButton!
@IBAction func showSearchController(sender: AnyObject) {
    let searchController = UISearchController(searchResultsController: searchResultController)
    searchController.searchBar.delegate = self
    self.presentViewController(searchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let camera = GMSCameraPosition.cameraWithLatitude(-33.86,
//            longitude: 151.20, zoom: 6)
//        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
//        mapView.myLocationEnabled = true
//        self.view = mapView
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient()
        
        placesClient?.currentPlaceWithCallback { (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if error != nil {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            if let placeLicklihoodList = placeLikelihoodList {
                let place = placeLicklihoodList.likelihoods.first?.place
                if let place = place
                {
                    print("Current Place address \(place.formattedAddress)")
                    self.curlocation.text = "Address: " + place.formattedAddress
                    self.coordinate.latitude = place.coordinate.latitude
                    self.coordinate.longitude = place.coordinate.longitude
                    
                    //print("Current Place attributions \(place.attributions)")
                    //print("Current PlaceID \(place.placeID)")
                }
                
                
                let camera = GMSCameraPosition.cameraWithLatitude(self.coordinate.latitude, longitude: self.coordinate.longitude, zoom: 16)
                self.mapview.animateToLocation(self.coordinate)
                self.mapview.animateToZoom(17)
                
                //Controls whether the My Location dot and accuracy circle is enabled.
                self.mapview.myLocationEnabled = true;
                
                //Controls the type of map tiles that should be displayed.
                self.mapview.mapType = kGMSTypeNormal;
                
                //Shows the compass button on the map
                self.mapview.settings.compassButton = true;
                
                //Shows the my location button on the map
                self.mapview.settings.myLocationButton = true;
                
                //Sets the view controller to be the GMSMapView delegate
                self.mapview.delegate = self;
                
                //self.googleMapsView =  GMSMapView(frame: self.mapview.frame)
                //self.view.addSubview(self.googleMapsView)
                
                self.searchResultController = SearchResultsController()
                self.searchResultController.delegate = self
            }
        }
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            
            self.curlocation.text = "Address: " + title
            
            let marker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 16)
            self.mapview.camera = camera
            
            marker.title = title
            marker.map = self.mapview
        }
    }
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String){
            
            let placesClient = GMSPlacesClient()
            placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
                self.resultsArray.removeAll()
                if results == nil {
                    return
                }
                for result in results!{
                    if let result = result as? GMSAutocompletePrediction{
                        self.resultsArray.append(result.attributedFullText.string)
                    }
                }
                self.searchResultController.reloadDataWithArray(self.resultsArray)
            }
    }
 }

