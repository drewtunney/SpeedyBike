//
//  LocationsViewController.m
//  CitiBike
//
//  Created by Dare Ryan on 5/9/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "LocationsViewController.h"
#import "Constants.h"
#import "GoogleMapsAPI.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface LocationsViewController ()
- (IBAction)textFieldEditingChanged:(id)sender;
- (IBAction)returnPressed:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *responseDictArray;
@property (strong, nonatomic) NSString *selectedLocation;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end

@implementation LocationsViewController

@synthesize locationDelegate = _locationDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.textField.delegate = self;
    
    [self.textField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:18]];
    self.textField.placeholder = @"Enter Destination";
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    FAKFontAwesome *arrowIcon = [FAKFontAwesome angleLeftIconWithSize:35];
    [arrowIcon addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]];
    UIImage *buttonImage = [arrowIcon imageWithSize:CGSizeMake(35,35)];
    [self.backButton setTitle:nil];
    [self.backButton setImage:buttonImage];
    [self.backButton setTintColor:[UIColor orangeColor]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView setHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    
    [self.textField becomeFirstResponder];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.responseDictArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18]];
    cell.textLabel.text = self.responseDictArray[indexPath.row][@"description"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLocation = self.responseDictArray[indexPath.row][@"reference"];
    if ([self.locationDelegate respondsToSelector:@selector(secondViewControllerDismissed:)]) {
        [self.locationDelegate secondViewControllerDismissed:self.selectedLocation];
    }
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];

    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)textFieldEditingChanged:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSearchResults) object:nil];
    
    [self performSelector:@selector(updateSearchResults) withObject:nil afterDelay:0.50];
}

- (IBAction)returnPressed:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSearchResults) object:nil];
    [self updateSearchResultsWithCompletion:^{
        if ([self.responseDictArray count]==0 && ![self.textField.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No locations found" message:@"There are no locations matching you search query" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
        }
        else{
            self.selectedLocation = self.responseDictArray[0][@"reference"];
            if ([self.locationDelegate respondsToSelector:@selector(secondViewControllerDismissed:)]) {
                [self.locationDelegate secondViewControllerDismissed:self.selectedLocation];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                transition.duration = 0.35;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionMoveIn;
                transition.subtype = kCATransitionFromLeft;
                [self.view.window.layer addAnimation:transition forKey:nil];

                [self dismissViewControllerAnimated:NO completion:nil];
            });
        }
    }];
}

- (IBAction)backButtonTapped:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];

     [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)updateSearchResultsWithCompletion:(void (^)())completion
{
    
    
    [GoogleMapsAPI updateListWithSuggestedPlacesForName:self.textField.text forLatitude:self.latitude andLongitude:self.longitude withCompletion:^(NSMutableArray *responseObjects) {
        self.responseDictArray = responseObjects;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView setHidden:NO];
            [self.tableView reloadData];
        });
        completion();
    }];
}

-(void)updateSearchResults
{
    [GoogleMapsAPI updateListWithSuggestedPlacesForName:self.textField.text forLatitude:self.latitude andLongitude:self.longitude withCompletion:^(NSMutableArray *responseObjects) {
        self.responseDictArray = responseObjects;
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView setHidden:NO];
            [self.tableView reloadData];
        });
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
}


@end
