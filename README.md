# MapLoader-iOS

[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)
[![Version](https://img.shields.io/cocoapods/v/MapLoader.svg?style=flat)](http://cocoapods.org/pods/MapLoader)
[![License](https://img.shields.io/cocoapods/l/MapLoader.svg?style=flat)](http://cocoapods.org/pods/MapLoader)
[![Platform](https://img.shields.io/cocoapods/p/MapLoader.svg?style=flat)](http://cocoapods.org/pods/MapLoader)

**MapLoader** is a tool helps you quickly loads Google and/or Apple maps on iOS. In addition, the library includes highly-customized annotations, markers and clusters views that allows you to design your own map UI.

<img src="https://raw.githubusercontent.com/twho/MapLoader-iOS/master/Images/demo.gif" width="640">

You may download **MapLoaderDemo** to see how its used in your app. 

## Key Features
- Easily loads Google and Apple maps on iOS
- Customizable markers and annotations
- Built-in foreground and background images for markers and annotations
- Clustering markers and annotations
- Markers and annotations animation support

## Requirements
- Swift 4.0
- iOS 10.0+

## Usage

Follow the instructions below to quickly setup MapView.

### Step 1: Initialize a MapLoader object
```swift
let mapLoader = MapLoader()
```
#### Initialize a GoogleMapLoader object 
```swift
let mapLoader = GoogleMapLoader()
```
Note: You need to set API key in AppDelegate.swift before having access to Google Map, see __Supplementals__ for more details.

### Step 2: Insert view to your current view in viewWillAppear() function
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    mapLoader.setupMapView(mapContainer: self.view, viewAboveMap: nil, delegate: self)
}
```
Note: You need to set delegate if you need to use ```MKMapViewDelegate```. Otherwise, you can leave it ```nil```

### Step 3: Resize the MapView in viewDidLayoutSubviews() function
```swift
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    mapLoader.layoutMapView()
}
```

### Follow the instructions below to use __clusters__ and __annotations/markers__.
### Step 4: Add your customized annotations
#### Use StyledAnnotationView for annotation views
```swift
var annotations: [MLAnnotation] = []  
let annotView = StyledAnnotationView(annotImg: .hazard, color: UIColor.white, background: .bubble, bgColor: UIColor.blue)
let annotation = MLAnnotation(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.06), annotView: annotView, data: nil)  
annotations.append(annotation)  
mapLoader.addAnnotations(annotations: annotations)
```
#### Simply change the object to MLMarker for Google Map use
```swift
let annotation = MLMarker(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.06), annotView: annotView, data: nil)  
```
### Step 5: Setup MKMapViewDelegate and use the following functions.
```swift
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    return mapLoader.generateClusteringView(annotation: annotation) as? MKAnnotationView
}
```

### Step 6: Refresh annotations and clusters when MapView region is changed
```swift
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    return mapLoader.generateClusteringView(annotation: annotation) as? MKAnnotationView
}
```
#### For Google map
Refresh the map after users finish their gestures.

```swift
func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
	mapLoader.refreshMap()
}
```
## Supplementals
### Use your own image as annotation views
```swift
let image = UIImage(named: "your_image")
let annotView = StyledAnnotationView(annotImg: image, background: .bubble, bgColor: UIColor.blue)
```
### Built-in annotation-like background images available. 
```swift
/**
Built-in background images.

- bubble: bubble background
- square: square-shaped background
- circle: circular background
- heart:  heart-shaped background
- flag:   flag background
*/
public enum BgImg {
    case bubble
    case square
    case circle
    case heart
    case flag
}
```
#### Set Google Map API key in AppDelegate.swift
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GoogleMapLoader.setAPIKey("YOUR_API_KEY")
    return true
}
```

## Installation

MapLoader is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
$ pod 'MapLoader'
```
If you don't use CocoaPods, you can download the entire project then drag and drop all the classes and use them in your project.

## Credits
* https://github.com/twho/CustomMapAnnotation-iOS
* https://github.com/efremidze/Cluster
* https://github.com/keithito/SimpleAnimation
* https://icons8.com/
