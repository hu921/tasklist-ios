import SwiftUI
import SwiftData
import Combine

/// The four tabs at the top.
enum AppTab: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, summary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: L("Daily")
        case .weekly: L("Weekly")
        case .monthly: L("Monthly")
        case .summary: L("Summary")
        }
    }

    var period: Period? {
        switch self {
        case .daily: .daily
        case .weekly: .weekly
        case .monthly: .monthly
        case .summary: nil
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @State private var tab: AppTab = .daily
    /// Pages away from the current day, week, or month. 0 = current.
    @State private var offset = 0
    @State private var now = Date.now
    @State private var showsAbout = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabSelector(selection: $tab)
                    .padding(.horizontal)
                    .padding(.top, 8)

                if let period = tab.period {
                    let pageStart = period.shift(period.start(of: now), by: offset)
                    pageHeader(period: period, pageStart: pageStart)
                    TaskPage(period: period, start: pageStart)
                } else {
                    SummaryView()
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Simple Todo")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Simple Todo").font(.appHeadline)
                }
            }
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showsAbout = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(L("Settings"))
                }
            }
            .sheet(isPresented: $showsAbout) {
                AboutView()
            }
        }
        .font(.appBody)
        .preferredColorScheme(AppSettings.shared.theme.colorScheme)
        .onChange(of: tab) { offset = 0 }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
                .receive(on: DispatchQueue.main)
        ) { _ in refresh() }
        // Travel: the device's time zone changed, so "today" may have changed.
        .onReceive(
            NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)
                .receive(on: DispatchQueue.main)
        ) { _ in
            AppLog.log("time zone changed", TimeZone.current.identifier)
            refresh()
        }
        .task { refresh() }
    }

    private func pageHeader(period: Period, pageStart: Date) -> some View {
        HStack {
            Button {
                offset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(L("Previous"))

            Spacer()

            VStack(spacing: 2) {
                Text(period.label(for: pageStart))
                    .font(.appHeadline)
                if offset != 0 {
                    Button(period.currentLabel) { offset = 0 }
                        .buttonStyle(.borderless)
                        .font(.appCaption)
                }
            }

            Spacer()

            Button {
                offset += 1
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(L("Next"))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private func refresh() {
        // Always use the device's current time zone.
        NSTimeZone.resetSystemTimeZone()
        now = .now
        CarryOver.run(in: context, now: now)
    }
}

/// Daily / Weekly / Monthly / Summary buttons, drawn in Roboto.
struct TabSelector: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selection == tab
                Button {
                    selection = tab
                } label: {
                    Text(tab.title)
                        .font(.appTab)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 7).fill(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color.secondary.opacity(0.15)))
    }
}

/// The tasks on one page (one day, week, or month).
struct TaskPage: View {
    let period: Period
    let start: Date

    @Environment(\.modelContext) private var context
    @Query private var tasks: [TaskItem]
    @State private var newTitle = ""
    @FocusState private var isAdding: Bool

    init(period: Period, start: Date) {
        self.period = period
        self.start = start
        let raw = period.rawValue
        // A little wider than the page, to include tasks saved in another time zone.
        // `sortedTasks` keeps only the ones that belong to this page.
        let from = start.addingTimeInterval(-13 * 3600)
        let to = period.shift(start, by: 1).addingTimeInterval(13 * 3600)
        _tasks = Query(
            filter: #Predicate<TaskItem> {
                $0.periodRaw == raw && $0.periodStart >= from && $0.periodStart < to
            },
            sort: [SortDescriptor(\TaskItem.createdAt)]
        )
    }

    /// Urgent tasks first, then the rest, each in the order they were added or moved here.
    private var pageTasks: [TaskItem] {
        tasks.filter { period.page(of: $0.periodStart) == start }
    }

    private var sortedTasks: [TaskItem] {
        let ordered = pageTasks.sorted { $0.listOrder < $1.listOrder }
        return ordered.filter(\.isUrgent) + ordered.filter { !$0.isUrgent }
    }

    var body: some View {
        let rows = sortedTasks
        List {
            ForEach(rows) { task in
                TaskRow(task: task, showsFlag: period == .daily)
                    .contextMenu {
                        ForEach(Period.allCases.filter { $0 != period }) { target in
                            Button(L("Move to %@", target.title), systemImage: "arrow.right") {
                                task.move(to: target)
                            }
                        }
                        Divider()
                        Button(L("Delete"), systemImage: "trash", role: .destructive) {
                            AppLog.log("task deleted", period.rawValue)
                            context.delete(task)
                        }
                    }
            }
            .onDelete { indexes in
                for index in indexes {
                    AppLog.log("task deleted", period.rawValue)
                    context.delete(rows[index])
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)
                TextField(L("Add a task"), text: $newTitle)
                    .focused($isAdding)
                    .submitLabel(.done)
                    .onSubmit(addTask)
            }

            if !rows.isEmpty {
                let done = rows.filter(\.isDone).count
                Text(L("%lld of %lld done", done, rows.count))
                    .font(.appFootnote)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        // Dragging the list down hides the keyboard.
        .scrollDismissesKeyboard(.immediately)
    }

    private func addTask() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            // Return on an empty line hides the keyboard.
            isAdding = false
            return
        }
        context.insert(TaskItem(title: title, period: period, periodStart: start))
        AppLog.log("task added", period.rawValue)
        newTitle = ""
        isAdding = true
    }
}

/// One line with a check box.
struct TaskRow: View {
    @Bindable var task: TaskItem
    var showsFlag = false
    @Environment(\.modelContext) private var context
    /// The title shows as plain text, so a long-press (right-click on Mac)
    /// opens the task's Move/Delete menu. Tapping it switches to editing.
    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggle) {
                Image(systemName: task.isDone ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(task.isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    .frame(width: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? L("Mark not done") : L("Mark done"))

            if isEditing {
                TextField(L("Task"), text: $task.title, axis: .vertical)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                    .onAppear { isFocused = true }
                    .onChange(of: isFocused) { _, focused in
                        guard !focused else { return }
                        isEditing = false
                        // Erasing all the text removes the task.
                        if task.isBlank {
                            AppLog.log("empty task removed")
                            context.delete(task)
                        }
                    }
                    .onChange(of: task.title) { _, title in
                        // Return finishes editing instead of starting a new line.
                        guard title.contains("\n") else { return }
                        task.title = title.replacingOccurrences(of: "\n", with: "")
                        isFocused = false
                    }
            } else {
                Text(task.title.isEmpty ? " " : task.title)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { isEditing = true }
            }

            if showsFlag {
                Button {
                    task.isUrgent.toggle()
                    AppLog.log("flag", task.isUrgent ? "on" : "off")
                } label: {
                    Image(systemName: task.isUrgent ? "flag.fill" : "flag")
                        .font(.title3)
                        .foregroundStyle(task.isUrgent ? AnyShapeStyle(.red) : AnyShapeStyle(.tertiary))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(task.isUrgent ? L("Remove urgent flag") : L("Mark urgent"))
            }
        }
    }

    private func toggle() {
        task.isDone.toggle()
        task.completedAt = task.isDone ? .now : nil
        AppLog.log(task.isDone ? "task done" : "task not done")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
