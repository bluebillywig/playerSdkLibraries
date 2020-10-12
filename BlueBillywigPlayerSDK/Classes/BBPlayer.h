//
//  BBPlayerConnector.h
//  BB Webview
//
//  Created by Floris Groenendijk on 30/06/14.
//  Copyright (c) 2014 Floris Groenendijk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface BBPlayerSetup: NSObject{
    BOOL fullscreenOnRotateToLandscape;
    BOOL debug;
    BOOL showPersonalizedAds;
    NSString *playout;
    NSString *assetType;
    NSString *adUnit;
};
- (void)setFullscreenOnRotateToLandscape:(BOOL)fullscreenOnRotateToLandscape;
- (void)setDebug:(BOOL)debug;
- (void)showPersonalizedAds:(BOOL)showPersonalizedAds;
- (void)setPlayout:(NSString * _Nonnull)playout;
- (void)setAssetType:(NSString * _Nonnull)assetType;
- (void)setAdUnit:(NSString * _Nonnull)adUnit;

- (BOOL)fullscreenOnRotateToLandscape;
- (BOOL)debug;
- (BOOL)showPersonalizedAds;
- (NSString * _Nonnull)playout;
- (NSString * _Nonnull)assetType;
- (NSString * _Nonnull)adUnit;
@end

@interface Playout: NSObject <NSCopying>{
    NSString *autoPlay;
    NSString *startCollapsed;
    NSString *hidePlayerOnEnd;
    NSString *interactivity_inView;
    NSString *interactivity_outView;
};
- (void)setAutoPlay:(NSString * _Nonnull)autoPlay;
- (void)setStartCollapsed:(NSString * _Nonnull)startCollapsed;
- (void)setHidePlayerOnEnd:(NSString * _Nonnull)hidePlayerOnEnd;
- (void)setInteractivity_inView:(NSString * _Nonnull)interactivity_inView;
- (void)setInteractivity_outView:(NSString * _Nonnull)interactivity_outView;

- (NSString * _Nullable)autoPlay;
- (NSString * _Nullable)startCollapsed;
- (NSString * _Nullable)hidePlayerOnEnd;
- (NSString * _Nullable)interactivity_inView;
- (NSString * _Nullable)interactivity_outView;

- (NSString * _Nonnull)description;
@end

@protocol BBPlayerEventDelegate
- (void)function:(NSString * _Nonnull)functionName;
- (void)function:(NSString * _Nonnull)functionName object:(NSObject * _Nonnull)object;
- (void)function:(NSString * _Nonnull)functionName value:(NSString * _Nonnull)value;
- (void)onLoadedPlayout:(Playout * _Nonnull)playout;
- (void)onPlay;
- (void)onPause;
- (void)onReady;
- (void)onResized;
- (void)onLoadedClipData;
- (void)onStarted;
- (void)onEnded;
- (void)onFullscreen;
- (void)onRetractFullscreen;
- (void)onVolumeChange;
- (void)onError;
- (void)runJavaScriptAlertPanelWithMessage:(NSString * _Nonnull)message initiatedByFrame:(WKFrameInfo * _Nonnull)frame completionHandler:(void (^_Nullable)(void))completionHandler;
- (void)runJavaScriptConfirmPanelWithMessage:(NSString * _Nonnull)message initiatedByFrame:(WKFrameInfo * _Nonnull)frame completionHandler:(void (^_Nullable)(BOOL result))completionHandler;
- (void)runJavaScriptTextInputPanelWithPrompt:(NSString * _Nonnull)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *_Nullable)frame completionHandler:(void (^_Nullable)(NSString * __nullable result))completionHandler;
@end

@interface BBPlayer : WKWebView<UIAlertViewDelegate,WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,UIScrollViewDelegate>

@property (nonatomic,weak) id <BBPlayerEventDelegate> _Nullable playerDelegate;
@property (nonatomic,retain) WKWebViewConfiguration * _Nullable wkWebViewConfiguration;

- (NSString * _Nonnull)version;

/**
 Initializer, provide uri to load in webview, doesn't fully initialize yet
 @param uri Load this uri in the webview
 @param frame Size of the webview frame
 @param baseUri Use for functions that need the baseUri
 */
- (id _Nullable)initWithUri:(NSString * _Nonnull)uri frame:(CGRect)frame baseUri:(NSString * _Nonnull)baseUri;

/**
 Initializer, provide uri to load in webview
 @param uri Load this uri in the webview
 @param frame Size of the webview frame
 @param clipId Id of the clip to play in the player
 @param token Video token (24h valid) for protected video's, to use tokens contact sales@bluebillywig.com
 More information: http://bluebillywig.com/nl/blog/your-content-your-rules-how-control-video-content-accessibility
 @param setup Player setup
 @param baseUri Use for functions that need the baseUri
 */
- (id _Nullable)initWithUri:(NSString * _Nonnull)uri frame:(CGRect)frame clipId:(NSString * _Nullable)clipId token:(NSString * _Nullable)token baseUri:(NSString * _Nonnull)baseUri setup:(BBPlayerSetup * _Nonnull)setup;

/**
 Loads the player in an empty initialized WebView
 @param clipId Id of the clip to play in the player
 @param setup Player setup
 */
- (void)lateInitialize:(NSString * _Nonnull)clipId setup:(BBPlayerSetup * _Nonnull)setup;

/**
 Loads the player in an empty initialized WebView
 @param clipId Id of the clip to play in the player
 @param token Video token (24h valid) for protected video's, to use tokens contact sales@bluebillywig.com
 More information: http://bluebillywig.com/nl/blog/your-content-your-rules-how-control-video-content-accessibility
 @param setup Player setup
 */
- (void)lateInitialize:(NSString * _Nonnull)_clipId token:(NSString * _Nullable)_token setup:(BBPlayerSetup * _Nonnull)setup;

/**
 Function to attach to a player event, like fullscreen or playing
 @see https://support.bluebillywig.com/blue-billywig-v5-player/events-modes-and-phases
 @param event Event to attach to
 @param parent The object to which the function belongs
 @param function Name of the function that will get the event
 */
- (void)on:(NSString * _Nonnull)event parent:(id _Nonnull)parent function:(NSString * _Nonnull)function;

/**
 Function to attach to the loadedplayoutdata event
 @see https://support.bluebillywig.com/blue-billywig-v5-player/events-modes-and-phases
 @param parent The object to which the function belongs
 @param function Name of the function that will get the event
 */
- (void)onLoadedPlayoutData:(id _Nonnull)parent function:(NSString * _Nonnull)function;

/**
 Function to disconnect a player event, like fullscreen or playing
 @see https://support.bluebillywig.com/blue-billywig-v5-player/events-modes-and-phases
 @param event Event to disconnect from
 */
- (void)off:(NSString * _Nonnull)event;

/**
 Call a method on the player embedded in the webview
 @see https://support.bluebillywig.com/blue-billywig-v5-player/functions
 */
- (NSString * _Nullable)call:(NSString * _Nonnull)function;

/**
 Call a method on the player embedded in the webview
 @see https://support.bluebillywig.com/blue-billywig-v5-player/functions
 @param function Name of the function that will be called
 @param argument Argument that's needed in the function
 */
- (NSString * _Nullable)call:(NSString * _Nonnull)function argument:(NSString * _Nullable)argument;

/**
 Call a method on the player embedded in the webview
 @see https://support.bluebillywig.com/blue-billywig-v5-player/functions
 @param function Name of the function that will be called
 @param arguments Arguments that are needed in the function
 */
- (NSString * _Nullable)call:(NSString * _Nonnull)function arguments:(NSDictionary * _Nullable)arguments;

/**
 Update user ad tracking dynamically
 @param showPersonalizedAds Enable or disable showing of personalized ads
 */
- (void)showPersonalizedAds:(BOOL)showPersonalizedAds;

/**
 This function should be called from the controller that contains the UIWebView.
 It does not trigger automatically, and this function should be called when fullscreenOnRotateToLandscape is true.
 @param interfaceOrientation The new orientation
 @param duration Duration of the orientation change
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

/**
 Use this function to start or resume the player.
 */
- (void)play;

/**
 Use this function to pause the player.
 */
- (void)pause;

/**
 Use this function to seek to a point in the video.
 @param timeInSeconds time to seek to
 */
- (void)seek:(float)timeInSeconds;

/**
 Use this function to mute or unmute the video.
 @param mute mute or unmute
 */
- (void)mute:(BOOL)mute;

/**
 Use this function to load a clip using it's clip id.
 @param clipId Id of clip to load
 */
- (NSString * _Nullable)loadClip:(NSString * _Nonnull)clipId;

/**
 Use this function to load a clip using it's clip id.
 @param clipId Id of clip to load
 @param token Video token (24h valid) for protected video's, to use tokens contact sales@bluebillywig.com
 More information: http://bluebillywig.com/nl/blog/your-content-your-rules-how-control-video-content-accessibility
 */
- (NSString * _Nullable)loadClip:(NSString * _Nonnull)clipId token:(NSString * _Nonnull)token;

/**
 Use this function to make the player go to fullscreen mode.
 */
- (void)fullscreen;

/**
 Use this function to make the player go out of fullscreen mode.
 */
- (void)retractFullscreen;

/**
 Use this function to cleanup the player
 */
-(void)destroy;

/**
 Expand the view to the frame dimension that is provided
 */
- (void)expand:(UIView * _Nullable)view;

/**
Collapse the view
*/
- (void)collapse:(UIView * _Nullable)view;

@end
