//
//  LocationService.h
//  ContainerScan
//
//  Created by OKAR OU on 16/8/25.
//  Copyright © 2016年 VICKY ZHOU (EUCD-EUC-ISD-OOCLL/ZHA). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationService : NSObject<CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,assign) BOOL isLocationUnableAlert;
@property (nonatomic,assign) BOOL deferringUpdates;

@property (nonatomic,strong) NSDate *lastUpdateTime;

+ (LocationService *)shareInstance;
- (void)handleForeground;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
