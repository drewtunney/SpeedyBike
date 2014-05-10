//
//  MapVC.m
//  CitiBike
//
//  Created by Drew Tunney on 5/2/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "MapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "StationMarker.h"
#import "AppDelegate.h"
#import "LocationsViewController.h"
#import "Constants.h"
#import "CitiBikeAPI.h"

@interface MapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) NSURLSession *getStations;
@property(strong, nonatomic) NSSet *markers;
@property (strong, nonatomic) NSMutableArray *closestStations;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat directionsOriginLatitude;
@property (nonatomic) CGFloat directionsOriginLongitude;
@property (nonatomic) CGFloat directionsDestinationLatitude;
@property (nonatomic) CGFloat directionsDestinationLongitude;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) NSString *locationReference;
@property (strong, nonatomic) GMSPolyline *directionsLine;
@property (strong, nonatomic) NSArray *stations;



@end

@implementation MapVC {
    GMSMapView *mapView_;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.button removeFromSuperview];
    
    // Implement here to check if KVO is already implemented.
    
   
}

- (void)viewDidLoad {
    
    [self startDeterminingUserLocation];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.getStations = [NSURLSession sessionWithConfiguration:config];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapView_.myLocation.coordinate.latitude
                                                            longitude:mapView_.myLocation.coordinate.longitude
                                                                 zoom:16];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    self.view = mapView_;
    mapView_.delegate = self;
    
}

-(void)startDeterminingUserLocation
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    self.currentLocation = [locations lastObject];
    [mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                                                  longitude:self.currentLocation.coordinate.longitude
                                                                       zoom:16]];
    self.latitude = self.currentLocation.coordinate.latitude;
    self.longitude = self.currentLocation.coordinate.longitude;
    [self setPinsForStation];
}

- (void)setPinsForStation
{
    [CitiBikeAPI downloadStationDataWithCompletion:^(NSArray *stations) {
        self.stations = stations;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self createMarkerObjects];
        }];

    }];
}

- (void)createMarkerObjects
{

    [mapView_ clear];
   
        //[self findNearestStations:self.stations];
    self.closestStations = [CitiBikeAPI findNearestStationsforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
        [self sortStationsByDistance];
        
       // NSLog(@"Closest Stations Log: %@", self.closestStations);
    
    NSArray *closestThreeStations = [[NSArray alloc]initWithObjects:self.closestStations[0], self.closestStations[1], self.closestStations[2], nil];
   

    for (NSDictionary *station in closestThreeStations){
        
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([[station valueForKeyPath:@"latitude"]floatValue], [[station valueForKeyPath:@"longitude"]floatValue]);
            marker.title = [station valueForKeyPath:@"stAddress1"];
            marker.snippet = [[station valueForKeyPath:@"availableBikes"] stringValue];
            marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
            marker.map = mapView_;
    }
   
}


#pragma mark - GMSMapViewDelegate

-(void) setNearestStationsArray
{
   self.closestStations = [CitiBikeAPI findNearestStationsforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
}


-(void)sortStationsByDistance
{
   NSSortDescriptor *distanceSort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [self.closestStations sortUsingDescriptors:@[distanceSort]];
}

- (void)mapView:(GMSMapView *)mapView_
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
   // NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
    self.latitude = coordinate.latitude;
    self.longitude = coordinate.longitude;
    [self setPinsForStation];
    [self.button removeFromSuperview];
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView{
    [mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude
                                                                  longitude:mapView.myLocation.coordinate.longitude
                                                                       zoom:16]];
    self.latitude = mapView.myLocation.coordinate.latitude;
    self.longitude = mapView.myLocation.coordinate.longitude;
     [self setPinsForStation];
    return YES;
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [mapView setSelectedMarker:marker];
    self.directionsOriginLatitude = marker.position.latitude;
    self.directionsOriginLongitude = marker.position.longitude;
    NSLog(@"%f, %f", marker.position.latitude, marker.position.longitude);
    [self showDestinationTextbox];
    
    return YES;
}

-(void)showDestinationTextbox

{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSLog(@"%f", appDelegate.window.frame.size.width);
  
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(self.view.frame.origin.x+10, self.view.frame.origin.y + 50,appDelegate.window.frame.size.width-20, 30.0f)];
    [self.button setTitle:@"Set Destination" forState:UIControlStateNormal];
    [self.button.titleLabel setTextColor:[UIColor blackColor]];
    UIColor *backgroundColor = [UIColor colorWithWhite:1.0 alpha:.75];
    self.button.backgroundColor = backgroundColor;
    [self.button addTarget:self action:@selector(didTapDestinationButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    
}

-(void)didTapDestinationButton
{
    NSLog(@"Tapped Button");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationsViewController *locationsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
    locationsViewController.latitude = self.latitude;
    locationsViewController.longitude = self.longitude;
    locationsViewController.locationDelegate = self;
    [self presentViewController:locationsViewController animated:YES completion:nil];
    
}

-(void)secondViewControllerDismissed:(NSString *)locationReferenceStringForMap
{
     [mapView_ clear];
    
    [self getAddressForLocationReferenceID:locationReferenceStringForMap];
    //NSLog(@"%@", self.location);
}

-(void)getDirectionFromBikeDock
{

    
    NSString *directionsURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&key=%@&avoid=ferries&mode=bicycling", self.directionsOriginLatitude, self.directionsOriginLongitude,self.directionsDestinationLatitude, self.directionsDestinationLongitude,Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:directionsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //NSLog(@"%@", JSONResponseDict);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            GMSPath *path = [GMSPath pathFromEncodedPath:JSONResponseDict[@"routes"][0][@"overview_polyline"][@"points"]];
            self.directionsLine = [GMSPolyline polylineWithPath:path];
            self.directionsLine.strokeWidth = 7;
            self.directionsLine.strokeColor = [UIColor greenColor];
            self.directionsLine.map = mapView_;
            
            CLLocationCoordinate2D originPosition = CLLocationCoordinate2DMake(self.directionsOriginLatitude, self.directionsOriginLongitude);
            GMSMarker *originMarker = [GMSMarker markerWithPosition:originPosition];
            originMarker.map = mapView_;
            
            CLLocationCoordinate2D destinationPosition = CLLocationCoordinate2DMake(self.directionsDestinationLatitude, self.directionsDestinationLongitude);
            GMSMarker *destinationMarker = [GMSMarker markerWithPosition:destinationPosition];
            destinationMarker.map = mapView_;

        });
               //NSLog(@"%@", JSONResponseDict[@"predictions"][0][@"description"]);
                NSLog(@"%@", error);
    }]resume];

}

-(void)getCoordinatesForLocationForDestination:(NSString *)address
{
    
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&key=%@", address, Web_Browser_Key];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
       // NSLog(@"%@", JSONResponseDict);
        
        //NSLog(@"%@", JSONResponseDict);
        self.directionsDestinationLatitude = [JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lat"] floatValue];
        self.directionsDestinationLongitude = [JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lng"] floatValue];
       // NSLog(@"Given coordinates: %f, %f", self.directionsDestinationLatitude, self.directionsDestinationLongitude);
        
        [self getDirectionFromBikeDock];
        //NSLog(@"%@", JSONResponseDict);
        
        NSLog(@"%@", error);
    }]resume];
}

-(void)getAddressForLocationReferenceID:(NSString *)ID
{
    
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", ID, Web_Browser_Key];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSString *streetNumber = JSONResponseDict[@"result"][@"address_components"][0][@"long_name"];
        NSString *streetName = JSONResponseDict[@"result"][@"address_components"][1][@"long_name"];
        NSString *zipCode = [((NSArray *) JSONResponseDict[@"result"][@"address_components"])lastObject][@"long_name"];
        NSString *fullAddress = [NSString stringWithFormat:@"%@+%@+%@", streetNumber, streetName, zipCode];
        fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [self getCoordinatesForLocationForDestination:fullAddress];
        
        NSLog(@"%@", error);
    }]resume];

}



@end
