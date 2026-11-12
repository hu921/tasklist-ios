import SwiftUI
import SwiftData

/// Done vs. not done for one week.
struct WeekStat: Identifiable {
    let start: Date
    let done: Int
    let notDone: Int

    var id: Date { start }
    var total: Int { done + notDone }
}

enum WeeklySummary {
    /// One entry per week, newest first, from the week of the oldest task to this week.
    /// - done: tasks checked off during that week.
    /// - not done: tasks that existed during that week and were still open at its end.
    static func compute(tasks: [TaskItem], now: Date = .now, calendar: Calendar = .current) -> [WeekStat] {
        guard let oldest = tasks.map(\.createdAt).min() else { return [] }
        let firstWeek = Period.weekly.start(of: oldest, calendar: calendar)
        var week = Period.weekly.start(of: now, calendar: calendar)
        var stats: [WeekStat] = []

        while week >= firstWeek {
            let end = Period.weekly.shift(week, by: 1, calendar: calendar)
            var done = 0
            var notDone = 0
            for task in tasks where task.createdAt < end {
                if task.isDone, let completed = task.completedAt {
                    if completed >= week && completed < end {
                        done += 1
                    } else if completed >= end {
                        notDone += 1
                    }
                } else if !task.isDone {
                    notDone += 1
                }
            }
            if done + notDone > 0 {
                stats.append(WeekStat(start: week, done: done, notDone: notDone))
            }
            week = Period.weekly.shift(week, by: -1, calendar: calendar)
        }
        return stats
    }
}

struct SummaryView: View {
    @Query private var tasks: [TaskItem]

    var body: some View {
        let weeks = WeeklySummary.compute(tasks: tasks)
        let totalDone = tasks.filter(\.isDone).count
        let perfectWeeks = weeks.filter { $0.notDone == 0 }.count

        List {
            HStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(totalDone) tasks done")
                        .font(.appTitle)
                    Text("\(perfectWeeks) \(perfectWeeks == 1 ? "week" : "weeks") with everything done")
                        .font(.appFootnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)

            if weeks.isEmpty {
                Text("No tasks yet.")
                    .foregroundStyle(.secondary)
            } else {
                Section {
                    ForEach(weeks) { WeekRow(stat: $0) }
                } header: {
                    Text("By week").font(.appFootnote)
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct WeekRow: View {
    let stat: WeekStat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(Period.weekly.label(for: stat.start))
                    .font(.appHeadline)
                Spacer()
                if stat.notDone == 0 {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .accessibilityLabel("Everything done")
                }
            }
            ProgressView(value: Double(stat.done), total: Double(max(stat.total, 1)))
            HStack {
                Text("\(stat.done) done")
                Spacer()
                Text("\(stat.notDone) not done")
                    .foregroundStyle(.secondary)
            }
            .font(.appFootnote)
        }
        .padding(.vertical, 4)
    }
}
