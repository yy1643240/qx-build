#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

static NSArray<NSString *> *TXSelectors(void) {
    return @[@"_effectiveVolume", @"setActiveCategoryVolume:", @"volumeStepUp", @"volumeStepDown", @"startSystemRecordingWithMicrophoneEnabled:handler:", @"stopSystemRecording:", @"vpnActiveForSpecifier:", @"_setVPNActive:", @"setVPNActive:", @"takeScreenshot"];
}

static void TXProbe(void) {
    NSMutableString *out=[NSMutableString stringWithString:@"[TouchXProbe] BEGIN: read-only Objective-C capability inventory\n"];
    unsigned count=0;Class *classes=objc_copyClassList(&count);
    for(NSString *selectorName in TXSelectors()) {
        SEL selector=NSSelectorFromString(selectorName); NSMutableArray *hits=[NSMutableArray array];
        for(unsigned i=0;i<count;i++) { Class cls=classes[i]; Method method=class_getInstanceMethod(cls,selector); if(!method)continue; const char *types=method_getTypeEncoding(method); [hits addObject:[NSString stringWithFormat:@"%@ | %@",NSStringFromClass(cls),types?@(types):@"?"]]; }
        [out appendFormat:@"[TouchXProbe] %@ => %@\n",selectorName,hits.count?[hits componentsJoinedByString:@" ; "]:@"NOT_FOUND"];
    }
    free(classes);[out appendString:@"[TouchXProbe] END\n"];NSLog(@"%@",out);
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/jb/tmp" withIntermediateDirectories:YES attributes:nil error:nil];[out writeToFile:@"/var/jb/tmp/touchx-sq-interface-probe.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
%ctor { dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{TXProbe();}); }
