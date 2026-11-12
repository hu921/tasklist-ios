# Simple Todo (iOS)

App Store name: "Simple Todo: Daily task". Studio: journipod.

A simple booklet-style to-do list. Daily, weekly, and monthly pages with check boxes.

## Features
- Daily, Weekly, and Monthly pages. Arrows move to past or future pages.
- Tap the box to check off a task. Swipe left to delete.
- Daily tasks: tap the flag to mark Urgent (red). Urgent tasks show at the top.
- Unfinished tasks move to the current day, week, or month automatically.
- Summary tab: tasks done vs. not done for each week, with a star for weeks where everything was done.
- Roboto font (Apache 2.0, in `SimpleTasks/Fonts`).
- About page (ⓘ button): version and developer info.
- Syncs through iCloud. No sign-in.

## Requirements
- Mac with Xcode 15 or newer (free from the Mac App Store)
- iOS / iPadOS 17 or newer, macOS 14 or newer (native Mac app)

## Run it
1. Open `SimpleTasks.xcodeproj` in Xcode.
2. Pick an iPhone simulator, or **My Mac**, at the top and press Run (⌘R).

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

## TestFlight (iPhone, iPad, Mac)
Needs an active Apple Developer account.
1. In App Store Connect, create the app with bundle ID `com.hu921.simpletasks` (iOS and macOS).
2. In Xcode, pick **Any iOS Device**, then **Product → Archive** → **Distribute App** → **TestFlight & App Store**.
3. Pick **Any Mac**, then repeat step 2.
4. In App Store Connect → TestFlight, add yourself as a tester.
