//
//  WeatherInfoVC.m
//  NYPL_Weather
//
//  Created by Wesley Hovanec on 12/21/15.
//  Copyright © 2015 Wesley Hovanec. All rights reserved.
//

#import "WeatherInfoVC.h"

#import "WeatherDate.h"

@interface WeatherInfoVC ()

@property (nonatomic, strong)UILabel *temperatureHighLabel;
@property (nonatomic, strong)UILabel *temperatureLowLabel;

@end



@implementation WeatherInfoVC

#pragma mark -Set Up Views

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.temperatureHighLabel.text = [NSString stringWithFormat:@"Hi %.2fK", self.currentWeatherDate.temperatureHigh];
    self.temperatureLowLabel.text = [NSString stringWithFormat:@"Lo %.2fK", self.currentWeatherDate.temperatureLow];
}

-(void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    contentView.backgroundColor = [UIColor clearColor];
    self.view = contentView;
    
    [self setUpLabels];
    [self setUpAutoLayoutConstraints];
}

-(void)setUpLabels {
    self.temperatureHighLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.temperatureHighLabel.backgroundColor = [UIColor whiteColor];
    self.temperatureHighLabel.alpha = 0.85;
    self.temperatureHighLabel.layer.cornerRadius = 10.0;
    self.temperatureHighLabel.textAlignment = NSTextAlignmentCenter;
    self.temperatureHighLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:52];
    self.temperatureHighLabel.clipsToBounds = YES;
    self.temperatureHighLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.temperatureHighLabel];
    
    self.temperatureLowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.temperatureLowLabel.backgroundColor = [UIColor whiteColor];
    self.temperatureLowLabel.alpha = 0.85;
    self.temperatureLowLabel.layer.cornerRadius = 10.0;
    self.temperatureLowLabel.textAlignment = NSTextAlignmentCenter;
    self.temperatureLowLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40];
    self.temperatureLowLabel.clipsToBounds = YES;
    self.temperatureLowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.temperatureLowLabel];
}

-(void)setUpAutoLayoutConstraints {
    id temperatureHighLabel = self.temperatureHighLabel;
    id temperatureLowLabel = self.temperatureLowLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(temperatureHighLabel, temperatureLowLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[temperatureHighLabel(==75)]-20-[temperatureLowLabel(==55)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[temperatureHighLabel(==290)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[temperatureLowLabel(==235)]" options:0 metrics:nil views:views]];
}

#pragma mark -Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
