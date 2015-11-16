//
//  NBMLog.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 20/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//
#import "CocoaLumberjack.h"

#ifdef DEBUG
    static const int ddLogLevel = DDLogLevelVerbose;
    //Simple log macro
    #define DLog(s,...) NSLog((@"[%s] " s),__func__,## __VA_ARGS__);
#else
    static const int ddLogLevel = 0;
    //Log only in debug mode
    #define DLog(...)
#endif



