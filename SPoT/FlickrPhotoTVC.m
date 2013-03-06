//
//  FlickrPhotoTVC.m
//  MyShutterbug
//
//  Created by Eduard on 2/26/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "RecentPhotosStorage.h"

@interface FlickrPhotoTVC() <UISplitViewControllerDelegate>

@end

@implementation FlickrPhotoTVC


#pragma mark - photos management (model)

- (void) setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData]; //if the model changes (photos), we need to reload the view
}


#pragma mark - UISplitViewControllerDelegate

- (void) awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL) splitViewController:(UISplitViewController *)svc
    shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)orientation
{
    //return NO; // never hide the master VC
    return UIInterfaceOrientationIsPortrait(orientation);     // hide master VC in portrait orientation / show it in landscape orientation
}


#pragma mark - Split view delegate methods

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



# pragma mark - Split view: transfer button

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


#pragma mark - segues
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath){
            if([segue.identifier isEqualToString:@"Show Image"]){
                // this is done with "respondsToSelector" and "performSelector" - check CardViewer project for direct messaging
                if([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]){
                    [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
                    NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                    
                    [RecentPhotosStorage addPhoto:self.photos[indexPath.row]];
                }
            }
        }
    }
}


#pragma mark - Table view data source

- (NSString *) titleForRow:(NSUInteger) row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description];
}

- (NSString *) subtitleForRow:(NSUInteger) row
{
    return [self.photos[row][FLICKR_PHOTO_OWNER] description];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

@end
