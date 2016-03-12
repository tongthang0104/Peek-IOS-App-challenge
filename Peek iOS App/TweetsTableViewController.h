//
//  TweetsTableViewController.h
//  Peek iOS App
//
//  Created by Thang H Tong on 3/8/16.
//  Copyright © 2016 ThangTong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterNetworkController.h"

@interface TweetsTableViewController : UITableViewController

@property (strong, nonatomic) TwitterNetworkController *twitterAPI;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (strong, nonatomic) NSString *maxID;
@property (strong, nonatomic) STTwitterAPI *twitter;

@end
