//
//  NetworkUnavailableVC.m
//
//
//  Created by Dare Ryan on 5/20/14.
//
//

#import "NetworkUnavailableVC.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <Reachability/Reachability.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Constants.h"
#import "MapVC.h"

@interface NetworkUnavailableVC ()
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIImageView *centerImage;
- (IBAction)retryButtonTapped:(id)sender;

@end

@implementation NetworkUnavailableVC

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
    [self checkReachability];
    FAKFontAwesome *refreshIcon = [FAKFontAwesome refreshIconWithSize:30];
    UIImage *image = [refreshIcon imageWithSize:CGSizeMake(30, 30)];
    [self.retryButton setImage:image forState:UIControlStateNormal];
    [self.retryButton setTitle:@"Retry" forState:UIControlStateNormal];
    [self.retryButton setTintColor:[UIColor orangeColor]];
    
    FAKFontAwesome *globeIcon = [FAKFontAwesome globeIconWithSize:60];
    [globeIcon addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]];
    UIImage *globeImage = [globeIcon imageWithSize:CGSizeMake(60, 60)];
    
    [self.centerImage setImage:globeImage];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)retryButtonTapped:(id)sender {
    [self checkReachability];
}

-(void)checkReachability
{
    
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.maps.google.com"];
    
    reach.reachableBlock = ^(Reachability *reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapVC *mapVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MapVC"];
            [self presentViewController:mapVC animated:NO completion:nil];
            [reach stopNotifier];
        });
        
    };
    reach.unreachableBlock = ^(Reachability *reach)
    {
        [reach stopNotifier];
    };

    [reach startNotifier];

}
@end
