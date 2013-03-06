//
//  StanfordFlickrTagTVC.m
//  SPoT
//
//  Created by Eduard on 3/4/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "StanfordFlickrTagTVC.h"
#import "FlickrFetcher.h"
#import "UIApplication+NetworkActivity.h"

@interface StanfordFlickrTagTVC ()

@end

@implementation StanfordFlickrTagTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tagsToIgnore = @[@"cs193pspot", @"portrait", @"landscape"];
    
    //self.photos = [FlickrFetcher stanfordPhotos];
    
    [self loadPhotosFromFlicker];
    [self.refreshControl addTarget:self action:@selector(loadPhotosFromFlicker) forControlEvents:UIControlEventValueChanged];
}

- (void) loadPhotosFromFlicker
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loaderQ = dispatch_queue_create("flicker loader", NULL);
    dispatch_async(loaderQ, ^{
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
        NSArray *stanfordPhotos = [FlickrFetcher stanfordPhotos];
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = stanfordPhotos;
            [self.refreshControl endRefreshing];
        });
    });
}

@end
