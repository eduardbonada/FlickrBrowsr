//
//  RecentPhotosStorage.m
//  SPoT
//
//  Created by Eduard on 3/4/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "RecentPhotosStorage.h"

#define ALL_PHOTOS_KEY @"RecentPhotosStorage"
#define MAXIMUM_CAPACITY 10

@implementation RecentPhotosStorage

+ (NSArray *)allPhotos
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ALL_PHOTOS_KEY];
}

+ (void)addPhoto:(NSDictionary *)photo
{
    NSMutableArray *photos = [[[self class] allPhotos] mutableCopy];
    if (!photos) {
        photos = [[NSMutableArray alloc] init]; // create persistent store for first time
    } else {
        if ([photos indexOfObject:photo]==NSNotFound) {
            if ([photos count]==MAXIMUM_CAPACITY) {
                // the photo was never stored before, we remove last photo so as not to exceed maximum capacity
                [photos removeLastObject];
            }
        } else {
            // the photo was stored before, so we remove it from the previous position
            [photos removeObject:photo];
        }
    }

    [photos insertObject:photo atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:photos forKey:ALL_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
