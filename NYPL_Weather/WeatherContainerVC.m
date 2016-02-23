//
//  WeatherContainerVC.m
//  NYPL_Weather
//
//  Created by Wesley Hovanec on 12/21/15.
//  Copyright © 2015 Wesley Hovanec. All rights reserved.
//

#import "WeatherContainerVC.h"

#import "WeatherDataManager.h"
#import "WeatherInfoVC.h"
#import "WeatherDate.h"

@interface WeatherContainerVC ()

//Last index will contain the latest date.
@property (nonatomic, strong)NSArray *weatherDates;

@property (nonatomic, strong)UIPageViewController *pageViewController;

@property (nonatomic, strong)UIImageView *backgroundImageView;
@property (nonatomic, strong)UINavigationBar *navigationBar;
@property (nonatomic, strong)UINavigationItem *navigationItem;
@property (nonatomic, strong)UIBarButtonItem *updateButton;

@end



@implementation WeatherContainerVC

#pragma mark -Set Up Views

- (void)viewDidLoad {
    [super viewDidLoad];
    [[WeatherDataManager sharedWeatherDataManager] addObserver:self forKeyPath:@"weatherDates" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Error" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self handleErrorWithInfo:note.userInfo];
    }];
    self.weatherDates = [[WeatherDataManager sharedWeatherDataManager] weatherDates];
    [self requestUpdateWeatherDates];
}

-(void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    [self setUpBackground];
    [self setUpNavigationBar];
    [self setUpPageViewController];
    [self setUpAutoLayoutConstraints];
}

-(void)setUpBackground {
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundImageView.image = [UIImage imageNamed:@"Background.jpg"];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundImageView];
}

-(void)setUpNavigationBar {
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.navigationBar];
    
    self.navigationItem = [[UINavigationItem alloc] init];
    self.navigationBar.items = @[self.navigationItem];
    
    self.updateButton = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(requestUpdateWeatherDates)];
    self.navigationItem.rightBarButtonItem = self.updateButton;
}

-(void)setUpPageViewController {
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    [self.pageViewController  setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

-(void)setUpAutoLayoutConstraints {
    id topGuide = self.topLayoutGuide;
    id backgroundImageView = self.backgroundImageView;
    id navigationBar = self.navigationBar;
    id pageViewController = self.pageViewController.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(backgroundImageView, topGuide, navigationBar, pageViewController);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[topGuide]-0-[navigationBar(==44)]-0-[backgroundImageView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backgroundImageView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[navigationBar]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[navigationBar]-0-[pageViewController]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pageViewController]-0-|" options:0 metrics:nil views:views]];
}

#pragma mark -Weather Updates

-(void)requestUpdateWeatherDates {
    self.updateButton.enabled = NO;
    [[WeatherDataManager sharedWeatherDataManager] updateWeatherDates];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == [WeatherDataManager sharedWeatherDataManager] && [keyPath isEqualToString:@"weatherDates"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.weatherDates = [change valueForKey:@"new"];
            [self.pageViewController  setViewControllers:@[[self viewControllerAtIndex:self.weatherDates.count - 1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            self.navigationItem.title = [(WeatherInfoVC *)[self.pageViewController.viewControllers firstObject] currentWeatherDate].date;
            self.updateButton.enabled = YES;
        });
    }
}

-(void)handleErrorWithInfo:(NSDictionary *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Updating Weather" message:[info valueForKey:@"error"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:^{
            self.updateButton.enabled = YES;
        }];
    });
}

#pragma mark -UIPageViewController Data Source

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.weatherDates.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return self.weatherDates.count - 1;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [(WeatherInfoVC *)viewController index];
    if (index == 0) {
        return nil;
    }
    return [self viewControllerAtIndex:--index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [(WeatherInfoVC *)viewController index];
    if (index == self.weatherDates.count - 1) {
        return nil;
    }
    return [self viewControllerAtIndex:++index];
}

-(WeatherInfoVC *)viewControllerAtIndex:(NSInteger)index {
    WeatherInfoVC *vc = [[WeatherInfoVC alloc] init];
    vc.index = index;
    vc.currentWeatherDate = [self.weatherDates objectAtIndex:index];
    
    return vc;
}

#pragma mark -UIPageViewController Delegate

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.navigationItem.title = [(WeatherInfoVC *)[pageViewController.viewControllers firstObject] currentWeatherDate].date;
    }
}

#pragma mark -Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
