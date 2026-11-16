# Simple Todo — Development Record (iOS)

Last updated: November 16, 2026

---

## 1. App basics

| Item | Value |
|---|---|
| App Store name | Simple Todo: Daily Task |
| Home-screen name | Simple Todo |
| Older name | Simple Tasks (taken on the App Store, not used) |
| Studio | Journipod |
| Platforms | iPhone, iPad, Mac (native). No Apple Watch. |
| Minimum system | iOS / iPadOS 17, macOS 14 |
| Version | 1.0 (build 20 submitted) |
| Category | Productivity |
| Languages | English, Traditional Chinese (Taiwan) |
| Accent color | Orange #E87A4A |
| App icon | Design D, "day page" |

## 2. IDs

| Item | Value |
|---|---|
| Bundle ID | com.hu921.simpletasks |
| iCloud container | iCloud.com.hu921.simpletasks |
| Tip (small) | com.hu921.simpletasks.tip.small — $0.99 |
| Tip (medium) | com.hu921.simpletasks.tip.medium — $2.99 |
| Tip (large) | com.hu921.simpletasks.tip.large — $4.99 |
| Tip type | Consumable. Tips unlock nothing. |
| Code (GitHub) | https://github.com/hu921/tasklist-ios |

## 3. Accounts

- Apple Developer account: active since November 12, 2026.
- Version 1 ships under Sara's individual Apple account.
- Journipod is not a registered business yet.
- Plan: form an LLC, get a D-U-N-S number, then ask Apple Support to change the account to an organization.
- Paid Apps agreement: Active (bank and W-9 done). To check: bank currency showed UGX; it should be USD.
- EU: skipped for version 1 ("not a trader", so no home address is made public).

## 4. Support and links

| Item | Value |
|---|---|
| Support email | support.simpletodo@gmail.com |
| Privacy Policy | https://sites.google.com/view/simpletodo-journipod/privacy-policy |
| Support page | https://sites.google.com/view/simpletodo-journipod/support |
| Page text source | /mnt/project-files/simple-todo/app-store-pages.md |
| App Store text | /mnt/project-files/ios/app-store-text.md |

## 5. Privacy decisions

- No ads, ever.
- No analytics. No Firebase.
- No account or sign-in.
- Tasks are stored on the device and in the user's own iCloud. The developer cannot see them.
- Name (optional) is stored in the user's own iCloud.
- Settings (theme, font, size, language) stay on the device.
- Crash reports: Apple's built-in reports only (Xcode → Organizer).
- Marketing numbers: App Store Connect Analytics.
- App Store privacy label: "Customer Support" data from the wish form, not linked to the user. No tracking.
- Privacy manifest (PrivacyInfo.xcprivacy) is included.
- Test builds keep an on-device log (actions only, no task text). It is hidden in App Store builds.

## 6. iCloud (CloudKit) notes

- Tasks sync through CloudKit, private database.
- Wishes are saved to the CloudKit public database (type: Wish).
- After any change to the data model, deploy the schema to Production in the CloudKit Console.
- Schema deployed to Production: November 12 and 13, 2026 (the "movedAt" field added).
- Sync usually takes about 20 seconds. This timing is controlled by Apple.
- Do not use the Mac app run from Xcode for daily use. It uses the Development environment.

## 7. How to read wishes

1. Go to https://icloud.developer.apple.com and sign in.
2. Open **CloudKit Console** → container **iCloud.com.hu921.simpletasks**.
3. Click **Records**.
4. Choose **Production** (for TestFlight and App Store users).
5. Database: **Public Database**. Zone: **_defaultZone**.
6. Record type: **Wish**.
7. Click **Query Records**.

## 8. App Review history

| Date | Event |
|---|---|
| Nov 14, 2026 | iOS 1.0 (build 20) and 3 tips submitted. macOS 1.0 submitted. |
| Nov 14–15, 2026 | macOS 1.0: Guideline 2.1 "Information Needed". Apple asked for answers and a screen recording. |
| Nov 15, 2026 | Sara replied with a screen recording and answers, then resubmitted. |

Reply text: /mnt/project-files/simple-todo/app-review-reply.md
Use the same notes in "App Review Notes" for future versions.

## 9. Build and change timeline

| Date | PR | Build | Change |
|---|---|---|---|
| Nov 11 | — | — | First app version (Daily, Weekly, Monthly, carry-over, iCloud) |
| Nov 11 | #1 | — | Urgent flag on daily tasks |
| Nov 12 | #2 | 1 | Summary tab, About page, Roboto font, native Mac, rename to Simple Todo |
| Nov 12 | #3 | 2 | Build number update |
| Nov 12 | #4 | 3 | iCloud sync status; Mac sync fixed |
| Nov 12 | #5 | 4 | Sync error clears; iPhone keyboard closes |
| Nov 12 | #6 | 5 | Move tasks between Daily, Weekly, Monthly |
| Nov 12 | #7 | — | Move menu on long-press over task text |
| Nov 12 | #8 | — | Tasks with erased text are removed |
| Nov 13 | #9 | 8 | Test-only log, privacy manifest |
| Nov 13 | #10 | 9 | Save log to file |
| Nov 13 | #11 | 10 | Send a wish |
| Nov 13 | #12 | 11 | Tip jar |
| Nov 13 | #13 | 12 | Wish form saved to iCloud; Contact email |
| Nov 13 | #14 | 13 | "Wish sent" title; copyright line |
| Nov 13 | #15 | 15 | Settings page (theme, font, size, language); time zone handling |
| Nov 13 | #16 | 16 | Mac: same-width menu buttons |
| Nov 13 | #17 | 17 | Mac: same-width menu buttons (fix) |
| Nov 14 | #18 | 19 | Orange look, Profile name, new icon, Mac Settings window |
| Nov 14 | #19 | 20 | Faster Summary, carry-over once at launch, no log file in App Store builds |
| Nov 15 | #20 (draft) | 21 | Share a task via iMessage (not merged) |

"—" means not recorded.

## 10. Future plans

- **Share a task via iMessage** (PR #20, build 21, draft). Friend gets their own copy. Hold until 1.0 is approved. Then test if the link is tappable in Messages.
- **Website** showing how to use the app (journipod domain). Not started.
- **About page:** show developer name and website once the website exists.
- **Android app** (tasklist-android repo). Same features to be confirmed.
- **LLC + D-U-N-S**, then change Apple account to organization.
- **Social media:** Instagram + Threads account "simpletodo.app", created after App Store approval. Plan in /mnt/project-files/marketing/.
- **Reminders:** maybe later.
