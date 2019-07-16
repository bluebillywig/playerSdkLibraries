//
//  BBComponent.m
//  BB Webview
//
//  Created by Floris Groenendijk on 01/07/14.
//  Copyright (c) 2014 Floris Groenendijk. All rights reserved.
//

#import "Version.h"
#import "BBComponent.h"
#import <AdSupport/ASIdentifierManager.h> // @import AdSupport;

#ifndef DEBUG
#undef NSLog
#endif

@implementation BBComponent{
    BOOL secure;
    BOOL debug;
}

const int backendVersion = 3;

- (NSString *)version{
    Version *version = [[Version alloc] init];
    return [version getVersion];
}

- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost{
    return [self initWithPublication:publication vhost:vhost secure:true];
}

- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost debug:(BOOL)_debug{
    return [self initWithPublication:publication vhost:vhost secure:true debug:_debug];
}

- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost secure:(BOOL)_secure{
    return [self initWithPublication:publication vhost:vhost secure:_secure debug:NO];
}
- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost secure:(BOOL)_secure debug:(BOOL)_debug{
    if (self = [super init]) {
        self.publication = publication;
        self.vhost = vhost;
        secure = _secure;
        debug = _debug;
        NSLog(@"Initialized BBComponent with publication: %@, vhost: %@, secure: %@ , debug: %@", publication, vhost, _secure ? @"Yes" : @"No", _debug ? @"Yes" : @"No");
    }
    return self;
}

/**
 Private function that will create the url for the player
 @param vhost Base url to load, eg. bbvms.com
 */
- (NSString *)createUri:(NSString *)vhost{
    return [self createUri:vhost component:nil showPersonalizedAds:true];
}

/**
 Private function that will create the url for the player
 @param vhost Base url to load, eg. bbvms.com
 @param component Name of the component to load
 */
- (NSString *)createUri:(NSString *)vhost component:(NSString *)component{
    return [self createUri:vhost component:component showPersonalizedAds:true];
}

/**
 Private function that will create the url for the player
 @param vhost Base url to load, eg. bbvms.com
 @param component Name of the component to load
 @param showPersonalizedAds Show personalized ads to the user, phone setting will be leading when personalized ads should not show
 */
- (NSString *)createUri:(NSString *)vhost component:(NSString *)component showPersonalizedAds:(BOOL)showPersonalizedAds{
    NSMutableString *uri = [[NSMutableString alloc] initWithString:@"http"];
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]; // identifier for advertising
    BOOL latBoolean = ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]; // limit ad tracking

    if( secure ){
        [uri appendString:@"s"];
    }
    if( component == nil ){ // base uri
        [uri appendString:[NSString stringWithFormat:@"://%@/",vhost]];
    }
    else{ // component uri
        [uri appendString:[NSString stringWithFormat:@"://%@/component/?c=%@&v=%i",vhost,component,backendVersion]];
        [uri appendString:[NSString stringWithFormat:@"&adsystem_idtype=idfa&adsystem_rdid=%@", idfaString]]; // idfaString doesn't need percent encoding
        if (latBoolean == NO && showPersonalizedAds == NO) {
            latBoolean = YES;
        }
        [uri appendString:[NSString stringWithFormat:@"&adsystem_is_lat=%@", latBoolean ? @"1" : @"0"]];
        if( debug ){
            [uri appendString:@"&bbdebug"];
        }
    }
    
    return uri;
}

- (id)createPlayer:(CGRect)canvasSize setup:(BBPlayerSetup *)setup{
    return [self createPlayer:canvasSize clipId:@"0" setup:setup];
}

- (id)createPlayer:(CGRect)canvasSize clipId:(NSString *)clipId setup:(BBPlayerSetup *)setup{
    return [self createPlayer:canvasSize clipId:clipId token:@"" setup:setup];
}

- (id)createPlayer:(CGRect)canvasSize clipId:(NSString *)clipId token:(NSString *)token setup:(BBPlayerSetup *)setup{
    
    NSString *uri = [self createUri:self.vhost component:@"iOSAppPlayer" showPersonalizedAds:setup.showPersonalizedAds];
    NSString *baseUri = [self createUri:self.vhost];
    
    NSLog(@"Uri for player: %@", uri);
    
    [setup setDebug:debug];
    
    return [[BBPlayer alloc] initWithUri:uri frame:canvasSize clipId:clipId token:token baseUri:baseUri setup:setup];
}

@end
