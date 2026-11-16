# Simple Todo — 開發紀錄（iOS）

最後更新：2026 年 11 月 16 日

---

## 1. App 基本資料

| 項目 | 內容 |
|---|---|
| App Store 名稱 | Simple Todo: Daily Task |
| 主畫面名稱 | Simple Todo |
| 舊名稱 | Simple Tasks（App Store 已被使用，未採用） |
| 工作室 | Journipod |
| 平台 | iPhone、iPad、Mac（原生）。不支援 Apple Watch。 |
| 最低系統 | iOS / iPadOS 17、macOS 14 |
| 版本 | 1.0（已送審 build 20） |
| 類別 | 效率（Productivity） |
| 語言 | English、繁體中文（台灣） |
| 主色 | 橘色 #E87A4A |
| App 圖示 | 設計 D「每日頁面」 |

## 2. 識別碼

| 項目 | 內容 |
|---|---|
| Bundle ID | com.hu921.simpletasks |
| iCloud 容器 | iCloud.com.hu921.simpletasks |
| 贊助（小） | com.hu921.simpletasks.tip.small — $0.99 |
| 贊助（中） | com.hu921.simpletasks.tip.medium — $2.99 |
| 贊助（大） | com.hu921.simpletasks.tip.large — $4.99 |
| 贊助類型 | 消耗型。不會解鎖任何功能。 |
| 程式碼（GitHub） | https://github.com/hu921/tasklist-ios |

## 3. 帳號

- Apple 開發者帳號：2026 年 11 月 12 日啟用。
- 第 1 版以 Sara 的個人 Apple 帳號上架。
- Journipod 尚未登記為公司。
- 計畫：成立 LLC，申請 D-U-N-S 編號，再請 Apple 客服將帳號改為組織帳號。
- 付費 App 協議：已生效（銀行與 W-9 已完成）。待確認：銀行幣別顯示 UGX，應為 USD。
- 歐盟：第 1 版略過（選擇「非交易商」，不公開住家地址）。

## 4. 客服與連結

| 項目 | 內容 |
|---|---|
| 客服 Email | support.simpletodo@gmail.com |
| 隱私權政策 | https://sites.google.com/view/simpletodo-journipod/privacy-policy |
| 支援頁面 | https://sites.google.com/view/simpletodo-journipod/support |
| 頁面文字來源 | /mnt/project-files/simple-todo/app-store-pages.md |
| App Store 文字 | /mnt/project-files/ios/app-store-text.md |

## 5. 隱私決定

- 永遠沒有廣告。
- 沒有數據分析。不使用 Firebase。
- 不需帳號或登入。
- 任務存在裝置和使用者自己的 iCloud。開發者看不到。
- 名字（選填）存在使用者自己的 iCloud。
- 設定（主題、字體、大小、語言）只存在裝置上。
- 當機報告：只用 Apple 內建報告（Xcode → Organizer）。
- 行銷數據：App Store Connect 分析。
- App Store 隱私標籤：許願表單的「客戶支援」資料，不連結到使用者。不追蹤。
- 已加入隱私清單（PrivacyInfo.xcprivacy）。
- 測試版本有裝置上的記錄（只記操作，不含任務內容）。App Store 版本不顯示。

## 6. iCloud（CloudKit）說明

- 任務透過 CloudKit 私人資料庫同步。
- 願望存在 CloudKit 公開資料庫（類型：Wish）。
- 資料結構有任何變更後，要在 CloudKit Console 把結構部署到 Production。
- 已部署到 Production：2026 年 11 月 12 日和 13 日（新增「movedAt」欄位）。
- 同步通常約 20 秒。時間由 Apple 控制。
- 不要把從 Xcode 執行的 Mac App 拿來日常使用。它用的是 Development 環境。

## 7. 如何查看願望

1. 前往 https://icloud.developer.apple.com 並登入。
2. 打開 **CloudKit Console** → 容器 **iCloud.com.hu921.simpletasks**。
3. 點 **Records**。
4. 選 **Production**（TestFlight 和 App Store 使用者）。
5. 資料庫：**Public Database**。區域：**_defaultZone**。
6. 記錄類型：**Wish**。
7. 點 **Query Records**。

## 8. App 審查紀錄

| 日期 | 事件 |
|---|---|
| 2026/11/14 | iOS 1.0（build 20）和 3 項贊助送審。macOS 1.0 送審。 |
| 2026/11/14–15 | macOS 1.0：準則 2.1「需要資訊」。Apple 要求回答問題並提供螢幕錄影。 |
| 2026/11/15 | Sara 回覆螢幕錄影和答案，並重新送審。 |

回覆內容：/mnt/project-files/simple-todo/app-review-reply.md
之後的版本，同樣內容放在「App 審查備註」。

## 9. 版本與變更時間軸

| 日期 | PR | Build | 變更 |
|---|---|---|---|
| 11/11 | — | — | 第一版（每日、每週、每月、自動移動、iCloud） |
| 11/11 | #1 | — | 每日任務緊急旗標 |
| 11/12 | #2 | 1 | 總結分頁、關於頁面、Roboto 字體、原生 Mac、改名 Simple Todo |
| 11/12 | #3 | 2 | 更新 build 編號 |
| 11/12 | #4 | 3 | iCloud 同步狀態；修正 Mac 同步 |
| 11/12 | #5 | 4 | 同步錯誤會清除；iPhone 鍵盤可收起 |
| 11/12 | #6 | 5 | 任務可在每日、每週、每月之間移動 |
| 11/12 | #7 | — | 長按任務文字顯示移動選單 |
| 11/12 | #8 | — | 文字刪光的任務會被移除 |
| 11/13 | #9 | 8 | 測試用記錄、隱私清單 |
| 11/13 | #10 | 9 | 將記錄存成檔案 |
| 11/13 | #11 | 10 | 許個願 |
| 11/13 | #12 | 11 | 贊助 |
| 11/13 | #13 | 12 | 許願表單存到 iCloud；聯絡 Email |
| 11/13 | #14 | 13 | 「已送出」標題；版權文字 |
| 11/13 | #15 | 15 | 設定頁（主題、字體、大小、語言）；時區處理 |
| 11/13 | #16 | 16 | Mac：選單按鈕同寬 |
| 11/13 | #17 | 17 | Mac：選單按鈕同寬（修正） |
| 11/14 | #18 | 19 | 橘色外觀、個人名字、新圖示、Mac 設定視窗 |
| 11/14 | #19 | 20 | 總結更快、啟動時只移動一次、App Store 版本無記錄檔 |
| 11/15 | #20（草稿） | 21 | 透過 iMessage 分享任務（尚未合併） |

「—」表示沒有紀錄。

## 10. 未來計畫

- **透過 iMessage 分享任務**（PR #20，build 21，草稿）。朋友會收到自己的副本。等 1.0 通過審查後再處理，並測試訊息中的連結能否點擊。
- **網站**：說明 App 使用方式（journipod 網域）。尚未開始。
- **關於頁面**：網站完成後，顯示開發者名稱和網站。
- **Android App**（tasklist-android）。功能待確認。
- **LLC + D-U-N-S**，之後將 Apple 帳號改為組織帳號。
- **社群媒體**：Instagram + Threads 帳號「simpletodo.app」，App Store 通過後建立。計畫在 /mnt/project-files/marketing/。
- **提醒功能**：之後再考慮。
