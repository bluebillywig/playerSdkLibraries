//
//  BBComponent.h
//  BB Webview
//
//  Created by Floris Groenendijk on 01/07/14.
//  Copyright (c) 2014 Floris Groenendijk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BBPlayer.h"

@interface BBComponent : NSObject

@property (weak, nonatomic)NSString *publication;
@property (strong, nonatomic)NSString *vhost;

struct playerParameters{
    BOOL fullscreenOnRotateToLandscape;
    BOOL rotateToLandscapeOnFullscreen;
    BOOL debug;
    
};

- (NSString *)version;

/**
 Initializer, provide publication and vhost
 @param publication Name of the publication used
 @param vhost Base url to load, eg. bbvms.com
 */
- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost;

/**
 Initializer, provide publication and vhost with optional secure http
 @param publication Name of the publication used
 @param vhost Base url to load, eg. bbvms.com
 @param debug Enable debugging for the player
 */
- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost debug:(BOOL)debug;

/**
 Initializer, provide publication and vhost with optional secure http
 @param publication Name of the publication used
 @param vhost Base url to load, eg. bbvms.com
 @param secure When @c YES Load player over https
 */
- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost secure:(BOOL)secure;


/**
 Initializer, provide publication and vhost with optional secure http
 @param publication Name of the publication used
 @param vhost Base url to load, eg. bbvms.com
 @param secure When @c YES Load player over https
 @param debug Enable debugging for the player
 */
- (id)initWithPublication:(NSString *)publication vhost:(NSString *)vhost secure:(BOOL)secure debug:(BOOL)debug;

/**
 Create a webview with the Blue Billywig player
 @param canvasSize Size of the view
 @param setup Player setup
 */
- (id)createPlayer:(CGRect)canvasSize setup:(BBPlayerSetup *)setup;

/**
 Create a webview with the Blue Billywig player
 @param canvasSize Size of the view
 @param clipId Id of clip to play
 @param setup Player setup
 */
- (id)createPlayer:(CGRect)canvasSize clipId:(NSString *)clipId setup:(BBPlayerSetup *)setup;

/**
 Create a webview with the Blue Billywig player
 @param canvasSize Size of the view
 @param clipId Id of clip to play
 @param token Video token (24h valid) for protected video's, to use tokens contact sales@bluebillywig.com
        More information: http://bluebillywig.com/nl/blog/your-content-your-rules-how-control-video-content-accessibility
 @param setup Player setup
 */
- (id)createPlayer:(CGRect)canvasSize clipId:(NSString *)clipId token:(NSString *)token setup:(BBPlayerSetup *)setup;

@end
