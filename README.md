# MapLoader-iOS

[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)
[![Version](https://img.shields.io/cocoapods/v/MapLoader.svg?style=flat)](http://cocoapods.org/pods/MapLoader)
[![License](https://img.shields.io/cocoapods/l/MapLoader.svg?style=flat)](http://cocoapods.org/pods/MapLoader)
[![Platform](https://img.shields.io/cocoapods/p/MapLoader.svg?style=flat)](http://cocoapods.org/pods/MapLoader)

**MapLoader** is a tool helps you quickly loads iOS maps. In addition, the library includes highly-customized annotations and clusters that allows you to design your own map annotations.

You may download **MapLoaderDemo** to see how its used in your app. 

## Requirements
- Swift 4.0
- iOS 10.0+

## Installation

MapLoader is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
$ pod 'MapLoader'
```
If you don't use CocoaPods, you can download the entire project then drag and drop all the classes and use them in your project.

## Usage

Follow the instructions below to quickly setup MapView.

### Step 1: Initialize a MapLoader object
```swift
let mapLoader = MapLoader()
```
### Step 2: Setup MapView in ```swift viewWillAppear(_ animated: Bool)``` method
```swift
mapLoader.setupMapView(mapContainer: self.view, viewAboveMap: segmentControl, delegate: self)
```
Note: You need to set delegate if you need to use ```swift MKMapViewDelegate```. Otherwise, you can leave it ```swift nil```

### Step 3: Resize the MapView in ```swift viewDidLayoutSubviews()```
```swift
mapLoader.layoutMapView()
```

Follow the instructions below to use annotations and clusters.

### Step 4: Add your customized annotations
```swift
var annotations: [MLAnnotation] = []  
let img = UIImage(named: "my_image")!
let annotation = MLAnnotation(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.06), annotImg: img, annotBgColor: UIColor.red, data: nil)  
annotations.append(annotation)  
mapLoader.addAnnotations(annotations: annotations)
```

### Step 5: Setup ```swift MKMapViewDelegate``` and use the following function.
```swift
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
	return mapLoader.generateClusteringView(annotation: annotation) as? MKAnnotationView
}
```

### Step 6: Refresh annotations and clusters when MapView region is changed
```swift
func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
	mapLoader.refreshMap()
}
```


## Credits
* https://github.com/efremidze/Cluster
* https://github.com/keithito/SimpleAnimation
* https://icons8.com/
