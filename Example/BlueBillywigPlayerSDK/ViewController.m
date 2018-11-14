//
//  ViewController.m
//  BB Webview
//
//  Created by Floris Groenendijk on 4/8/13.
//  Copyright (c) 2013 Floris Groenendijk. All rights reserved.
//

#import "ViewController.h"
#import "BBComponent.h"

@interface ViewController ()
@end

@implementation ViewController

@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize bbPlayerWebView = _bbPlayerWebView;
@synthesize playerWebViewPlaceholder = _playerWebViewPlaceholder;

@synthesize createButton = _createButton;
@synthesize checkButton = _checkButton;
@synthesize destroyButton = _destroyButton;

@synthesize attachTimeupdateButton = _attachTimeupdateButton;
@synthesize removeTimeupdateButton = _removeTimeupdateButton;

@synthesize componentVersion = _componentVersion;
@synthesize textField = _textField;

@synthesize playout = _playout;

bool fullscreen = false;
bool window = false;
CGRect mainFrame;

CGRect playerRect;

bool hasAdUnit = false;

- (IBAction)attachTimeupdateButton:(id)sender {
    if( self.bbPlayerWebView != nil ){
        [self.bbPlayerWebView on:@"timeupdate" parent:self function:@"timeupdate"];
    }
}

- (IBAction)removeTimeupdateButton:(id)sender {
    if( self.bbPlayerWebView != nil ){
        [self.bbPlayerWebView off:@"timeupdate"];
    }
}

- (IBAction)createButton:(id)sender {
    
    if( self.bbPlayerWebView == nil ){
        NSString *token =  @"dfb4bf863f2bcb94f05c582365c48442a20be66f";
        
        BBComponent *bbComponent = [[BBComponent alloc] initWithPublication:@"demo" vhost:@"demo.bbvms.com" secure:true debug:false];
//        bbComponent = [[BBComponent alloc] initWithPublication:@"bb.dev" vhost:@"bb.dev.bbvms.com" secure:true debug:false];
        
        /* Setup player by creating a BBPlayerSetup object */
        BBPlayerSetup *bbPlayerSetup = [[BBPlayerSetup alloc] init];
        [bbPlayerSetup setPlayout:@"iosapp"];
        [bbPlayerSetup setFullscreenOnRotateToLandscape:YES];
        
        /* Creating a new BBPlayer object */
        self.bbPlayerWebView = [bbComponent createPlayer:self.playerWebViewPlaceholder.frame clipId:@"2119201" token:token setup:bbPlayerSetup];
//        self.bbPlayerWebView = [bbComponent createPlayer:self.playerWebViewPlaceholder.frame clipId:@"1081520" token:token setup:bbPlayerSetup];

        /* Receive delegates by adding <BBPlayerEventDelegate> to the ViewController header file and
         attaching the BBPlayer delegate to this ViewController */
        self.bbPlayerWebView.playerDelegate = self;
        
        /* Add BBPlayer as a subview of the current view to show it */
        [self.view addSubview:self.bbPlayerWebView];
        
        /* After placing the player it is possible to directly call a function */
        [self.bbPlayerWebView play];
        NSLog(@"ViewController - player is: %@",self.bbPlayerWebView);
        
    }
    else{
        NSLog(@"ViewController - There is a bbPlayerWebView still active: %@",self.bbPlayerWebView);
    }
}

- (IBAction)checkButton:(id)sender {
    NSLog(@"ViewController - player instance: %@", self.bbPlayerWebView);
}

- (IBAction)destroyButton:(id)sender {
    NSLog(@"ViewController - Removing player from superview");
    [self.bbPlayerWebView removeFromSuperview];
}

/**
 This will be called when the play button is pressed
 */
- (IBAction)playVideo:(id)sender {
    if (hasAdUnit) {
        [self.bbPlayerWebView expand:self.bbPlayerWebView];
        [self.bbPlayerWebView mute:false];
    }
    NSLog(@"ViewController - Playing video");
    if( [self.textField.text isEqualToString:@""] ) {
        [self.bbPlayerWebView play];
    } else {
        NSLog(@"Starting url %@ in WKWebview", self.textField.text);
        WKWebViewConfiguration *wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
        wkWebViewConfiguration.allowsInlineMediaPlayback = true;
        wkWebViewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;

        self.wkWebView = [[WKWebView alloc] initWithFrame:self.playerWebViewPlaceholder.frame configuration:wkWebViewConfiguration];
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.textField.text]]];
        [self.view addSubview:self.wkWebView];
        self.bbPlayerWebView = nil;
    }
}

/**
 This will be called when the pause button is pressed
 */
- (IBAction)pauseVideo:(id)sender {
    NSLog(@"ViewController - Pausing video");
    [self.bbPlayerWebView pause];
}

/**
 This will be called when the load clip button is pressed
 */
- (IBAction)loadClip:(id)sender {
    NSString *result = [self.bbPlayerWebView loadClip:@"2337181"];
    NSLog(@"ViewController - Load clip result: %@", result);
    // Uncomment call below to use token based security video's, described in the viewDidLoad function
    //[self.bbPlayerWebView call:@"load" argument:@"{\"type\":\"LoadParams\", \"clipId\":\"2337181\", \"token\":\"5f5611d6ddf21a912b5f26bda9da62a5ec18f56b\"}"];
}

/**
 View has loaded
 */
- (void)viewDidLoad
{
//    [super viewDidLoad];
    
    NSLog(@"ViewController - viewDidLoad");
    
    playerRect = self.playerWebViewPlaceholder.frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    mainFrame = self.view.frame;

    /* Add new BBComponent object to be able to create a BBPlayer object */
    BBComponent *bbComponent = [[BBComponent alloc] initWithPublication:@"demo" vhost:@"demo.bbvms.com" secure:true debug:false];
//    bbComponent = [[BBComponent alloc] initWithPublication:@"bb.dev" vhost:@"bb.dev.bbvms.com" secure:true debug:false];

    [self.componentVersion setText:[[NSString alloc] initWithFormat:@"Component versie: %@", bbComponent.version]];
    
    /* Setup player by creating a BBPlayerSetup object */
    BBPlayerSetup *bbPlayerSetup = [[BBPlayerSetup alloc] init];
    [bbPlayerSetup setPlayout:@"iosapp"];

    // Uncomment line below to use outstream ads
//    [bbPlayerSetup setAdUnit:@"companion_ad_test"];
    
    [bbPlayerSetup setFullscreenOnRotateToLandscape:YES];

    /**
     This is an example token, tokens are used to get unrestricted access to mediaclip(s)
     To use this functionality please contact sales@bluebillywig.com
     For more information: http://bluebillywig.com/nl/blog/your-content-your-rules-how-control-video-content-accessibility
     */
    NSString *token =  @"dfb4bf863f2bcb94f05c582365c48442a20be66f";

    /* The code below this comment will place a player on the screen without creating a placeholder in a storyboard */
//    CGRect frame = CGRectMake(0, 0, 450, 200);

    // 2 lines below are needed to use outstream ads
    if ([bbPlayerSetup.adUnit length] > 0) {
        self.bbPlayerWebView = [bbComponent createPlayer:self.playerWebViewPlaceholder.frame setup:bbPlayerSetup];
        [self.bbPlayerWebView onLoadedPlayoutData:self function:@"onLoadedPlayout"];

        hasAdUnit = true;
    } else {
        // We're using the UIWebView as placeholder for the frame
        self.bbPlayerWebView = [bbComponent createPlayer:self.playerWebViewPlaceholder.frame clipId:@"2119201" setup:bbPlayerSetup];
//        self.bbPlayerWebView = [bbComponent createPlayer:self.playerWebViewPlaceholder.frame clipId:@"1081547" token:token setup:bbPlayerSetup];
    }

    // Uncomment line below to use token based authentication for video's
    // self.bbPlayerWebView = [bbComponent createPlayer:self.playerWebViewPlaceholder.frame clipId:@"2119201" token:token setup:bbPlayerSetup];

    self.bbPlayerWebView.playerDelegate = self;
    [self.view addSubview:self.bbPlayerWebView];

    if (!hasAdUnit) {
        [self.bbPlayerWebView play];
    } else {
        [self.bbPlayerWebView collapse:self.bbPlayerWebView];
    }

    /* Uncomment the following line to receive timeupdate events from the player */
//    [self.bbPlayerWebView on:@"timeupdate" parent:self function:@"timeupdate"];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)keyboardDidShow: (NSNotification *) notification{
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y - 50;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    [self.view setClearsContextBeforeDrawing:true];
    [self.view setFrame:frame];

    [UIView commitAnimations];
    [self.bbPlayerWebView reload];
}

- (void)keyboardDidHide: (NSNotification *) notification{
    CGRect frame = mainFrame;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    [self.view setClearsContextBeforeDrawing:true];
    [self.view setFrame:frame];

    [UIView commitAnimations];
    [self.bbPlayerWebView reloadInputViews];
}

- (void)runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog( @"ViewController - App got alert: %@", message );
}

- (void)runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSLog( @"ViewController - App got confirm panel: %@", message );
}

- (void)runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    NSLog( @"ViewController - App got text input panel: %@", prompt );
    
}

-(void) function:(NSString *)functionName{
    NSLog(@"ViewController - Function called: %@",functionName);
}

-(void) function:(NSString *)functionName object:(NSObject * _Nonnull)object{
    NSLog(@"ViewController - Function called: %@",functionName);
    // This function name is the same string as the function name provided with onLoadedPlayoutData
    if ([functionName isEqualToString:@"onLoadedPlayout"]) {
        self.playout = (Playout *)object;
        NSLog(@"ViewController - function has arguments %@", self.playout);
        if ([[self.playout autoPlay] isEqualToString:@"true"]) {
            [self.bbPlayerWebView play];
            [self.bbPlayerWebView mute:false];
        }
        if ([[self.playout startCollapsed] isEqualToString:@"false"]) {
            [self.bbPlayerWebView expand:self.bbPlayerWebView];
        }
    }
}

-(void) onLoadedPlayout:(NSObject *)object{
    NSLog(@"ViewController - onLoadedPlayout %@", object);
}

-(void) onLoadedClipData{
    NSLog(@"ViewController - onLoadedClipData");
}

-(void) onPlay{
    NSLog(@"ViewController - onPlay");
    if (hasAdUnit) {
        [self.bbPlayerWebView expand:self.bbPlayerWebView];
    }
}

-(void) onPause{
    NSLog(@"ViewController - onPause");
}

-(void) onStarted{
    NSLog(@"ViewController - onStarted");
}

-(void) onReady{
    NSLog(@"ViewController - onReady");
    [self.bbPlayerWebView call:@"getPlayoutData"];
}

-(void) onEnded{
    NSLog(@"ViewController - onEnded");
    if (hasAdUnit) {
        if ([[self.playout hidePlayerOnEnd] isEqualToString:@"true"]) {
            [self.bbPlayerWebView collapse:self.bbPlayerWebView];
        }
    }
}

-(void) onError{
    NSLog(@"ViewController - onError");
}

-(void) onFullscreen{
    NSLog(@"ViewController - onFullscreen");
}

-(void) onRetractFullscreen{
    NSLog(@"ViewController - onRetractFullscreen");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    if( self.bbPlayerWebView == nil ) {
        if( interfaceOrientation == UIInterfaceOrientationPortrait ) {
            [self.wkWebView setFrame:playerRect];
        } else {
            CGRect webViewFrame = mainFrame;

            int yPosition = mainFrame.size.width;

            webViewFrame.size.height = yPosition;
            webViewFrame.size.width = mainFrame.size.height;

            [self.wkWebView setFrame:webViewFrame];
        }
    } else {
        [self.bbPlayerWebView willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    }
}

@end
