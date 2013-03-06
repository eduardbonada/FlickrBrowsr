//
//  FlickrTagTVC.m
//  SPoT
//
//  Created by Eduard on 3/1/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "FlickrTagTVC.h"
#import "FlickrFetcher.h"

@interface FlickrTagTVC () <UISplitViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *photosIndexedByTag; // key: 'NSString' tag - value: 'NSIndexSet' with the indexes of the photos that match that tag
@property (nonatomic, strong) NSArray *alphaSortedTags;         // of NSString, necessary to have the tags sorted only once

@end

@implementation FlickrTagTVC


#pragma mark - tags and photos management

- (void) setPhotos:(NSArray *)photos
{
    _photos = photos;

    self.photosIndexedByTag = [self computephotosIndexedByTag];
    self.alphaSortedTags = [self computeAlphaSortedTags];
    
    [self.tableView reloadData]; //if the model changes (photos), we need to reload the view
}

- (NSDictionary *)photosIndexedByTag
{
    if (!_photosIndexedByTag) {
        _photosIndexedByTag = [self computephotosIndexedByTag];
    }
    return _photosIndexedByTag;
}

-(NSDictionary *)computephotosIndexedByTag
{
    NSMutableDictionary *photosByTag = [[NSMutableDictionary alloc] init]; // of NSMutableIndexSet
    for (NSDictionary *photo in self.photos) {
        // get the tags from the photo
        NSMutableArray *tags = [NSMutableArray arrayWithArray:[photo[FLICKR_TAGS] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        [tags removeObjectsInArray:self.tagsToIgnore]; // remove unwanted tags
        
        NSUInteger index = [self.photos indexOfObject:photo]; // obtain index for current photo
        
        // for each tag, add index to set of indexes
        for (NSString *tag in tags) {
            if (photosByTag[tag])
                [(NSMutableIndexSet *)photosByTag[tag] addIndex:index]; // add the new index to the NSindexSet
            else
                photosByTag[tag]=[NSMutableIndexSet indexSetWithIndex:index]; // new tag found, create initial index
        }
    }

    return photosByTag;
}

- (NSArray *)alphaSortedTags
{
    if (!_alphaSortedTags) {
        // we get all tags from the dictionary and we return them ordered using NSString caseInsensitiveCompare: method
        _alphaSortedTags = [self computeAlphaSortedTags];
    }
    return _alphaSortedTags;
}

-(NSArray *)computeAlphaSortedTags
{
    return [[self.photosIndexedByTag allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)photosForTag:(NSString *)tag
{
    NSArray *photosForTag = [self.photos objectsAtIndexes:self.photosIndexedByTag[tag]];
    // before passing the array of photos to the next viewcontroller, we sort the photos by {key1,key2}
    NSSortDescriptor *firstKey = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES]; //key1
    NSSortDescriptor *secondKey = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_DESCRIPTION ascending:YES]; //key2
    return [photosForTag sortedArrayUsingDescriptors:@[firstKey,secondKey]]; //sorted by {key1,key2}
}


#pragma mark -  split view controller delegate

- (void) awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL) splitViewController:(UISplitViewController *)svc
    shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)orientation
{    
    // return NO; // never hide the master VC
    return UIInterfaceOrientationIsPortrait(orientation);     // hide master VC in portrait orientation / show it in landscape orientation
}


#pragma mark - Split view delegate methods
/*
- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    // Called when the view is about to disappear, activating the button
    barButtonItem.title = @"Photos";
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    if ([detailViewController respondsToSelector:@selector(setSplitViewBarButtonItem:)]){
        [detailViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:barButtonItem];
    }
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    if ([detailViewController respondsToSelector:@selector(setSplitViewBarButtonItem:)]){
        [detailViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
    }
}
*/


# pragma mark - Split view: transfer button
/*
- (id)splitViewDetailWithBarButtonItem
{
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    if (![detailViewController respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detailViewController respondsToSelector:@selector(splitViewBarButtonItem)]) detailViewController = nil;
    return detailViewController;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] performSelector:@selector(splitViewBarButtonItem)];
    [[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
    if (splitViewBarButtonItem)
        [destinationViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:splitViewBarButtonItem];
}
*/



#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos with Tag"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSString *tag = [[self titleForRow:indexPath.row] lowercaseString];
                    NSArray *photosToSegue = [self photosForTag:tag];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photosToSegue];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}


#pragma mark - Table view data source

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.alphaSortedTags[row] capitalizedString];
}

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [NSString stringWithFormat:@"%d photos",[self.photosIndexedByTag[[[self titleForRow:row] lowercaseString]] count]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.alphaSortedTags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

@end
