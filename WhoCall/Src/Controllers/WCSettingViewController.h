//
//  WCSettingViewController.h
//  WhoCall
//
//  Created by Wang Xiaolei on 11/17/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCSettingViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *switchLiar;
@property (weak, nonatomic) IBOutlet UISwitch *switchLocation;
@property (weak, nonatomic) IBOutlet UISwitch *switchContact;

- (IBAction)onSettingValueChanged:(UISwitch *)sender;

@end
