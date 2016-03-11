//
//  TwitterNetworkController.h
//  Peek iOS App
//
//  Created by Thang H Tong on 3/10/16.
//  Copyright © 2016 ThangTong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STTwitter/STTwitter.h>


@interface TwitterNetworkController : NSObject


@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *apiSecret;




+(instancetype)callTwitterWithConsumerKey: (NSString *)consumerKey
                           consumerSecret: (NSString *)consumerScecret
                               completion: (void (^)(NSString *username, NSString *userID))completion
                                    error:(void (^) (NSError *error))error;

//-(void)searchTweets: (NSString *)keyword completion: (void(^)(NSDictionary *searchMetadata, NSArray *data))completion error: (void(^)(NSError *error))errorBlock;

- (void)searchTweets:(NSString *)query
               maxID:(NSString *)maxID
        successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock;

@end
