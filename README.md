# Simple Tasks (iOS)

A simple booklet-style to-do list. Daily, weekly, and monthly pages with check boxes.

## Features
- Daily, Weekly, and Monthly pages. Arrows move to past or future pages.
- Tap the box to check off a task. Swipe left to delete.
- Unfinished tasks move to the current day, week, or month automatically.
- Syncs through iCloud. No sign-in.

## Requirements
- Mac with Xcode 15 or newer (free from the Mac App Store)
- iOS / iPadOS 17 or newer

## Run it
1. Open `SimpleTasks.xcodeproj` in Xcode.
2. Pick an iPhone simulator at the top and press Run (⌘R).

## Run on your iPhone or iPad
1. Xcode → Settings → Accounts → add your Apple ID.
2. Select the **SimpleTasks** target → **Signing & Capabilities** → choose your Team.
3. Connect the device, select it at the top, and press Run.

### iCloud sync
iCloud needs an active (paid) Apple Developer account.
Until it is active, remove the **iCloud** and **Push Notifications** capabilities in
**Signing & Capabilities** to run on a device. The app then saves on the device only.

Once the account is active, keep the capabilities. In **iCloud**, check the container
`iCloud.com.hu921.simpletasks` (click **+** to create it if missing).
Sign in to the same iCloud account on each device.
