//
//  FlickrTagTVC.h
//  SPoT
//
//  Created by Eduard on 3/1/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrTagTVC : UITableViewController

@property (nonatomic, strong) NSArray *photos; // of NSDictionary

@property (nonatomic, strong) NSArray *tagsToIgnore;

@end
