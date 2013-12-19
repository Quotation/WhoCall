//
//  WCHangupViewController.h
//  WhoCall
//
//  Created by Wang Xiaolei on 12/19/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCHangupViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *switchAds;
@property (weak, nonatomic) IBOutlet UISwitch *switchCheat;
@property (weak, nonatomic) IBOutlet UILabel *labelDisableTip;

- (IBAction)onSettingValueChanged:(UISwitch *)sender;

@end
