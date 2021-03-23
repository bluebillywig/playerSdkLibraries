//
//  ViewController.h
//  BB Webview
//
//  Created by Floris Groenendijk on 4/8/13.
//  Copyright (c) 2013 Floris Groenendijk. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <Foundation/NSJSONSerialization.h>
#import "BBPlayer.h"

@interface BBViewController : UIViewController<BBPlayerEventDelegate>

@property (weak, nonatomic) BBPlayer *bbPlayerWebView;

@property (weak, nonatomic) IBOutlet UIView *playerWebViewPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *loadClipButton;

@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyButton;


@property (weak, nonatomic) IBOutlet UIButton *attachTimeupdateButton;
@property (weak, nonatomic) IBOutlet UIButton *removeTimeupdateButton;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (retain, nonatomic) WKWebView *wkWebView;

@property (strong, nonatomic) IBOutlet UILabel *componentVersion;

@property (strong, nonatomic) Playout *playout;

@end
