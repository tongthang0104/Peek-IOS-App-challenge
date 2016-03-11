//
//  TwitterNetworkController.m
//  Peek iOS App
//
//  Created by Thang H Tong on 3/10/16.
//  Copyright © 2016 ThangTong. All rights reserved.
//

#import "TwitterNetworkController.h"


@interface TwitterNetworkController ()
@property (strong, nonatomic) STTwitterAPI *twitterAPI;


@end
@implementation TwitterNetworkController

+(instancetype)callTwitterWithConsumerKey:(NSString *)consumerKey
                           consumerSecret:(NSString *)consumerScecret
                               completion:(void (^)(NSString *username, NSString *userId))completion
                                    error:(void (^)(NSError *))error {
    
    TwitterNetworkController *twitterAPI = [[TwitterNetworkController alloc] init];
    twitterAPI.twitterAPI = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:consumerKey consumerSecret:consumerScecret];
    
    [twitterAPI.twitterAPI verifyCredentialsWithUserSuccessBlock:completion errorBlock:error];
    return twitterAPI;
}


- (void)searchTweets:(NSString *)query
               maxID:(NSString *)maxID
        successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
          errorBlock:(void(^)(NSError *error))errorBlock {
    [self.twitterAPI getSearchTweetsWithQuery:query
                                         geocode:nil
                                            lang:nil
                                          locale:nil
                                      resultType:@"recent"
                                           count:@"30"
                                           until:nil
                                         sinceID:nil
                                           maxID:maxID
                                 includeEntities:@(YES)
                                        callback:nil
                                    successBlock:successBlock
                                      errorBlock:errorBlock];
}
@end
