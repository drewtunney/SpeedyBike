//
//  LocationsViewController.h
//  CitiBike
//
//  Created by Dare Ryan on 5/9/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SecondDelegate <NSObject>
-(void)secondViewControllerDismissed:(NSString *)locationStringForMap;
@end

@interface LocationsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    id locationDelegate;
}
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, assign) id<SecondDelegate> locationDelegate;


@end
