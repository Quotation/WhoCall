//
//  WCSettingViewController.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/17/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

@import AddressBook;
#import "WCSettingViewController.h"
#import "WCCallInspector.h"
#import "WCAddressBook.h"
#import "UIAlertView+MKBlockAdditions.h"

@interface WCSettingViewController ()

@end

@implementation WCSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WCCallInspector *inspector = [WCCallInspector sharedInspector];
    self.switchLiar.on = inspector.handleLiarPhone;
    self.switchLocation.on = inspector.handlePhoneLocation;
    self.switchContact.on = inspector.handleContactName;
}

- (void)viewDidAppear:(BOOL)animated {
    // 触发弹出通讯录授权，第一次启动app后就弹出，避免在第一次来电的时候才弹
    [WCAddressBook defaultAddressBook];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)onSettingValueChanged:(UISwitch *)sender
{
    WCCallInspector *inspector = [WCCallInspector sharedInspector];
    if (sender == self.switchLiar) {
        inspector.handleLiarPhone = sender.on;
    } else if (sender == self.switchLocation) {
        inspector.handlePhoneLocation = sender.on;
    } else if (sender == self.switchContact) {
        inspector.handleContactName = sender.on;
        if (sender.on) {
            // 根据通讯录的访问权限，有不同的处理
            switch (ABAddressBookGetAuthorizationStatus()) {
                case kABAuthorizationStatusNotDetermined:
                {
                    ABAddressBookRef addrBook = ABAddressBookCreateWithOptions(nil, NULL);
                    ABAddressBookRequestAccessWithCompletion(addrBook, ^(bool granted, CFErrorRef error){
                        if (!granted) {
                            sender.on = NO;
                            inspector.handleContactName = NO;
                            [inspector saveSettings];
                        }
                        CFRelease(addrBook);
                    });
                    break;
                }
                case kABAuthorizationStatusDenied:
                {
                    sender.on = NO;
                    [UIAlertView alertViewWithTitle:nil
                                            message:NSLocalizedString(@"SETTING_CONTACT_NO_ACCESS", nil)
                                  cancelButtonTitle:NSLocalizedString(@"I_KNOW", nil)];
                    break;
                }
                default:
                    break;
            }
        }
    }
    [inspector saveSettings];
}

@end
