//
//  WeatherInfoVC.h
//  NYPL_Weather
//
//  Created by Wesley Hovanec on 12/21/15.
//  Copyright © 2015 Wesley Hovanec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeatherDate;

@interface WeatherInfoVC : UIViewController

@property (nonatomic, strong)WeatherDate *currentWeatherDate;
@property (nonatomic, assign)NSInteger index;

@end
