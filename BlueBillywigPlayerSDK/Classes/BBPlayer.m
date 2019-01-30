//
//  BBPlayerConnector.m
//  BB Webview
//
//  Created by Floris Groenendijk on 30/06/14.
//  Copyright (c) 2014 Floris Groenendijk. All rights reserved.
//

#import "BBPlayer.h"
#import "Version.h"
#import <Foundation/NSNull.h>

#ifndef DEBUG
#undef NSLog
#endif

@implementation BBPlayerSetup

- (NSString *)version{
    Version *version = [[Version alloc] init];
    return [version getVersion];
}

- (id)init{
    
    if( self = [super init] ){
        fullscreenOnRotateToLandscape = NO;
        debug = NO;
        playout = @"default";
        assetType = @"c";
        adUnit = @"";
    }
    return self;
}

- (void)setFullscreenOnRotateToLandscape:(BOOL)_fullscreenOnRotateToLandscape {
    fullscreenOnRotateToLandscape = _fullscreenOnRotateToLandscape;
}

- (void)setDebug:(BOOL)_debug{
    debug = _debug;
}

- (void)setPlayout:(NSString *)_playout{
    playout = _playout;
}

- (void)setAssetType:(NSString *)_assetType{
    assetType = _assetType;
}

- (void)setAdUnit:(NSString *)_adUnit{
    adUnit = _adUnit;
}

- (BOOL)fullscreenOnRotateToLandscape{
    return fullscreenOnRotateToLandscape;
}

- (BOOL)debug{
    return debug;
}

- (NSString *)playout{
    return playout;
}

- (NSString *)assetType{
    return assetType;
}

- (NSString *)adUnit{
    return adUnit;
}

@end


@implementation Playout

- (id)init{
    if( self = [super init] ){
        autoPlay = @"";
        startCollapsed = @"";
        hidePlayerOnEnd = @"";
        interactivity_inView = @"";
        interactivity_outView = @"";
    }
    return self;
}

- (NSString *) autoPlay {
    return autoPlay;
}

- (NSString *) startCollapsed {
    return startCollapsed;
}

- (NSString *) hidePlayerOnEnd {
    return hidePlayerOnEnd;
}

- (NSString *) interactivity_inView {
    return interactivity_inView;
}

- (NSString *) interactivity_outView {
    return interactivity_outView;
}

- (void)setAutoPlay:(NSString * _Nonnull)_autoPlay {
    autoPlay = _autoPlay;
}

- (void)setStartCollapsed:(NSString * _Nonnull)_startCollapsed {
    startCollapsed = _startCollapsed;
}

- (void)setHidePlayerOnEnd:(NSString * _Nonnull)_hidePlayerOnEnd {
    hidePlayerOnEnd = _hidePlayerOnEnd;
}

- (void)setInteractivity_inView:(NSString * _Nonnull)_interactivity_inView {
    interactivity_inView = _interactivity_inView;
}

- (void)setInteractivity_outView:(NSString * _Nonnull)_interactivity_outView {
    interactivity_outView = _interactivity_outView;
}

- (NSString *)description{
    return [[NSString alloc] initWithFormat:@"autoPlay: %@, startCollapsed: %@, hidePlayerOnEnd: %@, interactivity_inView: %@, interactivity_outView: %@", autoPlay, startCollapsed, hidePlayerOnEnd, interactivity_inView, interactivity_outView];
}

-(id) copyWithZone:(NSZone *)zone {
    Playout *copy = [[Playout allocWithZone: zone] init];

    [copy setAutoPlay:self.autoPlay];
    [copy setStartCollapsed:self.startCollapsed];
    [copy setHidePlayerOnEnd:self.hidePlayerOnEnd];
    [copy setInteractivity_inView:self.interactivity_inView];
    [copy setInteractivity_outView:self.interactivity_outView];
    return copy;
}

@end


@implementation BBPlayer{
    NSString *uri;
    NSString *baseUri;
    NSString *mediaclipUrl;
    NSString *token;
    
    NSMutableDictionary *callbackQueue;
    NSMutableArray *callQueue;
    
    int alertCallbackId;
    CGRect fullscreenRect;
    CGRect originalRect;
    
    bool playerReady;
    bool firstRun;
    bool autoPlay;
    BOOL debug;
    
    NSString *adUnit;
    bool hasAdUnit;

    BOOL fullscreenOnRotateToLandscape;
    bool startedInLandscape;
    bool collapsed;

    NSString *playoutName;
    NSString *assetType;
    NSString *clipId;
    
    WKUserContentController *wkUserContentController;
}

@synthesize playerDelegate = _playerDelegate;
@synthesize wkWebViewConfiguration = _wkWebViewConfiguration;

NSRegularExpression *urlRegex = nil;

- (NSString *)version{
    Version *version = [[Version alloc] init];
    return [version getVersion];
}

- (id)initWithUri:(NSString *)_uri frame:(CGRect)frame clipId:(NSString *)_clipId token:(NSString *)_token baseUri:(NSString *)_baseUri setup:(BBPlayerSetup *)setup{    
    fullscreenRect = [[UIScreen mainScreen] bounds];
    fullscreenOnRotateToLandscape = [setup fullscreenOnRotateToLandscape];
    collapsed = false;
    
    urlRegex = [NSRegularExpression regularExpressionWithPattern:@"^[^#]*#" options:NSRegularExpressionCaseInsensitive error:nil];
    
    float width = 0;
    float height = 0;
    playerReady = false;
    firstRun = true;
    autoPlay = false;
    
    if( fullscreenOnRotateToLandscape ){
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)){
            width = fullscreenRect.size.width;
            height = fullscreenRect.size.height;
            float width = fullscreenRect.size.width;
            fullscreenRect.size.width = fullscreenRect.size.height;
            fullscreenRect.size.height = width;
            startedInLandscape = true;
        } else {
            width = frame.size.width;
            height = frame.size.height;
            startedInLandscape = false;
        }
    }
    else{
        width = frame.size.width;
        height = frame.size.height;
    }
    
    originalRect = frame;
    callbackQueue = [[NSMutableDictionary alloc] init];
    callQueue = [[NSMutableArray alloc] init];

    
    wkUserContentController = [[WKUserContentController alloc] init];
    [wkUserContentController addScriptMessageHandler:self name:@"callbackHandler"];
    
    self.wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    self.wkWebViewConfiguration.userContentController = wkUserContentController;
    self.wkWebViewConfiguration.allowsInlineMediaPlayback = true;
#if __IPHONE_OS_VERSION_MIN_REQUIRED > 93000
    // target is higher than iOS 9.3.1
    self.wkWebViewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
#else
    self.wkWebViewConfiguration.requiresUserActionForMediaPlayback = NO;
#endif
    
    if ( self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width, height) configuration:self.wkWebViewConfiguration] ) {
        uri = _uri;
        
        baseUri = _baseUri;
        playoutName = [setup playout];
        assetType = [setup assetType];
        clipId = _clipId;
        token = _token;
        debug = [setup debug];
        adUnit = [setup adUnit];
        if ( adUnit.length > 0 ) {
            hasAdUnit = YES;
        }

        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = NO;
        self.scrollView.maximumZoomScale = 1.0;
        self.scrollView.minimumZoomScale = 1.0;
        
        self.backgroundColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:1];

        //Create a URL object.
        NSURL *url = [NSURL URLWithString:uri];
//        url = [NSURL URLWithString:@"https://google.com"];
//        url = [NSURL URLWithString:@"https://demo.bbvms.com/p/iosapp/c/2119206.html"];
        
        //URL Request Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        [self loadRequest:requestObj];
    }
    NSLog(@"Initialized function with self %@ and clipId: %@",self,_clipId);

    self.UIDelegate = self;

    [self hitTest:CGPointMake(10, 10) withEvent:nil];
    if (hasAdUnit) {
        [self fullscreen];
    }

    return self;
}

/**
 Private removeFromSuperview event, cleanup after yourself
 */
- (void)removeFromSuperview{
    NSLog(@"Removing from superview");
    [super removeFromSuperview];
}

-(void)dealloc{
    NSLog(@"Deallocating BBPlayer");
    for (NSString *function in callbackQueue) {
        [self off:function shutdown:true];
    }
    [callbackQueue removeAllObjects];
    callbackQueue = nil;
    [callQueue removeAllObjects];
    callQueue = nil;
    [wkUserContentController removeAllUserScripts];
    [wkUserContentController removeScriptMessageHandlerForName:@"callbackHandler"];
    wkUserContentController = nil;
    self.playerDelegate = nil;
    self.UIDelegate = nil;
    self.wkWebViewConfiguration = nil;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"userContentController - %@, %@, %@",message.body,self,[message.body hasPrefix:@"debug:"]?@"yes":@"no");
    
    NSArray *components = [message.body componentsSeparatedByString:@":"];
    
    if( [components count] < 2 ){
        NSLog(@"userContentController - not enough arguments, exiting userContentController function");
        return;
    }
    
    NSString *functionName = (NSString*)[components objectAtIndex:0];
    
    Playout *playout = nil;
    NSString *originalFunctionName = nil;

    NSArray *args = [[NSArray alloc] init];
    
    if( [components count] > 2 ) {
        if( ! [(NSString*)[components objectAtIndex:2] containsString:@"undefined"] ) {
            
            NSData *jsonData = [(NSString*)[[components objectAtIndex:2] stringByRemovingPercentEncoding] dataUsingEncoding:NSUTF8StringEncoding];

            NSError *error;
        
            // Note that JSONObjectWithData will return either an NSDictionary or an NSArray, depending whether your JSON string represents an a dictionary or an array.
            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
            if (error) {
                NSLog(@"userContentController - Error parsing JSON: %@", error);
            }
            else
            {
                NSLog(@"userContentController - jsonObject: %@", jsonObject);
                if ([jsonObject isKindOfClass:[NSArray class]])
                {
                    NSLog(@"userContentController - Found an array, start parsing arguments");
                    args = (NSArray *)jsonObject;
                    NSLog(@"userContentController - json array - %@",args);
                }
                else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"userContentController - Found a dictionary, start parsing arguments");
                    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
                    NSDictionary *dictionary = [jsonDictionary objectForKey:@"loadedAdPlayoutData"];

                    if (dictionary) {
                        originalFunctionName = functionName;
                        functionName = @"onLoadedAdPlayout";
                        playout = [[Playout alloc] init];
                        for(NSString *key in dictionary) {
                            NSLog(@"userContentController - found key: %@", key);
                            if ([key isEqualToString:@"autoPlay"]) {
                                [playout setAutoPlay:[dictionary objectForKey:key]];
                            } else if ([key isEqualToString:@"startCollapsed"]) {
                                [playout setStartCollapsed:[dictionary objectForKey:key]];
                            } else if ([key isEqualToString:@"hidePlayerOnEnd"]) {
                                [playout setHidePlayerOnEnd:[dictionary objectForKey:key]];
                            } else if ([key isEqualToString:@"interactivity_inView"]) {
                                [playout setInteractivity_inView:[dictionary objectForKey:key]];
                            } else if ([key isEqualToString:@"interactivity_outView"]) {
                                [playout setInteractivity_outView:[dictionary objectForKey:key]];
                            }
                        }
                    }

                }
                else {
                    NSLog(@"userContentController - Found a dictionary, not parsing, only parsing json objects (contained in [..])");
                }
            }
        }
    }
    
    //Parse functionName, args and callbackId from message.body
    
    NSLog(@"userContentController - Got %@ event",functionName);
    
    /* This function is called to notify the WKWebView that the bbAppBridge is operational */
    if( [functionName isEqualToString:@"appbridgeready"] ) {
        if (hasAdUnit) {
            mediaclipUrl = [NSString stringWithFormat:@"%@a/%@.json", baseUri, adUnit];
        } else {
            mediaclipUrl = [NSString stringWithFormat:@"%@p/%@/%@/%@.json", baseUri, playoutName, assetType, clipId];
        }
        if( token != NULL && token.length > 0 ){
            mediaclipUrl = [mediaclipUrl stringByAppendingString:[NSString stringWithFormat:@"?token=%@", token]];
        }
        
        NSLog(@"Trying to place player bbAppBridge.placePlayer('%@')",mediaclipUrl);
        [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.placePlayer('%@');", mediaclipUrl] completionHandler:^(id result, NSError *error) {
            if (error == nil)
            {
                if (result != nil)
                {
                    NSLog(@"result: %@", result);
                }
            }
            else
            {
                NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
            }
        }];

        playerReady = true;
        [self on:@"ready" parent:self function:@"onPlayerReady"];
        [self on:@"loadedclipdata" parent:self function:@"onLoadedClipData"];
    }
    else if ([functionName isEqualToString:@"onPlayerReady"]){
        if( !firstRun ){
            NSLog(@"userContentController - Already initialized, skipping...");
            return;
        }
        
        firstRun = false;
        playerReady = true;
        NSMutableArray *handledObjects = [[NSMutableArray alloc] init];
        for (NSString *function in callbackQueue) {
            NSLog(@"userContentController - Checking for unconnected event");
            NSMutableArray *callbackArray = [callbackQueue objectForKey:function];
            
            NSString *event = nil;
            NSString *attached = @"false";
            
            if( [callbackArray count] > 1 ){
                attached = callbackArray[1];
                
                NSLog(@"callbackArray count %ld attached: %@", (unsigned long)[callbackArray count],attached);
                
                if( [attached isEqualToString:@"false"] ){
                    event = callbackArray[2];
                    NSLog(@"Late binding of event: %@ to function: %@", event, function);
                    
                    [handledObjects addObject:function];
                    
                    if( [event isEqualToString:functionName] ){
                        id parent = callbackArray[0];
                        
                        if( parent != nil ){

                            WKScriptMessage *message = [[WKScriptMessage alloc] init];
                            [message setValue:[[NSString alloc] initWithFormat: @"%@:%@:%@", function, parent, args] forKey:@"callbackHandler"];
                            
                            [self userContentController:wkUserContentController didReceiveScriptMessage:message];
                        }
                    }
                    
                    if( [function isEqualToString:@"off"] ){
                        [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.off('%@')", event] completionHandler:nil];
                    }
                    else{
                        [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.on('%@','%@')", event, function] completionHandler:nil];
                    }
                }
            }
        }
        [callbackQueue removeAllObjects];
        [self.playerDelegate onReady];
        NSLog(@"Checking for unconnected event");
        [self on:@"started" parent:self function:@"onStarted"];
        [self on:@"ended" parent:self function:@"onEnded"];
        [self on:@"fullscreen" parent:self function:@"onFullscreen"];
        [self on:@"retractfullscreen" parent:self function:@"onRetractFullscreen"];
        [self on:@"error" parent:self function:@"onError"];
        [self on:@"play" parent:self function:@"onPlay"];
        [self on:@"pause" parent:self function:@"onPause"];
        if( startedInLandscape ){
            [self call:@"fullscreen"];
        }

        for (NSDictionary *dictionary in callQueue) {
            for(NSString *function in dictionary){
                NSLog(@"userContentController - calling function late: %@, %@",function,dictionary);

                NSObject *object = [dictionary objectForKey:function];
                if( [object isKindOfClass:[NSString class]] ){
                    NSString *argument = (NSString *)object;
                    [self call:function argumentObject:argument];
                }
                else if( [object isKindOfClass:[NSDictionary class]] ){
                    NSDictionary *arguments = (NSDictionary *)object;
                    [self call:function argumentObject:arguments];
                }
                else{
                    [self call:function];
                }
            }
        }
        [callQueue removeAllObjects];
        //        [self getIframeMessage:@""];
    } else if ([functionName isEqualToString:@"onPlay"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onPlay];
    } else if ([functionName isEqualToString:@"onPause"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onPause];
    } else if ([functionName isEqualToString:@"onLoadedClipData"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onLoadedClipData];
    } else if ([functionName isEqualToString:@"onLoadedAdPlayout"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate function:originalFunctionName object:playout];
    } else if ([functionName isEqualToString:@"onStarted"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onStarted];
    } else if ([functionName isEqualToString:@"onEnded"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onEnded];
    } else if ([functionName isEqualToString:@"onFullscreen"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onFullscreen];
    } else if ([functionName isEqualToString:@"onRetractFullscreen"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onRetractFullscreen];
    } else if ([functionName isEqualToString:@"onError"]){
        NSLog(@"firing %@!",functionName);
        [self.playerDelegate onError];
    }
    else {
        NSLog(@"firing method %@!",functionName);
        [self.playerDelegate function:functionName];
    }
}

- (void)off:(NSString *)event{
    [self off:event shutdown:false];
}

- (void)off:(NSString *)event shutdown:(BOOL)shutdown{
    if( !shutdown ){
        NSString *function = @"off";
        if( playerReady ){
            NSLog(@"off - Removing function %@", event);
            @synchronized(self){
                [callbackQueue removeObjectForKey:function];
            }
            [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.off('%@')", event] completionHandler:nil];
        }
        else{
            id parent = self;
            NSLog(@"off - Queue removing function %@", event);
            NSMutableArray *callbackArray = [[NSMutableArray alloc] initWithArray:@[parent, @"false", event]];
            @synchronized(self){
                [callbackQueue setObject:callbackArray forKey:function];
            }
        }
    }
    else{
        [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.off('%@')", event] completionHandler:nil];
    }
}

- (void)on:(NSString *)event parent:(id)parent function:(NSString *)function{
    if( playerReady || parent == self ){
        NSLog(@"on - Attaching event %@ to function %@ with parent %@", event, function, parent);
        NSMutableArray * callbackArray = [[NSMutableArray alloc] initWithArray:@[parent, @"true"]];
        @synchronized(self){
            [callbackQueue setObject:callbackArray forKey:function];
        }
        [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.on('%@','%@')", event, function] completionHandler:nil];
    }
    else{
        NSLog(@"on - Queue event %@; function %@ with parent %@", event, function, parent);
        NSMutableArray *callbackArray = [[NSMutableArray alloc] initWithArray:@[parent, @"false", event]];
        @synchronized(self){
            [callbackQueue setObject:callbackArray forKey:function];
        }
    }
}

- (void)onLoadedPlayoutData:(id)parent function:(NSString *)function{
    [self on:@"loadedadplayoutdata" parent:parent function:function];
}

- (NSString *)call:(NSString *)function{
    return [self call:function arguments:nil];
}

- (NSString *)call:(NSString *)function argument:(NSString *)argument{
    return [self call:function argumentObject:argument];
}

- (NSString *)call:(NSString *)function arguments:(NSDictionary *)arguments{
    return [self call:function argumentObject:arguments];
}

- (NSString *)call:(NSString *)function argumentObject:(NSObject *)arguments{
    NSError *error;
    NSData *jsonData = nil;
    NSString *jsonString;
    
    if( arguments != nil ){
        if( [arguments isKindOfClass:[NSMutableDictionary class]] || [arguments isKindOfClass:[NSDictionary class]] || [arguments isKindOfClass:[NSString class]] ){
            if( [arguments isKindOfClass:[NSString class]] ){
                jsonString = (NSString *)arguments;
            }
            else{
                jsonData = [NSJSONSerialization dataWithJSONObject:arguments
                                                           options:0
                                                             error:&error];
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    
    if( arguments == nil ){
        NSLog(@"call - Calling function: %@",function);
        return [self evaluateJavaScriptSynchronous:[NSString stringWithFormat:@"bbAppBridge.call('%@');",function]];
    }
    else{
        if( !jsonString ){
            NSLog(@"call - There was an error converting the dictionary : %@", error);
            return nil;
        }
        else{
            NSLog(@"call - Calling function: %@ with json: %@",function,jsonString);
            return [self evaluateJavaScriptSynchronous:[NSString stringWithFormat:@"bbAppBridge.call('%@','%@');", function, jsonString]];
        }
    }
    return nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if( fullscreenOnRotateToLandscape && !collapsed ){
        if( interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ){
            CGRect webViewFrame = self.frame;
            
            webViewFrame.size.height = originalRect.size.height;
            webViewFrame.size.width = originalRect.size.width;

            [UIView animateWithDuration:1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.frame = webViewFrame;
                             }
                             completion:^(BOOL finished){
                                 NSLog(@"Done; resized to: %@", NSStringFromCGRect(self.frame));
                             }
             ];
        }
        else{
            CGRect webViewFrame = self.frame;
            
            int yPosition = fullscreenRect.size.width;
            
            webViewFrame.origin.x = 0;
            webViewFrame.origin.y = 0;
            webViewFrame.size.height = yPosition;
            webViewFrame.size.width = fullscreenRect.size.height;

            [UIView animateWithDuration:1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.frame = webViewFrame;
                             }
                             completion:^(BOOL finished){
                                 NSLog(@"Done; resized to: %@", NSStringFromCGRect(self.frame));
                             }
             ];
        }
    }
}

- (void)play{
    if( playerReady ){
        [self call:@"play"];
    }
    else{
        NSLog(@"Adding play to queue");
        NSDictionary *call = [[NSDictionary alloc] initWithObjects:@[[NSNull null]] forKeys:@[@"play"]];
        [callQueue addObject:call];
    }
}

- (void)pause{
    if( playerReady ){
        [self call:@"pause"];
    }
    else{
        NSLog(@"Adding pause to queue");
        NSDictionary *call = [[NSDictionary alloc] initWithObjects:@[[NSNull null]] forKeys:@[@"pause"]];
        [callQueue addObject:call];
    }
}

- (void)seek:(float)timeInSeconds{
    NSString *time = [NSString stringWithFormat:@"%f", timeInSeconds];
    if( playerReady ){
        [self call:@"seek" argument:time];
    }
    else{
        NSLog(@"Adding seek to queue");
        NSDictionary *call = [[NSDictionary alloc] initWithObjects:@[time] forKeys:@[@"seek"]];
        [callQueue addObject:call];
    }
}

- (void)mute:(BOOL)mute{
    NSString *muted = @"false";
    if (mute) {
        muted = @"true";
    }
    if( playerReady ){
        [self call:@"setMuted" argument:muted];
    }
    else{
        NSLog(@"Adding mute/unmute to queue");
        NSDictionary *call = [[NSDictionary alloc] initWithObjects:@[muted] forKeys:@[@"setMuted"]];
        [callQueue addObject:call];
    }
}

- (NSString *)loadClip:(NSString*)_clipId{
    return [self loadClip:_clipId token:@""];
}

- (NSString *)loadClip:(NSString*)_clipId token:(NSString *)_token{
    clipId = _clipId;
    
    NSDictionary *jsonDictionary = [[NSDictionary alloc] initWithObjects:@[_clipId] forKeys:@[@"clipId"]];
    if( _token != NULL && _token.length > 0 ){
        [jsonDictionary setValue:_token forKey:@"token"];
    }
    
    if( playerReady ){
        return [self call:@"load" arguments:jsonDictionary];
    }
    else{
        NSLog(@"Adding loadClip to queue");
        [callQueue addObject:[[NSDictionary alloc] initWithObjects:@[jsonDictionary] forKeys:@[@"loadClip"]]];
    }
    return nil;
}

- (void)fullscreen{
    if( playerReady ){
        [self call:@"fullscreen"];
    }
    else{
        NSLog(@"Adding fullscreen to queue");
        NSDictionary *call = [[NSDictionary alloc] initWithObjects:@[[NSNull null]] forKeys:@[@"fullscreen"]];
        [callQueue addObject:call];
    }
}

- (void)retractFullscreen{
    if( playerReady ){
        [self call:@"retractFullscreen"];
    }
    else{
        NSLog(@"Adding retractFullscreen to queue");
        NSDictionary *call = [[NSDictionary alloc] initWithObjects:@[[NSNull null]] forKeys:@[@"retractFullscreen"]];
        [callQueue addObject:call];
    }
}

- (float)getCurrentTime{
    if( playerReady ){
        return [[self call:@"getCurrentTime"] floatValue];
    }
    else{
        return 0.0f;
    }
}

- (bool)isPlaying{
    if( playerReady ){
        return [[self call:@"isPlaying"] boolValue];
    }
    else{
        return false;
    }
}

- (bool)isFullscreen{
    if( playerReady ){
        return [[self call:@"isFullscreen"] boolValue];
    }
    else{
        return false;
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"got javascript alert panel with message %@", message);
    [self.playerDelegate runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"got javascript confirm panel with message %@", message);
    [self.playerDelegate runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    completionHandler(TRUE);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"got javascript textinput panel with message %@", prompt);
    [self.playerDelegate runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
    completionHandler( prompt );
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil) {
        NSURL *url = navigationAction.request.URL;
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
        }
    }

    return nil;
}

- (NSString *)evaluateJavaScriptSynchronous:(NSString *)script
{
    __block NSString *resultString = nil;
    
    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
            else {
                resultString = @"";
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
    }];
    
    while (resultString == nil)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}

- (void)returnResult:(int)callbackId args:(id)arg, ...
{
    va_list argsList;
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    if(arg != nil){
        [resultArray addObject:arg];
        va_start(argsList, arg);
        while((arg = va_arg(argsList, id)) != nil)
            [resultArray addObject:arg];
        va_end(argsList);
    }
    
    // Create a json response from the argument(s) provided
    NSData *json = [NSJSONSerialization dataWithJSONObject:resultArray options:kNilOptions error:nil];
    
    NSString *jsonString = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
    NSLog(@"json to be sent: %@",jsonString);
    
    // Call javascript function
    [self evaluateJavaScript:[NSString stringWithFormat:@"bbAppBridge.resultForCallback('%d','%@');",callbackId,jsonString] completionHandler:nil];
}

- (void)collapse:(UIView *)view {
    CGRect cFrame = originalRect;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)){
        cFrame.size.width = fullscreenRect.size.height;
    }
    cFrame.size.height = 0;

    [UIView animateWithDuration:0.25 animations:^(void){
        view.frame = cFrame;
    }];
    collapsed = true;
}


- (void)expand:(UIView *)view{
    CGRect cFrame = originalRect;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)){
        cFrame.size.width = fullscreenRect.size.height;
        cFrame.size.height = fullscreenRect.size.width;
    }

    [UIView animateWithDuration:0.25 animations:^(void){
        view.frame = cFrame;
    }];
    collapsed = false;
}

@end
