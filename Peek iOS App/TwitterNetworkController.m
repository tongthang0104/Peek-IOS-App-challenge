//
//  TwitterNetworkController.m
//  Peek iOS App
//
//  Created by Thang H Tong on 3/10/16.
//  Copyright © 2016 ThangTong. All rights reserved.
//

#import "TwitterNetworkController.h"

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

-(void)retweet:(NSDictionary *)tweetDict successBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    
    if (!self.account) {
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                if(!self.account && !self.userAPI) {
                    NSArray *multipleAccounts = [accountStore accountsWithAccountType:accountType];
                    if (multipleAccounts.count > 0) {
                        self.account = [multipleAccounts objectAtIndex:0];
                        self.userAPI = [STTwitterAPI twitterAPIOSWithAccount:self.account delegate:nil];
                    } else {
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Retweet was unsuccessful.", nil)};
                        NSError *error = [NSError errorWithDomain:ACErrorDomain
                                                             code:99
                                                         userInfo:userInfo];
                        errorBlock(error);
                    }
                }

                [self.userAPI postStatusRetweetWithID:tweetDict[@"id_str"] trimUser:[NSNumber numberWithBool:YES] successBlock:successBlock errorBlock:errorBlock];
            } else {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Twitter access not granted.", nil)};
                NSError *error = [NSError errorWithDomain:ACErrorDomain
                                                     code:98
                                                 userInfo:userInfo];
                errorBlock(error);
            }
        }];
    } else {
        [self retweet:tweetDict successBlock:successBlock errorBlock:errorBlock];
    }
}
@end
