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
//    NSMutableDictionary *md = [stationsList mutableCopy];
//#warning blocks the main thread
    NSArray *stations = [stationsList valueForKeyPath:@"stationBeanList"];
    NSArray *individual = [stations valueForKeyPath:@"availableBikes"];
    NSLog(@"station list = %@", stations);
    
    self.stations = stations;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.stations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // what did you put in the storyboard for the identifier
    static NSString *CellIdentifier = @"Station Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // configure the cells
    NSDictionary *stations = self.stations[indexPath.row];
    cell.textLabel.text = [stations valueForKeyPath:@"stationName"];
    
    cell.detailTextLabel.text = [stations[@"availableBikes"] stringValue];
    
    return cell;
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
