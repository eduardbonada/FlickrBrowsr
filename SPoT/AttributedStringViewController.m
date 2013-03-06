//
//  AttributedStringViewController.m
//  SPoT
//
//  Created by Eduard on 3/5/13.
//  Copyright (c) 2013 ebc. All rights reserved.
//

#import "AttributedStringViewController.h"

@interface AttributedStringViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AttributedStringViewController

-(void)setText:(NSAttributedString *)text
{
    _text = text;
    self.textView.attributedText = text;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.attributedText = self.text;
}

@end
