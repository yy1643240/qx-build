#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

static void TXLog(NSString *event) {
    NSString *line=[NSString stringWithFormat:@"%@ %@\n",[NSDate date],event];
    NSString *path=@"/var/jb/tmp/touchx-sq-action-trace.txt";
    NSFileHandle *f=[NSFileHandle fileHandleForWritingAtPath:path];
    if(!f){[[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];f=[NSFileHandle fileHandleForWritingAtPath:path];}
    [f seekToEndOfFile];[f writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];[f closeFile];NSLog(@"[TouchXTrace] %@",event);
}

static void TXHookVoid0(Class cls, SEL sel) {
    Method m=class_getInstanceMethod(cls,sel);if(!m)return;IMP old=method_getImplementation(m);NSString *name=[NSString stringWithFormat:@"%@ %@",NSStringFromClass(cls),NSStringFromSelector(sel)];
    IMP imp=imp_implementationWithBlock(^(id self){TXLog(name);((void(*)(id,SEL))old)(self,sel);});method_setImplementation(m,imp);
}
static void TXHookVoidBool(Class cls, SEL sel) {
    Method m=class_getInstanceMethod(cls,sel);if(!m)return;IMP old=method_getImplementation(m);NSString *name=[NSString stringWithFormat:@"%@ %@",NSStringFromClass(cls),NSStringFromSelector(sel)];
    IMP imp=imp_implementationWithBlock(^(id self,BOOL value){TXLog(name);((void(*)(id,SEL,BOOL))old)(self,sel,value);});method_setImplementation(m,imp);
}
static void TXHookVoidFloat(Class cls, SEL sel) {
    Method m=class_getInstanceMethod(cls,sel);if(!m)return;IMP old=method_getImplementation(m);NSString *name=[NSString stringWithFormat:@"%@ %@",NSStringFromClass(cls),NSStringFromSelector(sel)];
    IMP imp=imp_implementationWithBlock(^(id self,float value){TXLog(name);((void(*)(id,SEL,float))old)(self,sel,value);});method_setImplementation(m,imp);
}
static void TXHookFloat0(Class cls, SEL sel) {
    Method m=class_getInstanceMethod(cls,sel);if(!m)return;IMP old=method_getImplementation(m);NSString *name=[NSString stringWithFormat:@"%@ %@",NSStringFromClass(cls),NSStringFromSelector(sel)];
    IMP imp=imp_implementationWithBlock(^float(id self){TXLog(name);return ((float(*)(id,SEL))old)(self,sel);});method_setImplementation(m,imp);
}
static void TXHookVoidBlock(Class cls, SEL sel) {
    Method m=class_getInstanceMethod(cls,sel);if(!m)return;IMP old=method_getImplementation(m);NSString *name=[NSString stringWithFormat:@"%@ %@",NSStringFromClass(cls),NSStringFromSelector(sel)];
    IMP imp=imp_implementationWithBlock(^(id self,id block){TXLog(name);((void(*)(id,SEL,id))old)(self,sel,block);});method_setImplementation(m,imp);
}
static void TXHookRecordingStart(Class cls) {
    SEL sel=NSSelectorFromString(@"startSystemRecordingWithMicrophoneEnabled:handler:");Method m=class_getInstanceMethod(cls,sel);if(!m)return;IMP old=method_getImplementation(m);
    IMP imp=imp_implementationWithBlock(^(id self,BOOL microphone,id block){TXLog(@"RPScreenRecorder startSystemRecordingWithMicrophoneEnabled:handler:");((void(*)(id,SEL,BOOL,id))old)(self,sel,microphone,block);});method_setImplementation(m,imp);
}
static void TXInstallTrace(void) {
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/tmp/touchx-sq-action-trace.txt" error:nil];TXLog(@"BEGIN: selector-name-only trace; no parameters or return values are recorded");
    Class v=NSClassFromString(@"SBVolumeControl");TXHookVoidFloat(v,NSSelectorFromString(@"setActiveCategoryVolume:"));TXHookFloat0(v,NSSelectorFromString(@"volumeStepUp"));TXHookFloat0(v,NSSelectorFromString(@"volumeStepDown"));
    Class r=NSClassFromString(@"RPScreenRecorder");TXHookRecordingStart(r);TXHookVoidBlock(r,NSSelectorFromString(@"stopSystemRecording:"));
    Class vpn=NSClassFromString(@"VPNBundleController");TXHookVoidBool(vpn,NSSelectorFromString(@"setVPNActive:"));
    TXHookVoid0(NSClassFromString(@"SpringBoard"),NSSelectorFromString(@"takeScreenshot"));
    TXHookVoidBool(NSClassFromString(@"SBRingerControl"),NSSelectorFromString(@"setRingerMuted:"));
    TXLog(@"READY: trigger one SQ base action at a time, then export this file");
}
%ctor {dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{TXInstallTrace();});}
