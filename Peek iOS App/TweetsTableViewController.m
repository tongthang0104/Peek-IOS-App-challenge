//
//  TweetsTableViewController.m
//  Peek iOS App

//  Created by Thang H Tong on 3/8/16.
//  Copyright © 2016 ThangTong. All rights reserved.

// Thanks to :"http://www.appcoda.com/pull-to-refresh-uitableview-empty/" for refreshControl Attribute


#import "TweetsTableViewController.h"
#import <UIScrollView+InfiniteScroll.h>
#import <STTwitter/STTwitter.h>

@implementation TweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self infiniteScrolling];
    self.navigationItem.title = @"Peek Querry";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retweet" style:UIBarButtonItemStylePlain target:self action: @selector(retweet:)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor brownColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    
    
    self.twitterAPI = [TwitterNetworkController callTwitterWithConsumerKey:@"8kevXkS506035LW7HthIUn4ms" consumerSecret:@"IPLudUKghCkYgvkcFQS1xPrfYgTLGn66R60sAn0Fu85gpkBBSF" completion:^(NSString *username, NSString *userID) {
        
        NSLog(@"succeed login to Twitter");
        [self searchTwitterWithQuery:YES completion:nil];
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

-(void) infiniteScrolling {
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        
        [self searchTwitterWithQuery: NO completion:^{
            [tableView finishInfiniteScroll];
        }];
     }];

}
-(void)reloadData {
    [self.tableView reloadData];
    if (self.refreshControl) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [dateFormatter stringFromDate:[NSDate date]]];
        NSDictionary *colorDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:colorDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.tweetsArray removeAllObjects];
        [self.tableView reloadData];
        [self searchTwitterWithQuery:YES completion:nil];
        [self.refreshControl endRefreshing];
    }
}

-(void)retweet:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *selectedTweet = [self.tweetsArray objectAtIndex:selectedIndexPath.row];
    [self.twitterAPI retweet:selectedTweet successBlock:^(NSDictionary *status) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self alertControllerWithTitle:@"Successfully retweeted" message:@"OK"];
        });
    } errorBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertControllerWithTitle:(error.localizedDescription) message:@"Try again"];
        });
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)searchTwitterWithQuery:(BOOL)firstQuery completion: (void(^)(void))completion {
    [self.twitterAPI searchTweets:@"@Peek" maxID:self.maxID successBlock:^(NSDictionary *searchMetadata, NSArray *data) {
        NSString *nextResult = searchMetadata[@"next_results"];
        NSDictionary *nextResultDict = [self queryDictionary:nextResult];
        
        NSLog(@"%@", searchMetadata);
        self.maxID = nextResultDict[@"max_id"];
        
        if (firstQuery == YES) {
            self.tweetsArray = [NSMutableArray new];
            [self.tweetsArray addObjectsFromArray:data];
        } else {
            [self.tweetsArray addObjectsFromArray:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } errorBlock:^(NSError *error) {
        [self alertControllerWithTitle:(error.localizedDescription) message:@"Try again"];
        NSLog(@"%@", error.localizedDescription);
    }];
}

// Thanks to https://www.codementor.io/tips/3847022513/creating-url-query-parameters-from-nsdictionary-objects-in-objectivec

- (NSDictionary *)queryDictionary:(NSString *)parameter {
    //remove leading param separator, if it exists
    parameter = [parameter stringByReplacingOccurrencesOfString:@"?" withString:@""];
    NSMutableDictionary *paraDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *parameterString in [parameter componentsSeparatedByString:@"&"]) {
        NSArray *parts = [parameterString componentsSeparatedByString:@"="];
        if([parts count] < 2) continue;
        [paraDictionary setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    return paraDictionary;
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *secondColor;
    if (indexPath.row % 2 == 0) {
        secondColor = [UIColor lightGrayColor];
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
