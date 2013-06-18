//
//  GNFlipsideViewController.h
//  GameExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GNFlipsideViewController;

@protocol GNFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(GNFlipsideViewController *)controller;
@end

@interface GNFlipsideViewController : UIViewController

@property (weak, nonatomic) id <GNFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
