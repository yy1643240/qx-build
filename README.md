# Touch X SQ Action Trace v0.3

## Authorized temporary trace

Standard Rootless-only, arm64e, SpringBoard-only probe for the user-authorized iOS 16.6 device. It records only the selector name and timestamp of fixed system action methods when the user manually triggers a SquidGesture Pro action.

Output: `/var/jb/tmp/touchx-sq-action-trace.txt`

## Explicit data boundaries

- No SquidGesture Pro code, resources, preferences, action list, license or activation data.
- No method arguments or return values: no microphone boolean, VPN state, volume level, screenshot, clipboard, media metadata or personal data.
- No network access, daemon, timer loop, UI, persistence, or calls initiated by the probe.
- The only method replacements are the allowlisted system action methods and each replacement immediately forwards to the original IMP with the verified matching type signature.

## Build

```sh
make clean THEOS_PACKAGE_SCHEME=rootless
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless ARCHS=arm64e
```

## Test protocol

1. Install the package to the authorized Rootless device, then respring once.
2. Wait two seconds. The output begins with `READY`.
3. In SquidGesture Pro, manually trigger **one** action, wait two seconds, then trigger the next. Suggested order: volume up, volume down, silent, screenshot, recording start/stop, VPN toggle.
4. Export only the trace file above.
5. Remove immediately after export and respring:

```sh
dpkg -r com.6866.touchx.sqactiontrace
killall -9 SpringBoard
```

Uninstall plus respring removes all in-memory replacements; no other device files are created except the trace text file, which may then be deleted.
