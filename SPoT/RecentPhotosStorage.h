//
//  RecentPhotosStorage.h
//  SPoT
//
//  Created by Eduard on 3/4/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotosStorage : NSObject

+ (NSArray *)allPhotos; // retrieves all photos from the storage
+ (void)addPhoto:(NSDictionary *)photo; // adds a photo to the storage

@end
