//
//  CSDirectionsVC.m
//  cs-maps-level4
//
//  Created by Jon Friskics on 1/24/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

#import "DirectionsVC.h"

#import "DirectionsCell.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

@interface DirectionsVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DirectionsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 40, 320, 30);
    [backButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateHighlighted];
    [backButton setTitle:@"Back To Map" forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor orangeColor]];
    
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:backButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:backButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    

   
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.tableView reloadData];
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                      CGRectGetMinY(self.view.bounds),
                                      CGRectGetWidth(self.view.bounds),
                                      CGRectGetHeight(self.view.bounds) - 50);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.steps.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DirectionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"directionsCell"];
    
    if(cell == nil) {
        cell = [[DirectionsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *step = self.steps[indexPath.row];
    
    NSString *htmlStringWithFormatting = [NSString stringWithFormat:@"%@ %@",@"<style type='text/css'>body { font-size: 16px; font-family: Helvetica; font-weight: 100; }</style>",step[@"html_instructions"]];
    
    [cell.directionsWebView loadHTMLString:htmlStringWithFormatting baseURL:nil];
    
    
    cell.distanceLabel.text = step[@"distance"][@"text"];
    
    if([htmlStringWithFormatting rangeOfString:@"north"].location == NSNotFound && [htmlStringWithFormatting rangeOfString:@"south"].location == NSNotFound && [htmlStringWithFormatting rangeOfString:@"east"].location == NSNotFound && [htmlStringWithFormatting rangeOfString:@"west"].location == NSNotFound){
        
        FAKFontAwesome *icon = [FAKFontAwesome arrowUpIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]];
        cell.directionImage.image = [icon imageWithSize:CGSizeMake(30, 30)];
    }

    
    if ([htmlStringWithFormatting rangeOfString:@"left"].location != NSNotFound) {
        
        FAKFontAwesome *icon = [FAKFontAwesome arrowLeftIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]];
        cell.directionImage.image = [icon imageWithSize:CGSizeMake(30, 30)];
    }
    if ([htmlStringWithFormatting rangeOfString:@"right"].location != NSNotFound) {
    
        FAKFontAwesome *icon = [FAKFontAwesome arrowRightIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]];
        cell.directionImage.image = [icon imageWithSize:CGSizeMake(30, 30)];
    }
   
    if ([htmlStringWithFormatting rangeOfString:@"Destination"].location != NSNotFound || [htmlStringWithFormatting rangeOfString:@"Head"].location != NSNotFound){
        FAKFontAwesome *icon = [FAKFontAwesome mapMarkerIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]];
        cell.directionImage.image = [icon imageWithSize:CGSizeMake(30, 30)];
    }
    
    
    return cell;
}


- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
