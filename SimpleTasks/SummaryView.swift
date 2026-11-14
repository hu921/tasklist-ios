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
        let thisWeek = Period.weekly.start(of: now, calendar: calendar)

        // All weeks from the oldest task to this week, oldest first.
        var weeks: [Date] = []
        var index: [Date: Int] = [:]
        var week = firstWeek
        while week <= thisWeek {
            index[week] = weeks.count
            weeks.append(week)
            week = Period.weekly.shift(week, by: 1, calendar: calendar)
        }
        func slot(_ date: Date) -> Int? { index[Period.weekly.start(of: date, calendar: calendar)] }

        // One pass over the tasks. A task counts as "not done" in every week from
        // the week it was added until the week before it was checked off (or this
        // week, if still open). `open` marks where that run starts and stops.
        var done = [Int](repeating: 0, count: weeks.count)
        var open = [Int](repeating: 0, count: weeks.count + 1)
        for task in tasks {
            guard let first = slot(task.createdAt) else { continue }
            if task.isDone {
                guard let completed = task.completedAt else { continue }
                let doneWeek = slot(completed) ?? (completed > now ? weeks.count : -1)
                if doneWeek < weeks.count, doneWeek >= first { done[doneWeek] += 1 }
                if doneWeek > first {
                    open[first] += 1
                    open[min(doneWeek, weeks.count)] -= 1
                }
            } else {
                open[first] += 1
                open[weeks.count] -= 1
            }
        }

        var stats: [WeekStat] = []
        var running = 0
        for i in weeks.indices {
            running += open[i]
            if done[i] + running > 0 {
                stats.append(WeekStat(start: weeks[i], done: done[i], notDone: running))
            }
        }
        return stats.reversed()
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
                    Text(L("%lld tasks done", totalDone))
                        .font(.appTitle)
                    Text(perfectWeeks == 1 ? L("1 week with everything done") : L("%lld weeks with everything done", perfectWeeks))
                        .font(.appFootnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)

            if weeks.isEmpty {
                Text(L("No tasks yet."))
                    .foregroundStyle(.secondary)
            } else {
                Section {
                    ForEach(weeks) { WeekRow(stat: $0) }
                } header: {
                    Text(L("By week")).font(.appFootnote)
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
                        .accessibilityLabel(L("Everything done"))
                }
            }
            ProgressView(value: Double(stat.done), total: Double(max(stat.total, 1)))
            HStack {
                Text(L("%lld done", stat.done))
                Spacer()
                Text(L("%lld not done", stat.notDone))
                    .foregroundStyle(.secondary)
            }
            .font(.appFootnote)
        }
        .padding(.vertical, 4)
    }
}
