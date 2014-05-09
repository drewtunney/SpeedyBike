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
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) GMSPolyline *directionsLine;



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
    [self downloadStationData:nil];
}


- (void)downloadStationData:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    
    NSURLSessionDataTask *task = [self.getStations dataTaskWithURL:url completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error)
    {
        NSArray *stationsList = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                       error:NULL];
        NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
       // NSLog(@"Current Location = %@", mapView_.myLocation);
        self.stations = stations;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self createMarkerObjectsWithJson:stationsList];
        }];
    }];
    [task resume];
}

- (void)createMarkerObjectsWithJson:(NSArray *)markers
{

    [mapView_ clear];
   
        [self findNearestStations:self.stations];
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



//- (void)calculateDistance:(float *)lat1, (float *)lat2, (float *)lon1, (float *)lon2
//{
//    
//}

#pragma mark - GMSMapViewDelegate

-(void)findNearestStations:(NSArray *)stations
{
    self.closestStations = [[NSMutableArray alloc]init];
    
    for (NSDictionary *station in self.stations) {
        
        if ([station[@"availableBikes"] integerValue] > 1 && [station[@"statusValue"] isEqualToString:@"In Service"]) {
            CGFloat latitude = self.latitude - [station[@"latitude"] floatValue];
            CGFloat longitude = self.longitude - [station[@"longitude"] floatValue];
            CGFloat distanceFloat = latitude*latitude + longitude*longitude;
            NSNumber *distance = [NSNumber numberWithFloat:distanceFloat];
            NSMutableDictionary *availableStationDict = [NSMutableDictionary dictionaryWithDictionary:station];
            [availableStationDict setObject:distance forKey:@"distance"];
            [self.closestStations addObject:availableStationDict];
            
        }
        
    }
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
    [self downloadStationData:nil];
    [self.button removeFromSuperview];
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView{
    [mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude
                                                                  longitude:mapView.myLocation.coordinate.longitude
                                                                       zoom:16]];
    self.latitude = mapView.myLocation.coordinate.latitude;
    self.longitude = mapView.myLocation.coordinate.longitude;
     [self downloadStationData:nil];
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
    self.button.backgroundColor = [UIColor whiteColor];
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

-(void)secondViewControllerDismissed:(NSString *)locationStringForMap
{
    self.location = locationStringForMap;
    [self getCoordinatesForLocationForDestination:[self.location stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSLog(@"%@", self.location);
}

-(void)getDirectionFromBikeDock
{

   // NSString *URLformattedDestination = [self.location stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    //URLformattedDestination = [URLformattedDestination stringByReplacingOccurrencesOfString:@"," withString:@"-"];
    
    NSString *directionsURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&key=%@&avoid=ferries&mode=bicycling", self.directionsOriginLatitude, self.directionsOriginLongitude,self.directionsDestinationLatitude, self.directionsDestinationLongitude,Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:directionsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", JSONResponseDict);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            GMSPath *path = [GMSPath pathFromEncodedPath:JSONResponseDict[@"routes"][0][@"overview_polyline"][@"points"]];
            self.directionsLine = [GMSPolyline polylineWithPath:path];
            self.directionsLine.strokeWidth = 7;
            self.directionsLine.strokeColor = [UIColor greenColor];
            self.directionsLine.map = mapView_;

        });
               //NSLog(@"%@", JSONResponseDict[@"predictions"][0][@"description"]);
                NSLog(@"%@", error);
    }]resume];

}

-(void)getCoordinatesForLocationForDestination:(NSString *)location
{
#warning investigate call response for unknown addresses e.g. Warby Parker, Apple SoHo etc. 
    
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&key=%@", location, Web_Browser_Key];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
       // NSLog(@"%@", JSONResponseDict);
        
        NSLog(@"%@", JSONResponseDict);
        self.directionsDestinationLatitude = [JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lat"] floatValue];
        self.directionsDestinationLongitude = [JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lng"] floatValue];
        NSLog(@"Given coordinates: %f, %f", self.directionsDestinationLatitude, self.directionsDestinationLongitude);
        
        [self getDirectionFromBikeDock];
        //NSLog(@"%@", JSONResponseDict);
        
        NSLog(@"%@", error);
    }]resume];
}



@end
