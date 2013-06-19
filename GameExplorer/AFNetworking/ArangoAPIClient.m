// AFAppDotNetAPIClient.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ArangoAPIClient.h"

#import "AFJSONRequestOperation.h"

static NSString * const kAFAppDotNetAPIBaseURLString = @"http://localhost:8529/";


#pragma mark - ArangoAPIClient

@implementation ArangoAPIClient

+ (ArangoAPIClient *)sharedClient {
    static ArangoAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ArangoAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppDotNetAPIBaseURLString]];
    });
    
    return _sharedClient;
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    self.parameterEncoding = AFJSONParameterEncoding;
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}


@end


#pragma mark - GXGame (ArangoDB)

@implementation GXGame (ArangoDB)

+ (void)getGame:(void (^)(GXGame* game))success failure:(void (^)(NSError* error))failure {
    [[ArangoAPIClient sharedClient] postPath:@"_api/cursor" parameters:@{@"query": @"for game in Games return game"} success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Games Result: %@", JSON);
        NSArray* games = JSON[@"result"];
        NSDictionary* currentGame = [games lastObject];
        GXGame* game = [[GXGame alloc] initWithGameId:currentGame[@"_key"]];
        game.name = currentGame[@"name"];
        success(game);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end


#pragma mark - GXPlayer (ArangoDB)

@implementation GXPlayer (ArangoDB)

- (void)joinGame:(GXGame*)game success:(void (^)(GXGame* game))success failure:(void (^)(NSError* error))failure {
    [[ArangoAPIClient sharedClient] postPath:@"_api/document?collection=GamePlayers" parameters:@{@"game": game.gid, @"_key": self.pid, @"name": self.name} success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Join Game Result: %@", JSON);
        if (success != nil) {
            success(game);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString* arangoError = error.userInfo[NSLocalizedRecoverySuggestionErrorKey];
        if ([arangoError rangeOfString:@"\"code\":409"].location != NSNotFound) {
            // The user already exists, update instead
            [self updateNameAndVoice:success failure:failure];
        }
        else {
            if (failure != nil) {
                failure(error);
            }
        }
    }];
}


- (void)updateNameAndVoice:(void (^)())success failure:(void (^)(NSError* error))failure {
    //[[ArangoAPIClient sharedClient] putPath:[self arangodbPath] parameters:@{@"name": self.name, @"uservoice": [NSData dataWithContentsOfURL:self.userVoice]} success:^(AFHTTPRequestOperation *operation, id JSON) {
    [[ArangoAPIClient sharedClient] putPath:[self arangodbPath] parameters:@{@"name": self.name} success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Update Position Result: %@", JSON);
        if (success != nil) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure != nil) {
            failure(error);
        }
    }];
}


- (void)updatePosition:(void (^)())success failure:(void (^)(NSError* error))failure {
    [[ArangoAPIClient sharedClient] putPath:[self arangodbPath] parameters:@{@"latitude": @(self.latitude), @"longitude": @(self.longitude)} success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Update Position Result: %@", JSON);
        if (success != nil) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure != nil) {
            failure(error);
        }
    }];
}


- (void)readPosition:(void (^)())success failure:(void (^)(NSError* error))failure {
    [[ArangoAPIClient sharedClient] putPath:[self arangodbPath] parameters:@{@"latitude": @(self.latitude), @"longitude": @(self.longitude)} success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Update Position Result: %@", JSON);
        if (success != nil) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure != nil) {
            failure(error);
        }
    }];
}


- (NSString*)arangodbPath {
    return [NSString stringWithFormat:@"_api/document/GamePlayers/%@", self.pid];
}

@end


