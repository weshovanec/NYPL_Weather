//
//  WeatherDataManager.m
//  NYPL_Weather
//
//  Created by Wesley Hovanec on 12/21/15.
//  Copyright © 2015 Wesley Hovanec. All rights reserved.
//

#import "WeatherDataManager.h"

#import "WeatherDate.h"

@interface WeatherDataManager ()

@end



@implementation WeatherDataManager

#pragma mark -Singleton

+(WeatherDataManager *)sharedWeatherDataManager {
    static WeatherDataManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WeatherDataManager alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init {
    if (self = [super init]) {
        self.weatherDates = [[NSArray alloc] initWithObjects:[[WeatherDate alloc] init], nil];
    }
    return self;
}

#pragma mark -Weather Updates

-(void)updateWeatherDates {
    NSURL *url = [NSURL URLWithString:@"http://gwen.nyc/nypl/forecast.json"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [urlSession downloadTaskWithURL:url];
    [downloadTask resume];
}

#pragma mark -NSURLSession Delegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSError *jsonError = nil;
    NSDictionary *weatherDataDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:0 error:&jsonError];
    if (!jsonError) {
        [self parseWeatherDataDictionary:weatherDataDictionary];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:self userInfo:@{@"error" : jsonError.localizedDescription}];
    }
}
-(void)parseWeatherDataDictionary:(NSDictionary *)weatherDataDictionary {
    NSMutableArray *weatherDates = [[NSMutableArray alloc] init];
    for (NSDictionary *time in [weatherDataDictionary valueForKey:@"list"]) {
        
        NSString *date = [[[time valueForKey:@"dt_txt"] componentsSeparatedByString:@" "] firstObject];
        float temperatureHigh = [[time valueForKeyPath:@"main.temp_max"] floatValue];
        float temperatureLow = [[time valueForKeyPath:@"main.temp_min"] floatValue];
        
        WeatherDate *latestWeatherDate = [weatherDates lastObject];
        
        if ([date isEqualToString:latestWeatherDate.date]) {
            if (latestWeatherDate.temperatureHigh < temperatureHigh) {
                latestWeatherDate.temperatureHigh = temperatureHigh;
            }
            if (latestWeatherDate.temperatureLow > temperatureLow) {
                latestWeatherDate.temperatureLow = temperatureLow;
            }
        }
        else {
            WeatherDate *newDate = [[WeatherDate alloc] init];
            newDate.date = date;
            newDate.temperatureHigh = temperatureHigh;
            newDate.temperatureLow = temperatureLow;
            [weatherDates addObject:newDate];
        }
    }
    self.weatherDates = [weatherDates copy];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:self userInfo:@{@"error" : error.localizedDescription}];
    }
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:self userInfo:@{@"error" : error.localizedDescription}];
    }}

@end
