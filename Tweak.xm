#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSArray<NSString *> *TXSelectors(void) {
    return @[
        // Siri
        @"handleSiriButtonDownEventFromSource:activationEvent:", @"handleSiriButtonUpEventFromSource:",
        // Media
        @"togglePlayPause", @"play", @"pause", @"changeTrack:", @"nextTrack", @"previousTrack", @"setNowPlayingApplicationIsPlaying:",
        // Volume and ringer
        @"_effectiveVolume", @"setActiveCategoryVolume:", @"volumeStepUp", @"volumeStepDown", @"setVolume:", @"setVolumeTo:",
        @"isRingerMuted", @"setRingerMuted:", @"setRingerMuted:withFeedback:reason:clientType:",
        // Screenshot / clipboard-adjacent system entry points only; no image or clipboard is read.
        @"takeScreenshot", @"saveScreenshotsWithCompletion:",
        // Explicit user-triggered system recording only.
        @"isRecording", @"startSystemRecordingWithMicrophoneEnabled:handler:", @"stopSystemRecording:",
        // VPN
        @"vpnActiveForSpecifier:", @"setVPNActive:"
    ];
}

static BOOL TXInterestingClassName(NSString *name) {
    NSString *lower=name.lowercaseString;
    return [lower containsString:@"hammer"] || [lower containsString:@"sirigesture"] || [lower containsString:@"squidextender"];
}

static void TXProbe(void) {
    NSMutableString *out=[NSMutableString stringWithString:@"[TouchXProbe v0.2] BEGIN: read-only Objective-C capability inventory\n"];
    unsigned count=0; Class *classes=objc_copyClassList(&count);
    for (NSString *selectorName in TXSelectors()) {
        SEL selector=NSSelectorFromString(selectorName); NSMutableArray<NSString *> *hits=[NSMutableArray array];
        for (unsigned i=0;i<count;i++) {
            Method method=class_getInstanceMethod(classes[i],selector); if(!method) continue;
            const char *types=method_getTypeEncoding(method);
            [hits addObject:[NSString stringWithFormat:@"%@ | %@",NSStringFromClass(classes[i]),types?@(types):@"?"]];
        }
        [out appendFormat:@"[TouchXProbe] %@ => %@\n",selectorName,hits.count?[hits componentsJoinedByString:@" ; "]:@"NOT_FOUND"];
    }
    NSMutableArray<NSString *> *thirdPartyClasses=[NSMutableArray array];
    for(unsigned i=0;i<count;i++){NSString *name=NSStringFromClass(classes[i]);if(TXInterestingClassName(name))[thirdPartyClasses addObject:name];}
    [thirdPartyClasses sortUsingSelector:@selector(compare:)];
    [out appendFormat:@"[TouchXProbe] third-party class-name presence => %@\n",thirdPartyClasses.count?[thirdPartyClasses componentsJoinedByString:@" ; "]:@"NONE"];
    free(classes);
    [out appendString:@"[TouchXProbe v0.2] END\n"];
    NSLog(@"%@",out);
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/jb/tmp" withIntermediateDirectories:YES attributes:nil error:nil];
    [out writeToFile:@"/var/jb/tmp/touchx-sq-interface-probe.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

%ctor { dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{ TXProbe(); }); }
