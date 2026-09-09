# Touch X SQ Interface Probe v0.2

**Temporary, read-only, Rootless-only SpringBoard runtime inventory.**

## Scope

The probe performs one inventory run two seconds after SpringBoard starts. It only enumerates Objective-C classes already loaded in SpringBoard, and for a fixed allowlist of system selectors writes `class name | Objective-C type encoding` to:

`/var/jb/tmp/touchx-sq-interface-probe.txt`

It also records only class-name presence for `Hammer`, `SiriGesture`, and `SquidExtender` prefixes.

It never invokes, hooks, replaces or swizzles any method. It does not read SquidGesture settings, action tables, source, resources, license/activation state, arguments, return values, screenshots, clipboard or microphone data.

## Build — standard Rootless only

```sh
make clean THEOS_PACKAGE_SCHEME=rootless
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless ARCHS=arm64e
```

Expected payload: `/var/jb/Library/MobileSubstrate/DynamicLibraries/TouchXSQInterfaceProbe.*`

## Use

1. Install this package only on the authorized standard Rootless test device.
2. Respring once.
3. Read `/var/jb/tmp/touchx-sq-interface-probe.txt`.
4. Uninstall immediately after exporting the text:

```sh
dpkg -r com.6866.touchx.sqinterfaceprobe
killall -9 SpringBoard
```

No background loop, timer, network traffic, settings, preference bundle, or persistent daemon is included.
