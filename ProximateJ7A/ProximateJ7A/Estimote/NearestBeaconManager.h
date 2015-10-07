//
//  NearestBeaconManager.h
//  ProximateJ7A
//

#import <Foundation/Foundation.h>

#import "BeaconID.h"

@class NearestBeaconManager;

@protocol NearestBeaconManagerDelegate <NSObject>

- (void)nearestBeaconManager:(NearestBeaconManager *)nearestBeaconManager didUpdateNearestBeaconID:(BeaconID *)beaconID;

@end

@interface NearestBeaconManager : NSObject

@property (weak, nonatomic) id<NearestBeaconManagerDelegate> delegate;

- (instancetype)initWithBeaconRegions:(NSArray *)beaconRegions NS_DESIGNATED_INITIALIZER;

- (void)startNearestBeaconUpdates;
- (void)stopNearestBeaconUpdates;

@end
