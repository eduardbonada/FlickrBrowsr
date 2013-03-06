//
//  ScrollingImageViewController.m
//  MyShutterbug
//
//  Created by Eduard on 2/26/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "ScrollingImageViewController.h"
#import "AttributedStringViewController.h"
#import "UIApplication+NetworkActivity.h"

@interface ScrollingImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@property (nonatomic, getter = isAutoZoomed) BOOL autoZoomed;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem; // only used for iPad UI

@property (nonatomic, strong) UIPopoverController *urlPopover;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ScrollingImageViewController


#pragma mark - image control

- (UIImageView *) imageView
{
    if(!_imageView) _imageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    return _imageView;
}

-(void) setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void) resetImage
{
    if(self.scrollView){
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        self.autoZoomed = YES;

        // dispatch the image fetching into another thread
        [self.spinner startAnimating];
        NSURL *imageURL = self.imageURL;
        dispatch_queue_t imageFecthQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFecthQ, ^{
            // get the image from the url
            [[UIApplication sharedApplication] showNetworkActivityIndicator];
            [NSThread sleepForTimeInterval:1.0]; //artificially create a 2 second delay
            NSData *imageDataInURL = [[NSData alloc] initWithContentsOfURL:self.imageURL];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            UIImage *imageInURL = [[UIImage alloc] initWithData:imageDataInURL];
            
            // we check if the current image is the image we wanted before connecting to the network to check for the case where the user just cancelled the image and selected another one
            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(imageInURL){  
                        // set the views according to new image data
                        self.scrollView.contentSize = imageInURL.size;
                        self.imageView.image = imageInURL;
                        self.imageView.frame = CGRectMake(0, 0, imageInURL.size.width, imageInURL.size.height);
                        
                        [self zoomScaleToFit];
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

#pragma mark - managing the autozoom

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.autoZoomed = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self zoomScaleToFit];
}

- (void)zoomScaleToFit
{
    // Calculate zoom scale to fit the image in the screen without blank spaces
    // if is AutoZoomed then set the zoomScale property only if the geometry is completely loaded
    if ((self.isAutoZoomed)&&(self.imageView.bounds.size.width)&&(self.scrollView.bounds.size.width)) {
        CGFloat widthRatio  = self.scrollView.bounds.size.width  / self.imageView.bounds.size.width;
        CGFloat heightRatio = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
        self.scrollView.zoomScale = (widthRatio > heightRatio) ? widthRatio : heightRatio;
    }
}


#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.imageView]; // add image to scrollview
    
    // zooming configuration
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;

    self.titleBarButtonItem.title = self.title;
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem]; // necessary to set the button in the toolbar

    [self resetImage];
}

#pragma mark - popover segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show URL"]){
        if([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]){
            AttributedStringViewController *asc = segue.destinationViewController;
            
            NSMutableString *stringUrl = [[NSMutableString alloc] initWithString:@"URL: "];
            [stringUrl appendString:[self.imageURL description]];

            NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:stringUrl];

            if(([stringUrl rangeOfString:@"http"]).location!=NSNotFound) [mas addAttributes: @{NSForegroundColorAttributeName : [UIColor purpleColor]} range:[stringUrl rangeOfString:@"http"]];
            if(([stringUrl rangeOfString:@"http"]).location!=NSNotFound) [mas addAttributes: @{NSForegroundColorAttributeName : [UIColor redColor]} range:[stringUrl rangeOfString:@"flickr"]];
            if(([stringUrl rangeOfString:@"http"]).location!=NSNotFound) [mas addAttributes: @{NSForegroundColorAttributeName : [UIColor greenColor]} range:[stringUrl rangeOfString:@"jpg"]];
            asc.text = [mas copy];
            
            if([segue isKindOfClass:[UIStoryboardPopoverSegue class]]){
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            }
        }
    }
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"Show URL"]){
        return (self.imageURL && !self.urlPopover.popoverVisible) ? YES : NO; // return YES if URL is not nil and popover is not visible
    }
    else{
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}


#pragma mark - ipad toolbar

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

// Puts the splitViewBarButton in our toolbar (and/or removes the old one). Must be called when our splitViewBarButtonItem property changes (and also after our view has been loaded from the storyboard (viewDidLoad)).
- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem)
        [toolbarItems removeObject:_splitViewBarButtonItem]; // if the barbutton is present remove it
    if (barButtonItem)
        [toolbarItems insertObject:barButtonItem atIndex:0]; // put the barbutton on the left of our existing toolbar
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = barButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (barButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:barButtonItem];
    }
}


- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
