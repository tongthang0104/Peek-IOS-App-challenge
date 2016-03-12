//
//  TwitterNetworkController.h
//  Peek iOS App
//
//  Created by Thang H Tong on 3/10/16.
//  Copyright © 2016 ThangTong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STTwitter/STTwitter.h>
#import <Accounts/Accounts.h>


@interface TwitterNetworkController : NSObject

@property (nonatomic,strong) ACAccount *account;
@property (strong, nonatomic) STTwitterAPI *twitterAPI;
@property (strong, nonatomic) STTwitterAPI *userAPI;

+(instancetype)callTwitterWithConsumerKey: (NSString *)consumerKey
                           consumerSecret: (NSString *)consumerScecret
                               completion: (void (^)(NSString *username, NSString *userID))completion
                                    error:(void (^) (NSError *error))error;

- (void)searchTweets:(NSString *)query
               maxID:(NSString *)maxID
        successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock;

- (void)retweet:(NSDictionary *)tweetDict successBlock:(void(^)(NSDictionary *status))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

@end
