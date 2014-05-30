//
//  DemoViewController.m
//  CitiBike
//
//  Created by Dare Ryan on 5/22/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "DemoViewController.h"
#import "MapVC.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Create the data model
    _pageTitles = @[@"Tap anywhere on the map to find the 3 closest bike stations", @"Tap a station for bike and dock availability. Tap 'Directions From Here' to plan your ride.", @"Tell us where you want to go.", @"Check out your route! Yup, the directions are bike path optimized. Thanks, Google.", @"Want turn by turn directions? We have that too. Happy Biking.", @""];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png", @"page5", @"letsride2"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 10);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    if (index == [self.pageImages count] -1) {
        
        PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
        pageContentViewController.imageFile = self.pageImages[index];
        pageContentViewController.titleText = self.pageTitles[index];
        pageContentViewController.pageIndex = index;
    
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [pageContentViewController.view addGestureRecognizer:tapGestureRecognizer];
        //self.pageViewController.view.userInteractionEnabled = NO;
       // pageContentViewController.view.userInteractionEnabled = NO;
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didTap)];
        [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionLeft)];
         [pageContentViewController.view addGestureRecognizer:swipeGesture];
        pageContentViewController.view.backgroundColor = [UIColor orangeColor];
        return pageContentViewController;
    }
    
    // Create a new view controller and pass suitable data.
    
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
    
    
}

#pragma mark - Page View Controller Data Source

-(void)didTap
{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"DemoDone" forKey:@"DemoDone"];
    [defaults synchronize];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapVC *map = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MapVC"];
    [self presentViewController:map animated:YES completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end

