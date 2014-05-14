//
//  MapVC.m
//  CitiBike
//
//  Created by Drew Tunney on 5/2/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "MapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "CitiBikeAPI.h"
#import "GoogleMapsAPI.h"

@interface MapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) NSSet *markers;
@property (strong, nonatomic) NSMutableArray *closestStationsWithBikes;
@property (strong, nonatomic) NSArray *closestStationsWithDocks;
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
@property (nonatomic) BOOL isDisplayingDestinationInfo;
@property (strong, nonatomic) UIAlertView *cancelRouteAlert;
@property (strong, nonatomic) GMSMarker *selectedDestination;
@property (nonatomic) CGFloat selectedMarkerLat;
@property (nonatomic) CGFloat selectedMarkerLng;

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
    self.isDisplayingDestinationInfo = NO;
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createMarkerObjectsForAvailableBikes];
        });
    }];
}

- (void)createMarkerObjectsForAvailableBikes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView_ clear];
        
        self.closestStationsWithBikes = [CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
        
        NSArray *closestThreeStations = [[NSArray alloc]initWithObjects:self.closestStationsWithBikes[0], self.closestStationsWithBikes[1], self.closestStationsWithBikes[2], nil];
        
        for (NSDictionary *station in closestThreeStations){
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([station[@"latitude"]floatValue],[station[@"longitude"]floatValue]);
            marker.title = station[@"stAddress1"];
            marker.snippet = [NSString stringWithFormat:@"%@ available bikes",[station[@"availableBikes"] stringValue]];
            UIColor *markerColor = [UIColor colorWithRed:0.106 green:0.643 blue:1.0 alpha:1.0];
            marker.icon = [GMSMarker markerImageWithColor:markerColor];
            marker.map = mapView_;
        }
    });
}

-(void)createMarkerObjectsForAvailableDocks:(NSArray *)docks
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CLLocationCoordinate2D originPosition = CLLocationCoordinate2DMake(self.directionsOriginLatitude, self.directionsOriginLongitude);
        GMSMarker *originMarker = [GMSMarker markerWithPosition:originPosition];
        UIColor *markerColor = [UIColor colorWithRed:0.106 green:0.643 blue:1.0 alpha:1.0];
        originMarker.icon = [GMSMarker markerImageWithColor:markerColor];
        originMarker.map = mapView_;
        
        NSArray *closestThreeStations = @[docks[0], docks[1], docks[2]];
        for (NSDictionary *station in closestThreeStations){
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([station[@"latitude"]floatValue],[station[@"longitude"]floatValue]);
            if ([station[@"latitude"]floatValue] == self.selectedMarkerLat && [station[@"longitude"]floatValue] == self.selectedMarkerLng) {
                marker.title = station[@"stAddress1"];
                marker.snippet = [NSString stringWithFormat:@"%@ available docks",[station[@"availableDocks"] stringValue]];
                UIColor *markerColor = [UIColor orangeColor];
                marker.icon = [GMSMarker markerImageWithColor:markerColor];
                marker.map = mapView_;
                [mapView_ setSelectedMarker:marker];
                self.isDisplayingDestinationInfo = YES;
            }
            else{
                marker.title = station[@"stAddress1"];
                UIColor *markerColor = [UIColor orangeColor];
                marker.icon = [GMSMarker markerImageWithColor:markerColor];
                marker.opacity = 0.4;
                marker.map = mapView_;
            }
        }
    });
}

-(void) setNearestStationsArray
{
    self.closestStationsWithBikes = [CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.button removeFromSuperview];
    if (self.isRouting && self.isDisplayingDestinationInfo) {
        [mapView setSelectedMarker:nil];
        self.isDisplayingDestinationInfo = NO;
    }
    else if (self.isRouting && !self.isDisplayingDestinationInfo) {
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
        self.latitude = mapView.myLocation.coordinate.latitude;
        self.longitude = mapView.myLocation.coordinate.longitude;
        [CitiBikeAPI downloadStationDataWithCompletion:^(NSArray *stations) {
            self.stations = stations;
            self.closestStationsWithBikes =[CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createMarkerObjectsForAvailableBikes];
                
                GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:CLLocationCoordinate2DMake(self.latitude,self.longitude) coordinate:CLLocationCoordinate2DMake([self.closestStationsWithBikes[2][@"latitude"] floatValue], [self.closestStationsWithBikes[2][@"longitude"] floatValue])];
                
                bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake([self.closestStationsWithBikes[1][@"latitude"] floatValue], [self.closestStationsWithBikes[1][@"longitude"] floatValue])];
                
                bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake([self.closestStationsWithBikes[0][@"latitude"] floatValue], [self.closestStationsWithBikes[0][@"longitude"] floatValue])];
                
                [mapView_ moveCamera:[GMSCameraUpdate fitBounds:bounds withPadding:100.0f]];
            });
        }];
    }
    return YES;
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self.button removeFromSuperview];
    if (self.isRouting){
        if (marker.position.latitude != self.directionsOriginLatitude && marker.position.longitude != self.directionsOriginLongitude){
            self.selectedMarkerLat = marker.position.latitude;
            self.selectedMarkerLng = marker.position.longitude;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [mapView_ clear];
                [GoogleMapsAPI displayDirectionsfromOriginLatitude:self.directionsOriginLatitude andOriginLongitude:self.directionsOriginLongitude toDestinationLatitude:self.selectedMarkerLat andDestinationLongitude:self.selectedMarkerLng onMap:mapView_];
                [self createMarkerObjectsForAvailableDocks:self.closestStationsWithDocks];
            });
        }
    }
    else{
        [mapView setSelectedMarker:marker];
        self.directionsOriginLatitude = marker.position.latitude;
        self.directionsOriginLongitude = marker.position.longitude;
        [self showDestinationButton];
    }
    return YES;
}

-(void)showDestinationButton
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 40,appDelegate.window.frame.size.width-20, 50.0f)];
    [self.button setTitle:@"Get Directions From Here" forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.button.titleLabel setTextColor:[UIColor whiteColor]];
    //UIColor *backgroundColor = [UIColor colorWithWhite:1.0 alpha:.75];
    UIColor *backgroundColor = [UIColor colorWithRed:0.0f green:0.8f blue:0.086f alpha:0.75f];
    self.button.backgroundColor = backgroundColor;
    [self.button addTarget:self action:@selector(didTapDestinationButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

-(void)didTapDestinationButton
{
    if (self.isRouting){
        [self.cancelRouteAlert show];
    }
    else{
        NSDictionary *navBarTitleAttributes = @{NSForegroundColorAttributeName:[UIColor orangeColor]};
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *locationsNavController = [storyBoard instantiateViewControllerWithIdentifier:@"LocationsNavController"];
        [locationsNavController.navigationBar setTitleTextAttributes:navBarTitleAttributes];
        LocationsViewController *locationsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
        [locationsNavController setViewControllers:@[locationsViewController] animated:NO];
        locationsViewController.latitude = self.latitude;
        locationsViewController.longitude = self.longitude;
        locationsViewController.locationDelegate = self;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.35;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:transition forKey:nil];
        [self presentViewController:locationsNavController animated:NO completion:nil];
    }
}

-(void)secondViewControllerDismissed:(NSString *)locationReferenceStringForMap
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView_ clear];
        [self.button removeFromSuperview];
        self.isRouting = YES;
        [self mapDirectionsforDestinationReference:locationReferenceStringForMap];
        
    });
}

-(void)mapDirectionsforDestinationReference:(NSString *)reference
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GoogleMapsAPI getAddressForLocationReferenceID:reference withCompletion:^(NSString *address){
            [GoogleMapsAPI getCoordinatesForLocationForDestination:address withCompletion:^(NSDictionary *destinationCoordinates){
                
                
                self.closestStationsWithDocks = [CitiBikeAPI findNearestStationsWithDocksforLatitude:[destinationCoordinates[@"lat"] floatValue] andLongitude:[destinationCoordinates[@"lng"] floatValue] inArrayOfStations:self.stations];
                self.directionsDestinationLatitude = [self.closestStationsWithDocks[0][@"latitude"] floatValue];
                self.directionsDestinationLongitude = [self.closestStationsWithDocks[0][@"longitude"] floatValue];
                self.selectedMarkerLat = [self.closestStationsWithDocks[0][@"latitude"] floatValue];
                self.selectedMarkerLng = [self.closestStationsWithDocks[0][@"longitude"] floatValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:CLLocationCoordinate2DMake(self.directionsOriginLatitude, self.directionsOriginLongitude) coordinate:CLLocationCoordinate2DMake(self.directionsDestinationLatitude, self.directionsDestinationLongitude)];
                    [mapView_ moveCamera:[GMSCameraUpdate fitBounds:bounds withPadding:75.0f]];
                });
                
                [GoogleMapsAPI displayDirectionsfromOriginLatitude:self.directionsOriginLatitude andOriginLongitude:self.directionsOriginLongitude toDestinationLatitude:self.directionsDestinationLatitude andDestinationLongitude:self.directionsDestinationLongitude onMap:mapView_];
                [self createMarkerObjectsForAvailableDocks:self.closestStationsWithDocks];
            }];
        }];
    });
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
