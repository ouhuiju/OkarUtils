//
//  LocationService.m
//  ContainerScan
//
//  Created by OKAR OU on 16/8/25.
//  Copyright © 2016年 VICKY ZHOU (EUCD-EUC-ISD-OOCLL/ZHA). All rights reserved.
//

#import "LocationService.h"

long const SEND_REPORT_TIME_INTERVAL = 5;

@implementation LocationService

+ (LocationService *)shareInstance {
    static LocationService *_singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletion = [[self alloc] init];
        [_singletion createLocationManager];
    });
    return _singletion;
}

-(void)createLocationManager{
    if (_locationManager) {
        return;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    if ([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)startUpdatingLocation {
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [_locationManager stopUpdatingLocation];
}

- (void)handleForeground {
    if(![self checkLocationServiceEnable]){
        [self showLocationUnableAlert];
    }
    [self createLocationManager];
    [self startUpdatingLocation];
}

-(BOOL) checkLocationServiceEnable{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            return NO;
        case kCLAuthorizationStatusRestricted:
            return NO;
        case kCLAuthorizationStatusNotDetermined:
            return NO;
        default:
            return YES;
    }
}

-(void)showLocationUnableAlert{
    _isLocationUnableAlert = YES;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Need GPS, pls click 'Open'."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertview show];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_isLocationUnableAlert) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        _isLocationUnableAlert = NO;
        return;
    }
    
    if (buttonIndex == 1) {
        
    }
}

#pragma mark - Location Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (!self.deferringUpdates) {
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:SEND_REPORT_TIME_INTERVAL];
        self.deferringUpdates = YES;
        
        if (!_lastUpdateTime) {
            _lastUpdateTime = [NSDate date];
            [self getAddressWithLocations:locations];
        }else{
            NSTimeInterval interval = fabs([_lastUpdateTime timeIntervalSinceNow]);
            if (interval >= SEND_REPORT_TIME_INTERVAL) {
                [self getAddressWithLocations:locations];
                _lastUpdateTime = [NSDate date];
            }
        }
    }else{
        //        NSLog(@"not bind phone yet");
    }
}

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    NSLog(@"didFinishDeferredUpdatesWithError is %@", error);
    self.deferringUpdates = NO;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"Loaction authorzation status change");
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            //            [_dbHelper saveExceptionLog:@"Location service change to disable"];
            break;
        case kCLAuthorizationStatusRestricted:
            //            [_dbHelper saveExceptionLog:@"Location service change to disable"];
            break;
        case kCLAuthorizationStatusNotDetermined:
            //            [_dbHelper saveExceptionLog:@"Location service change to disable"];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            //            [_dbHelper saveOperationLog:@"Location service change to enable"];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            //            [_dbHelper saveOperationLog:@"Location service change to enable"];
            break;
        default:
            break;
    }
}


-(void)getAddressWithLocations:(NSArray *) locations{
    if (locations.count>0) {
        CLLocation *location = locations[0];
        CLGeocoder *revGeo = [[CLGeocoder alloc] init];
        [revGeo reverseGeocodeLocation:location
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         if (!error && [placemarks count] > 0)
                         {
                             NSDictionary *dict =
                             [[placemarks objectAtIndex:0] addressDictionary];
                             NSArray *formattedLines = [dict objectForKey:@"FormattedAddressLines"];
                             NSString *formattedAddress = formattedLines[0];
                             
                             NSLog(@"dict is %@", dict);
                             
                             //                             Location *reportLocation = [[Location alloc] initWithCLLocation:location];
                             //                             reportLocation.address = formattedAddress;
                             //                             NSLog(@"address is %@",formattedAddress);
                             //                             MonitorReport *report = [self monitorReportWithLocation:reportLocation];
                             //                             [_dbHelper saveMonitorReport:report];
                         }else{
                             NSLog(@"ERROR: %@", error);
                         }
                     }];
    }
}

@end
