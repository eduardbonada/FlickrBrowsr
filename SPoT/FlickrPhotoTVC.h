//
//  FlickrPhotoTVC.h
//  MyShutterbug
//
//  Created by Eduard on 2/26/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//
// Will call setImageURL as part of any "Show Image" segue

#import <UIKit/UIKit.h>

@interface FlickrPhotoTVC : UITableViewController

@property (nonatomic, strong) NSArray *photos; // of NSDictionary

@end
