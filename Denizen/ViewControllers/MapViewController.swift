//
//  MapViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-07.
//

import UIKit
import SwiftyJSON
import MapKit

class MapItem: NSObject, MKAnnotation {
    let id: String
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let record: [String: AnyObject]?
    
    init(id: String, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, record: [String: AnyObject]?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.record = record
    }
}

class MapViewController: UIViewController {
    var resourceId: String!
    var mapView = MKMapView()
    var mapItems = [MapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureMapView()
        configureAPIRequest()
        setConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name:.detailChosen, object:self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name:.detailDismissed, object:self)
    }
    
    func configureMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let toronto = CLLocation(latitude: 43.671111, longitude: -79.385833)
        let region = MKCoordinateRegion(
            center: toronto.coordinate,
            latitudinalMeters: 15000,
            longitudinalMeters: 15000)
        mapView.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        view.addSubview(mapView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}


// MARK: - Map view delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapItem else { return nil }
        
        let identifier = "mapItem"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MapItem else { return }
        let mapItem = mapItems.filter { $0.id == annotation.id }
        if let formatted = mapItem.first, let finalFormatted = formatted.record.map({ $0 }) {
            let arr = finalFormatted.sorted { $0.key < $1.key }
            let mapTableVC = MapTableViewController()
            mapTableVC.data = arr
            self.navigationController?.pushViewController(mapTableVC, animated: true)
        }
    }
}

// MARK: - Configure API request

extension MapViewController {
    func configureAPIRequest() {
        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        // https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search?id=2ee41858-5bbd-4073-98bf-7d46430bb1b9
        WebServiceManager.shared.sendRequest(urlString: URLScheme.baseURL + Query.ActionType.datastoreSearch, parameters: [Query.Key.id: resourceId]) { (responseObject, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                    let alertController = UIAlertController(title: "Network Error", message: error.localizedDescription , preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            if let responseObject = responseObject {
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                }
                
                let json = JSON(responseObject as [String: Any])
                let dict = self.json2dic(json)
                if let result = dict["result"] as? [String: AnyObject], let records = result["records"] as? [String: AnyObject] {
                    for record in records {
                        if let geometry = record.value["geometry"] as? String,
                           let coordinates = geometry.slice(from: "[", to: "]"),
                           let id = record.value["_id"] as? String {
                            
                            let coordinateArr = coordinates.components(separatedBy: ",")
                            let longitude = coordinateArr[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            let latitude = coordinateArr[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            if let lat = Double(longitude), let long = Double(latitude) {
                                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                let mapItem = MapItem(id: id, title: nil, subtitle: nil, coordinate: coordinate, record: record.value as? [String: AnyObject])
                                self.mapItems.append(mapItem)
                            }
                        }

                    }
                    self.mapView.addAnnotations(self.mapItems)
                }
            }
        }
    }
}
