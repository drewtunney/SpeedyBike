//
//  LocationsViewController.m
//  CitiBike
//
//  Created by Dare Ryan on 5/9/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "LocationsViewController.h"

@interface LocationsViewController ()
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)textFieldEditingChanged:(id)sender;
- (IBAction)routeButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LocationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning override with response array count
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldEditingChanged:(id)sender
{
}

- (IBAction)routeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
