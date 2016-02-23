//
//  WeatherDataManager.h
//  NYPL_Weather
//
//  Created by Wesley Hovanec on 12/21/15.
//  Copyright © 2015 Wesley Hovanec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherDataManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

//Last index will contain the latest date.
@property (nonatomic, copy)NSArray *weatherDates;

+(WeatherDataManager *)sharedWeatherDataManager;
-(void)updateWeatherDates;

@end
