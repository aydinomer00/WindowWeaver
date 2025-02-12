import AppKit
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        installEventHandler()

        // Initialize keyboard shortcuts
        _ = KeyboardShortcuts.shared
    }
}

private extension AppDelegate {
    func installEventHandler() {
        // Define the event type for hot key pressed events
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, _ -> OSStatus in
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                if status == noErr {
                    if let callback = HotKeyCallbacks.shared.callbacks[Int(hotKeyID.id)] {
                        DispatchQueue.main.async {
                            callback()
                        }
                    }
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
}
