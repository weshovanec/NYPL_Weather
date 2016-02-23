//
//  WeatherDate.h
//  NYPL_Weather
//
//  Created by Wesley Hovanec on 12/21/15.
//  Copyright © 2015 Wesley Hovanec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherDate : NSObject

@property (nonatomic, strong)NSString *date;
@property (nonatomic)float temperatureHigh;
@property (nonatomic)float temperatureLow;

@end
