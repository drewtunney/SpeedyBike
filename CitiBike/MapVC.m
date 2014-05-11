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
#import "GoogleMapsAPI.h"

@interface MapVC () <GMSMapViewDelegate>

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
@property (strong, nonatomic) NSArray *stations;
@property (nonatomic) BOOL isRouting;
@property (strong, nonatomic) UIAlertView *cancelRouteAlert;

@end

@implementation MapVC {
    GMSMapView *mapView_;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.button removeFromSuperview];
}

- (void)viewDidLoad
{
    [self startDeterminingUserLocation];
    self.isRouting = NO;
    self.cancelRouteAlert = [[UIAlertView alloc]initWithTitle:@"Cancel Route" message:@"Would you like to cancel your current route and clear the map?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.cancelRouteAlert.delegate = self;
    
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
    
    self.closestStations = [CitiBikeAPI findNearestStationsforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
    
    NSArray *closestThreeStations = [[NSArray alloc]initWithObjects:self.closestStations[0], self.closestStations[1], self.closestStations[2], nil];
    for (NSDictionary *station in closestThreeStations){
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[station valueForKeyPath:@"latitude"]floatValue], [[station valueForKeyPath:@"longitude"]floatValue]);
        marker.title = [station valueForKeyPath:@"stAddress1"];
        marker.snippet = [NSString stringWithFormat:@"%@ available bikes",[[station valueForKeyPath:@"availableBikes"] stringValue]];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
        marker.map = mapView_;
    }
}

-(void) setNearestStationsArray
{
    self.closestStations = [CitiBikeAPI findNearestStationsforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.button removeFromSuperview];
    
    if (self.isRouting) {
         [self.cancelRouteAlert show];
    }
    else{
    self.latitude = coordinate.latitude;
    self.longitude = coordinate.longitude;
    [self setPinsForStation];
    [self.button removeFromSuperview];
    }
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView
{
    if (self.isRouting) {
        [mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude
                                                                     longitude:mapView.myLocation.coordinate.longitude
                                                                          zoom:16]];
    }
    else{
    [mapView clear];
    [mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude
                                                                  longitude:mapView.myLocation.coordinate.longitude
                                                                       zoom:16]];
    self.latitude = mapView.myLocation.coordinate.latitude;
    self.longitude = mapView.myLocation.coordinate.longitude;
    [self setPinsForStation];
    }
    return YES;
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self.button removeFromSuperview];
    [mapView setSelectedMarker:marker];
    self.directionsOriginLatitude = marker.position.latitude;
    self.directionsOriginLongitude = marker.position.longitude;
    [self showDestinationButton];
    return YES;
}

-(void)showDestinationButton
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
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
    if (self.isRouting) {
        [self.cancelRouteAlert show];
    }else{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationsViewController *locationsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
    locationsViewController.latitude = self.latitude;
    locationsViewController.longitude = self.longitude;
    locationsViewController.locationDelegate = self;
    [self presentViewController:locationsViewController animated:YES completion:nil];
    }
}

-(void)secondViewControllerDismissed:(NSString *)locationReferenceStringForMap
{
    [mapView_ clear];
    [self.button removeFromSuperview];
    self.isRouting = YES;
    [self mapDirectionsforDestinationReference:locationReferenceStringForMap];
}

-(void)mapDirectionsforDestinationReference:(NSString *)reference
{
    [GoogleMapsAPI getAddressForLocationReferenceID:reference withCompletion:^(NSString *address) {
        [GoogleMapsAPI getCoordinatesForLocationForDestination:address withCompletion:^(NSDictionary *destinationCoordinates) {
            self.directionsDestinationLatitude = [destinationCoordinates[@"lat"] floatValue];
            self.directionsDestinationLongitude = [destinationCoordinates[@"lng"] floatValue];
            [GoogleMapsAPI displayDirectionsfromOriginLatitude:self.directionsOriginLatitude andOriginLongitude:self.directionsOriginLongitude toDestinationLatitude:self.directionsDestinationLatitude andDestinationLongitude:self.directionsDestinationLongitude onMap:mapView_];
        }];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        [mapView_ clear];
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        self.isRouting = NO;
    }
    else{
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

@end
