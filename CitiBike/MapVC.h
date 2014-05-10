//
//  MapVC.h
//  CitiBike
//
//  Created by Drew Tunney on 5/2/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationsViewController.h"

@interface MapVC : UIViewController<CLLocationManagerDelegate, SecondDelegate, UIAlertViewDelegate>



@end
