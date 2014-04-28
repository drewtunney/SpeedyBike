//
//  StationInfoTableViewController.m
//  CitiBike
//
//  Created by Drew Tunney on 4/28/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "StationInfoTableViewController.h"

@interface StationInfoTableViewController ()

@end

@implementation StationInfoTableViewController

- (void)setStations:(NSArray *)stations
{
    _stations = stations;
    [self.tableView reloadData];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchStations];
}

-(void)fetchStations
{
    NSURL *url = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    NSDictionary *stationsList = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                 options:0
                                                                   error:NULL];
    NSLog(@"CitiBike Results = %@", stationsList);
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
