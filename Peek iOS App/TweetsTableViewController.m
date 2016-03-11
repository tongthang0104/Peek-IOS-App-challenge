//
//  TweetsTableViewController.m
//  Peek iOS App

//  Created by Thang H Tong on 3/8/16.
//  Copyright © 2016 ThangTong. All rights reserved.

// Thanks to :"http://www.appcoda.com/pull-to-refresh-uitableview-empty/" for refreshControl Attribute


#import "TweetsTableViewController.h"
#import "TwitterNetworkController.h"
#import <STTwitter/STTwitter.h>


@interface TweetsTableViewController ()

@property (strong, nonatomic) TwitterNetworkController *twitterAPI;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (strong, nonatomic) NSString *maxID;
@property (strong, nonatomic) STTwitterAPI *twitter;

@end

@implementation TweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Peek Querry";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retweet" style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor brownColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    
    
    self.twitterAPI = [TwitterNetworkController callTwitterWithConsumerKey:@"8kevXkS506035LW7HthIUn4ms" consumerSecret:@"IPLudUKghCkYgvkcFQS1xPrfYgTLGn66R60sAn0Fu85gpkBBSF" completion:^(NSString *username, NSString *userID) {
        
        NSLog(@"succeed login to Twitter");
        [self searchTwitterWithQuery];
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        [self alertControllerWithTitle:error.localizedDescription message: @"Try again"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Support Functions

-(void)reloadData {
    [self.tableView reloadData];
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.tweetsArray removeAllObjects];
        [self.tableView reloadData];
        [self searchTwitterWithQuery];
        [self.refreshControl endRefreshing];
    }
}

-(void)searchTwitterWithQuery {
    [self.twitterAPI searchTweets:@"@Peek" maxID:self.maxID successBlock:^(NSDictionary *searchMetadata, NSArray *data) {
        NSString *nextResultsParamsStr = searchMetadata[@"next_results"];
        NSDictionary *nextResultsParams = [self queryDictionary:nextResultsParamsStr];
        
        NSLog(@"%@", searchMetadata);
        self.maxID = nextResultsParams[@"max_id"];
        
        self.tweetsArray = [NSMutableArray new];
        
        [self.tweetsArray addObjectsFromArray:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (NSDictionary *)queryDictionary:(NSString *)paramStr {
    //remove leading param separator, if it exists
    paramStr = [paramStr stringByReplacingOccurrencesOfString:@"?" withString:@""];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [paramStr componentsSeparatedByString:@"&"]) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        if([parts count] < 2) continue;
        [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    return params;
}

-(void)alertControllerWithTitle: (NSString *)title message: (NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"tweetCell" forIndexPath:indexPath];
    
    //separator line
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:separatorLineView];
    
    //hightlight 
    UIView *highlightColorView = [[UIView alloc] init];
    highlightColorView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = highlightColorView;
    
    NSDictionary *tweetDictionary = self.tweetsArray[indexPath.row];
    NSString *tweetText = [tweetDictionary objectForKey:@"text"];
    NSDictionary *userDict = [tweetDictionary objectForKey:@"user"];
    NSString *username = [userDict objectForKey:@"name"];
    NSString *profileImage = [userDict objectForKey:@"profile_image_url"];
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.textLabel.text = tweetText;
    cell.detailTextLabel.text = [NSString stringWithFormat:@" by %@", username];
    NSURL *url = [NSURL URLWithString: profileImage];
    NSData *data = [NSData dataWithContentsOfURL:url];
    cell.imageView.image = [[UIImage alloc] initWithData:data];
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *secondColor;
    if (indexPath.row % 2 == 0) {
        secondColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    } else {
        secondColor = [UIColor whiteColor];
    }
    UIColor *currentColor = cell.backgroundColor;
    if (![secondColor isEqual:currentColor]) {
        cell.backgroundColor = secondColor;
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.estimatedRowHeight = 80;
    return tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.tweetsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
