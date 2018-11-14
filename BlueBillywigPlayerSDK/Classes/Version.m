//
//  Version.m
//  BB Webview
//
//  Created by Floris Groenendijk on 03/07/15.
//  Copyright (c) 2014 Floris Groenendijk. All rights reserved.
//

#import "Version.h"


@implementation Version{}

- (NSString*)getVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

@end


