//
//  WindSpeedClient.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 12/5/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

/*
 
 Uses this api:  http://openweathermap.org/api
 
 */

#import "WindSpeedClient.h"
#import "CloudClient2.h"
#import "NSDictionary+JSON.h"
#import "NSDate+Utilities.h"
#import <CoreLocation/CoreLocation.h>

#define kMaxWindAgeMinutes 5

@interface WindSpeedClient () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSDate* windLastUpdatedTimestamp;
@property (nonatomic) float lastWindSpeedMph;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WindSpeedClient
@synthesize lastWindSpeedMph = _lastWindSpeedMph;

+ (WindSpeedClient*)shared {
    
    static WindSpeedClient *shared;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        shared = [[self alloc] init];
    });
    return shared;
}

-(void)updateWindSpeed {
    @synchronized (self) {
        if (![self hasWindSpeedBeenUpdatedRecently]) {
            [self startLocationLookup];
        } else {
            [self notifyDelegate];
        }
    }
}

-(BOOL)hasWindSpeedBeenUpdatedRecently {
    @synchronized (self) {
        return [self.windLastUpdatedTimestamp isLaterThanDate:[NSDate dateWithMinutesBeforeNow: kMaxWindAgeMinutes]]; {
        }
    }
}

-(void)startLocationLookup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)retrieveWindSpeedForLatitude: (float)latitude longitude: (float)longitude {
    @synchronized (self) {
        [self getWindSpeedForLatitude:latitude longitude:longitude completion:^(BOOL ok, NSData *responseData) {
            if (ok) {
                float speed = [self windSpeedMphFromResponse: responseData];
                if (speed > -1) {
                    self.lastWindSpeedMph = speed;
                    self.locationManager = nil;
                }
            }
            [self notifyDelegate];
        }];
    }
}

-(void)notifyDelegate {
    @synchronized (self) {
        if (self.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate windSpeedUpdateAttempted];
            });
        }
    }
}

-(void) getWindSpeedForLatitude: (float)latitude longitude: (float) longitude completion:  (void (^)(BOOL ok, NSData* responseData)) completion {
    NSAssert(completion, @"completion block required");
    if ([CloudClient2 isConnected]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f", latitude, longitude]];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData]; // cache buster
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *sendError) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            if (sendError == nil && response != nil && [httpResponse statusCode] == 200) {
                // NSLog(@"http GET for wind successful.  URL is %@", request.URL.absoluteString);
                completion(YES, data);
            } else {
                NSString* httpStatus = response == nil ? @"Unknown" :  [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode];
                SHSLog(@"Failed http GET request. Server returned HTTP status code %@. More Info = %@.  URL is %@", httpStatus, sendError, request.URL.absoluteString);
                completion(NO, nil);
            }
        }] resume];
    } else {
        SHSLog(@"http GET for wind speed not attempted: device is not connected to net");
        completion(NO,  nil);
    }
}

// answer -1 if error or speed not found in response
-(float)windSpeedMphFromResponse: (NSData*)responseData {
    NSError* unmarshallingError = nil;
    if (responseData) {
        NSDictionary* responseJsonAsDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&unmarshallingError];
        if (unmarshallingError) {
            SHSLog(@"wind service returned invalid json");
            return -1;
        } else {
            NSDictionary* windDict = [responseJsonAsDict objectForJsonProperty:@"wind"];
            if (windDict) {
                NSNumber* speed = [windDict objectForJsonProperty:@"speed"];
                if (speed && [speed isKindOfClass:[NSNumber class]]) {
                    return speed.floatValue;
                }
            }
            SHSLog(@"wind service did not return a wind speed");
            return -1;
        }
    } else {
        SHSLog(@"wind service did not return a response");
        return -1;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager (for wind speed determination) failed: %@", error);
    @synchronized (self) {
        self.locationManager = nil;
        [self notifyDelegate];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation) {
        @synchronized (self) {
            self.locationManager = nil;
        }
        [self retrieveWindSpeedForLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    }
}

#pragma mark - Custom accessors

-(void)setLastWindSpeedMph:(float)lastWindSpeedMph {
    @synchronized (self) {
        _lastWindSpeedMph = lastWindSpeedMph;
        _windLastUpdatedTimestamp = [NSDate date];
    }
}

-(float)lastWindSpeedMph {
    @synchronized (self) {
        return _lastWindSpeedMph;
    }
}

/* Sample JSON response

{
    "coord":{
        "lon":139,
        "lat":35
    },
    "sys":{
        "type":3,
        "id":7616,
        "message":0.0215,
        "country":"JP",
        "sunrise":1417815472,
        "sunset":1417851133
    },
    "weather":[
               {
                   "id":801,
                   "main":"Clouds",
                   "description":"few clouds",
                   "icon":"02d"
               }
               ],
    "base":"cmc stations",
    "main":{
        "temp":279.06,
        "pressure":1008,
        "humidity":52,
        "temp_min":277.15,
        "temp_max":281.15
    },
    "wind":{
        "speed":5.7,
        "deg":240,
        "var_beg":200,
        "var_end":280,
        "gust":10.8
    },
    "clouds":{  
        "all":20
    },
    "dt":1417824000,
    "id":1851632,
    "name":"Shuzenji",
    "cod":200
}
 
*/

@end
