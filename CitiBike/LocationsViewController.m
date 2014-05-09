//
//  LocationsViewController.m
//  CitiBike
//
//  Created by Dare Ryan on 5/9/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "LocationsViewController.h"
#import "Constants.h"

@interface LocationsViewController ()
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)textFieldEditingChanged:(id)sender;
- (IBAction)routeButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *responseDictArray;
@property (strong, nonatomic) NSString *selectedLocation;


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
    return [self.responseDictArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.responseDictArray[indexPath.row][@"description"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLocation = self.responseDictArray[indexPath.row][@"description"];
    if ([self.locationDelegate respondsToSelector:@selector(secondViewControllerDismissed:)]) {
        [self.locationDelegate secondViewControllerDismissed:self.selectedLocation];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldEditingChanged:(id)sender
{
    [self updateListWithSuggestedPlacesForName:self.textField.text];
    
}

- (IBAction)routeButtonTapped:(id)sender
{
    if ([self.responseDictArray count] > 0) {
        self.selectedLocation = self.responseDictArray[0][@"description"];
        if ([self.locationDelegate respondsToSelector:@selector(secondViewControllerDismissed:)]) {
            [self.locationDelegate secondViewControllerDismissed:self.selectedLocation];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No locations found" message:@"There are no locations matching you search query" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
   
}

-(void)updateListWithSuggestedPlacesForName:(NSString *)textInput
{
    self.responseDictArray = [[NSMutableArray alloc]init];
    
    NSString *searchString = [textInput stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=17000&sensor=true&key=%@", searchString, self.latitude, self.longitude, Web_Browser_Key];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        //NSLog(@"%@", JSONResponseDict[@"predictions"][0][@"description"]);
        for (NSDictionary *location in JSONResponseDict[@"predictions"]) {
            [self.responseDictArray addObject:location];
        }
        NSLog(@"%@", error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }]resume];
}
@end
