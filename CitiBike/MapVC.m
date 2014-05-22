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
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "DirectionsVC.h"
#import <Reachability/Reachability.h>
#import "NetworkUnavailableVC.h"


@interface MapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) NSSet *markers;
@property (strong, nonatomic) NSMutableArray *closestStationsWithBikes;
@property (strong, nonatomic) NSArray *closestStationsWithDocks;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat directionsOriginDockLatitude;
@property (nonatomic) CGFloat directionsOriginDockLongitude;
@property (nonatomic) CGFloat directionsDestinationDockLatitude;
@property (nonatomic) CGFloat directionsDestinationDockLongitude;
@property (nonatomic) CGFloat destinationLatitude;
@property (nonatomic) CGFloat destinationLongitude;
@property (strong, nonatomic) UIButton *routeButton;
@property (strong, nonatomic) NSArray *stations;
@property (nonatomic) BOOL isRouting;
@property (nonatomic) BOOL isDisplayingDestinationInfo;
@property (strong, nonatomic) UIAlertView *cancelRouteAlert;
@property (strong, nonatomic) GMSMarker *selectedDestination;
@property (nonatomic) CGFloat selectedMarkerLat;
@property (nonatomic) CGFloat selectedMarkerLng;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *directionsListButton;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) UIButton *currentLocationButton;

@end

@implementation MapVC {
    GMSMapView *mapView_;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.routeButton removeFromSuperview];
    
    [CitiBikeAPI downloadStationDataWithCompletion:^(NSArray *stations) {
        self.stations = stations;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkReachabilityWithCompletion:nil];
    self.isRouting = NO;
    self.isDisplayingDestinationInfo = NO;
    self.cancelRouteAlert = [[UIAlertView alloc]initWithTitle:@"Cancel Route" message:@"Would you like to cancel your current route and clear the map?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.cancelRouteAlert.delegate = self;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.73
                                                            longitude:-73.99
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = NO;
    self.view = mapView_;
    mapView_.delegate = self;
    [self showCurrentLocationButton];
    
    [self startDeterminingUserLocation];
    
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
    self.latitude = self.currentLocation.coordinate.latitude;
    self.longitude = self.currentLocation.coordinate.longitude;
    
    
    [mapView_ clear];
    
    [CitiBikeAPI downloadStationDataWithCompletion:^(NSArray *stations) {
        self.stations = stations;
        self.closestStationsWithBikes =[CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createMarkerObjectsForAvailableBikes];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.latitude
                                                                    longitude:self.longitude
                                                                         zoom:6];
            
            [mapView_ animateToCameraPosition:camera];
        });
    }];
    
    [self setPinsForStation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.73
                                                            longitude:-73.99
                                                                 zoom:12];
    
    [mapView_ animateToCameraPosition:camera];
    
    [self.currentLocationButton removeFromSuperview];
    
}

- (void)setPinsForStation
{
    [self checkReachabilityWithCompletion:^{
        [CitiBikeAPI downloadStationDataWithCompletion:^(NSArray *stations) {
            self.stations = stations;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createMarkerObjectsForAvailableBikes];
            });
        }];
    }];
}

- (void)createMarkerObjectsForAvailableBikes
{
    [self checkReachabilityWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [mapView_ clear];
            
            self.closestStationsWithBikes = [CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
            
            NSArray *closestThreeStations = [[NSArray alloc]initWithObjects:self.closestStationsWithBikes[0], self.closestStationsWithBikes[1], self.closestStationsWithBikes[2], nil];
            
            for (NSDictionary *station in closestThreeStations){
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake([station[@"latitude"]floatValue],[station[@"longitude"]floatValue]);
                marker.title = station[@"stAddress1"];
                marker.snippet = [NSString stringWithFormat:@"%@ Bikes and %@ Docks",[station[@"availableBikes"] stringValue], [station[@"availableDocks"] stringValue]];
                UIImage *image = [UIImage imageNamed:@"bicycle"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0, 40.0), NO, 0.0);
                [image drawInRect:CGRectMake(0, 0, 40, 40)];
                UIImage *scaledBike = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                marker.icon = scaledBike;
                marker.map = mapView_;
                
                GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:CLLocationCoordinate2DMake(self.latitude,self.longitude) coordinate:CLLocationCoordinate2DMake([self.closestStationsWithBikes[2][@"latitude"] floatValue], [self.closestStationsWithBikes[2][@"longitude"] floatValue])];
                
                bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake([self.closestStationsWithBikes[1][@"latitude"] floatValue], [self.closestStationsWithBikes[1][@"longitude"] floatValue])];
                
                bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake([self.closestStationsWithBikes[0][@"latitude"] floatValue], [self.closestStationsWithBikes[0][@"longitude"] floatValue])];
                
                [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:100.0f]];
            }
        });
    }];
}

-(void)createMarkerObjectsForAvailableDocks:(NSArray *)docks
{
    [self checkReachabilityWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            CLLocationCoordinate2D originPosition = CLLocationCoordinate2DMake(self.directionsOriginDockLatitude, self.directionsOriginDockLongitude);
            GMSMarker *originMarker = [GMSMarker markerWithPosition:originPosition];
            UIColor *startGreen = [UIColor colorWithRed:0.114 green:0.859 blue:0.333 alpha:1.0];
            originMarker.icon = [GMSMarker markerImageWithColor:startGreen];
            originMarker.map = mapView_;
            
            CLLocationCoordinate2D destinationPosition = CLLocationCoordinate2DMake(self.destinationLatitude, self.destinationLongitude);
            GMSMarker *destinationMarker = [GMSMarker markerWithPosition:destinationPosition];
            UIColor *endRed = [UIColor colorWithRed:0.949 green:0.267 blue:0.263 alpha:1];
            destinationMarker.icon = [GMSMarker markerImageWithColor:endRed];
            destinationMarker.title = self.locationName;
            destinationMarker.map = mapView_;
            
            NSArray *closestThreeStations = @[docks[0], docks[1], docks[2]];
            for (NSDictionary *station in closestThreeStations){
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake([station[@"latitude"]floatValue],[station[@"longitude"]floatValue]);
                if ([station[@"latitude"]floatValue] == self.selectedMarkerLat && [station[@"longitude"]floatValue] == self.selectedMarkerLng) {
                    marker.title = station[@"stAddress1"];
                    marker.snippet = [NSString stringWithFormat:@"%@ Docks",[station[@"availableDocks"] stringValue]];
                    //UIColor *markerColor = [UIColor orangeColor];
                    UIImage *image = [UIImage imageNamed:@"bicycle"];
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0, 40.0), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 40, 40)];
                    UIImage *scaledBike = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    marker.icon = scaledBike;
                    marker.map = mapView_;
                    
                    [mapView_ setSelectedMarker:marker];
                    
                    self.isDisplayingDestinationInfo = YES;
                }
                else{
                    marker.title = station[@"stAddress1"];
                    // UIColor *markerColor = [UIColor orangeColor];
                    UIImage *image = [UIImage imageNamed:@"bicycle"];
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0, 40.0), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 40, 40)];
                    UIImage *scaledBike = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    marker.icon = scaledBike;
                    marker.opacity = 0.4;
                    marker.map = mapView_;
                    
                }
            }
        });
    }];
}



-(void) setNearestStationsArray
{
    [self checkReachabilityWithCompletion:^{
        self.closestStationsWithBikes = [CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
    }];
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self checkReachabilityWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.routeButton removeFromSuperview];
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
                [self.routeButton removeFromSuperview];
            }
        });
    }];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self checkReachabilityWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.routeButton removeFromSuperview];
            if (self.isRouting){
                
                if (marker.position.latitude != self.directionsOriginDockLatitude && marker.position.longitude != self.directionsOriginDockLongitude && marker.position.latitude != self.destinationLatitude && marker.position.longitude != self.destinationLongitude){
                    self.selectedMarkerLat = marker.position.latitude;
                    self.selectedMarkerLng = marker.position.longitude;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [mapView_ clear];
                        [GoogleMapsAPI displayDirectionsfromOriginLatitude:self.directionsOriginDockLatitude andOriginLongitude:self.directionsOriginDockLongitude toDestinationLatitude:self.selectedMarkerLat andDestinationLongitude:self.selectedMarkerLng onMap:mapView_ withCompletion:^(NSDictionary *steps) {
                            self.steps = steps[@"routes"][0][@"legs"][0][@"steps"];
                        }];
                        [self createMarkerObjectsForAvailableDocks:self.closestStationsWithDocks];
                    });
                }
                else if (marker.position.latitude == self.destinationLatitude && marker.position.longitude == self.destinationLongitude){
                    [mapView setSelectedMarker:marker];
                    self.isDisplayingDestinationInfo = YES;
                }
            }
            
            else{
                [mapView setSelectedMarker:marker];
                self.directionsOriginDockLatitude = marker.position.latitude;
                self.directionsOriginDockLongitude = marker.position.longitude;
                [self showDestinationButton];
            }
            
        });
    }];
    return YES;
}

-(void)showDestinationButton
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    self.routeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.routeButton setFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 40,appDelegate.window.frame.size.width-20, 50.0f)];
    [self.routeButton setTitle:@"Directions From Here" forState:UIControlStateNormal];
    [self.routeButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:24]];
    [self.routeButton.titleLabel setTextColor:[UIColor whiteColor]];
    UIColor *backgroundColor = [UIColor colorWithRed:1.0f green:0.568f blue:0.078f alpha:0.75f];
    self.routeButton.backgroundColor = backgroundColor;
    [self.routeButton addTarget:self action:@selector(didTapDestinationButton) forControlEvents:UIControlEventTouchUpInside];
    self.routeButton.layer.cornerRadius = 5;
    self.routeButton.layer.borderWidth = 0;
    [self.view addSubview:self.routeButton];
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
        [self.routeButton removeFromSuperview];
        self.isRouting = YES;
        [self showClearButton];
        [self createDirectionsListButton];
        [self mapDirectionsforDestinationReference:locationReferenceStringForMap];
        
    });
}

-(void)mapDirectionsforDestinationReference:(NSString *)reference
{
    [self checkReachabilityWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [GoogleMapsAPI getAddressForLocationReferenceID:reference withCompletion:^(NSArray *address){
                [GoogleMapsAPI getCoordinatesForLocationForDestination:address[0] withCompletion:^(NSDictionary *destinationCoordinates){
                    self.locationName = address[1];
                    self.destinationLatitude = [destinationCoordinates[@"lat"]floatValue];
                    self.destinationLongitude = [destinationCoordinates[@"lng"] floatValue];
                    
                    self.closestStationsWithDocks = [CitiBikeAPI findNearestStationsWithDocksforLatitude:[destinationCoordinates[@"lat"] floatValue] andLongitude:[destinationCoordinates[@"lng"] floatValue] inArrayOfStations:self.stations];
                    self.directionsDestinationDockLatitude = [self.closestStationsWithDocks[0][@"latitude"] floatValue];
                    self.directionsDestinationDockLongitude = [self.closestStationsWithDocks[0][@"longitude"] floatValue];
                    self.selectedMarkerLat = [self.closestStationsWithDocks[0][@"latitude"] floatValue];
                    self.selectedMarkerLng = [self.closestStationsWithDocks[0][@"longitude"] floatValue];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:CLLocationCoordinate2DMake(self.directionsOriginDockLatitude, self.directionsOriginDockLongitude) coordinate:CLLocationCoordinate2DMake(self.directionsDestinationDockLatitude, self.directionsDestinationDockLongitude)];
                        [mapView_ moveCamera:[GMSCameraUpdate fitBounds:bounds withPadding:75.0f]];
                    });
                    
                    [GoogleMapsAPI displayDirectionsfromOriginLatitude:self.directionsOriginDockLatitude andOriginLongitude:self.directionsOriginDockLongitude toDestinationLatitude:self.directionsDestinationDockLatitude andDestinationLongitude:self.directionsDestinationDockLongitude onMap:mapView_ withCompletion:^(NSDictionary *steps) {
                        self.steps = steps[@"routes"][0][@"legs"][0][@"steps"];
                    }];
                    [self createMarkerObjectsForAvailableDocks:self.closestStationsWithDocks];
                }];
            }];
        });
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        [mapView_ clear];
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        self.isRouting = NO;
        [self.clearButton removeFromSuperview];
        [self.directionsListButton removeFromSuperview];
    }
    else{
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

-(void)showClearButton
{
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [clearButton setTitle:@"Clear Map" forState:UIControlStateNormal];
    [clearButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:20]];
    [clearButton.titleLabel setTextColor:[UIColor whiteColor]];
    
    UIColor *backgroundColor = [UIColor colorWithRed:1.0f green:0.568f blue:0.078f alpha:0.75f];
    clearButton.backgroundColor = backgroundColor;
    
    [clearButton addTarget:self action:@selector(clearMap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:45]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:120]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    clearButton.layer.cornerRadius = 5;
    clearButton.layer.borderWidth = 0;
    
    self.clearButton = clearButton;
}

-(void)clearMap
{
    [mapView_ clear];
    self.isRouting = NO;
    [self.clearButton removeFromSuperview];
    [self.directionsListButton removeFromSuperview];
    [self focusOnCurrentLocation];
}

-(void)showCurrentLocationButton
{
    UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    FAKFontAwesome *icon = [FAKFontAwesome locationArrowIconWithSize:20];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *iconImage = [icon imageWithSize:CGSizeMake(20, 20)];
    [locButton setImage:iconImage forState:UIControlStateNormal];
    
    UIColor *backgroundColor = [UIColor colorWithRed:1.0f green:0.568f blue:0.078f alpha:0.75f];
    locButton.backgroundColor = backgroundColor;
    
    [locButton addTarget:self action:@selector(focusOnCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:locButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:45]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:45]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:locButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    locButton.layer.cornerRadius = 5;
    locButton.layer.borderWidth = 0;
    self.currentLocationButton = locButton;
}

-(void)focusOnCurrentLocation
{
    if (self.isRouting) {
        [mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView_.myLocation.coordinate.latitude
                                                                      longitude:mapView_.myLocation.coordinate.longitude
                                                                           zoom:16]];
    }
    else{
        [self checkReachabilityWithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [mapView_ clear];
                [self.routeButton removeFromSuperview];
                self.latitude = mapView_.myLocation.coordinate.latitude;
                self.longitude = mapView_.myLocation.coordinate.longitude;
                [CitiBikeAPI downloadStationDataWithCompletion:^(NSArray *stations) {
                    self.stations = stations;
                    self.closestStationsWithBikes =[CitiBikeAPI findNearestStationsWithBikesforLatitude:self.latitude andLongitude:self.longitude inArrayOfStations:self.stations];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self createMarkerObjectsForAvailableBikes];
                    });
                }];
            });
        }];
    }
}

-(void)createDirectionsListButton
{
    UIButton *directionsListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [directionsListButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    FAKFontAwesome *icon = [FAKFontAwesome listIconWithSize:20];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *iconImage = [icon imageWithSize:CGSizeMake(20, 20)];
    [directionsListButton setImage:iconImage forState:UIControlStateNormal];
    
    UIColor *backgroundColor = [UIColor colorWithRed:1.0f green:0.568f blue:0.078f alpha:0.75f];
    directionsListButton.backgroundColor = backgroundColor;
    
    [directionsListButton addTarget:self action:@selector(showDirectionsListVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:directionsListButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:directionsListButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:45]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:directionsListButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:45]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:directionsListButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:directionsListButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    directionsListButton.layer.cornerRadius = 5;
    directionsListButton.layer.borderWidth = 0;
    self.directionsListButton = directionsListButton;
    
}

-(void)showDirectionsListVC
{
    DirectionsVC *directionsVC = [[DirectionsVC alloc] init];
    directionsVC.steps = self.steps;
    [self presentViewController:directionsVC animated:YES completion:^{
        nil;
    }];
}

-(void)checkReachabilityWithCompletion:(void (^)())completion
{
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.maps.google.com"];
    
    reach.unreachableBlock = ^(Reachability *reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapVC *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NetworkUnavailableVC"];
            [self presentViewController:vc animated:YES completion:nil];
            [reach stopNotifier];
            
        });
    };
    
    reach.reachableBlock = ^(Reachability *reach)
    {
        [reach stopNotifier];
        if (completion) {
            completion();
        }
    };
    
    [reach startNotifier];
}
@end
