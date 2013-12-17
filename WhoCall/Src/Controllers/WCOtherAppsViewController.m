//
//  WCOtherAppsViewController.m
//  WhoCall
//
//  Created by Wang Xiaolei on 11/18/13.
//  Copyright (c) 2013 Wang Xiaolei. All rights reserved.
//

#import "WCOtherAppsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface WCOtherAppsViewController ()

@end

@implementation WCOtherAppsViewController

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
    
    self.iconNobody.layer.cornerRadius = 10;
    self.iconNobody.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.cellNobody) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id740362780"]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
