//
//  RecentSeenPhotosTVC.m
//  SPoT
//
//  Created by Eduard on 3/4/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "RecentSeenPhotosTVC.h"
#import "RecentPhotosStorage.h"

@interface RecentSeenPhotosTVC ()

@end

@implementation RecentSeenPhotosTVC

- (void)viewWillAppear:(BOOL)animated
{
    self.photos = [RecentPhotosStorage allPhotos]; // we reload the photos every time the view appears to get updated information
}

@end
