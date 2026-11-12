import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @State private var period: Period = .daily
    /// Pages away from the current day, week, or month. 0 = current.
    @State private var offset = 0
    @State private var now = Date.now

    private var pageStart: Date {
        period.shift(period.start(of: now), by: offset)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Period", selection: $period) {
                    ForEach(Period.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                pageHeader

                TaskPage(period: period, start: pageStart)
            }
            .navigationTitle("Simple Tasks")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onChange(of: period) { offset = 0 }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
                .receive(on: DispatchQueue.main)
        ) { _ in refresh() }
        .task { refresh() }
    }

    private var pageHeader: some View {
        HStack {
            Button {
                offset -= 1
            } label: {
                Image(systemName: "chevron.left").padding()
            }
            .accessibilityLabel("Previous")

            Spacer()

            VStack(spacing: 2) {
                Text(period.label(for: pageStart))
                    .font(.headline)
                if offset != 0 {
                    Button(period.currentLabel) { offset = 0 }
                        .font(.caption)
                }
            }

            Spacer()

            Button {
                offset += 1
            } label: {
                Image(systemName: "chevron.right").padding()
            }
            .accessibilityLabel("Next")
        }
        .padding(.vertical, 4)
    }

    private func refresh() {
        now = .now
        CarryOver.run(in: context, now: now)
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
        let end = period.shift(start, by: 1)
        _tasks = Query(
            filter: #Predicate<TaskItem> {
                $0.periodRaw == raw && $0.periodStart >= start && $0.periodStart < end
            },
            sort: [SortDescriptor(\TaskItem.createdAt)]
        )
    }

    /// Urgent tasks first, then the rest, each in the order they were added.
    private var sortedTasks: [TaskItem] {
        tasks.filter(\.isUrgent) + tasks.filter { !$0.isUrgent }
    }

    var body: some View {
        let rows = sortedTasks
        List {
            ForEach(rows) { task in
                TaskRow(task: task, showsFlag: period == .daily)
                    .contextMenu {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            context.delete(task)
                        }
                    }
            }
            .onDelete { indexes in
                for index in indexes { context.delete(rows[index]) }
            }

            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)
                TextField("Add a task", text: $newTitle)
                    .focused($isAdding)
                    .submitLabel(.done)
                    .onSubmit(addTask)
            }

            if !tasks.isEmpty {
                let done = tasks.filter(\.isDone).count
                Text("\(done) of \(tasks.count) done")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    private func addTask() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        context.insert(TaskItem(title: title, period: period, periodStart: start))
        newTitle = ""
        isAdding = true
    }
}

/// One line with a check box.
struct TaskRow: View {
    @Bindable var task: TaskItem
    var showsFlag = false

    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggle) {
                Image(systemName: task.isDone ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(task.isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    .frame(width: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "Mark not done" : "Mark done")

            TextField("Task", text: $task.title, axis: .vertical)
                .strikethrough(task.isDone)
                .foregroundStyle(task.isDone ? .secondary : .primary)

            if showsFlag {
                Button {
                    task.isUrgent.toggle()
                } label: {
                    Image(systemName: task.isUrgent ? "flag.fill" : "flag")
                        .font(.title3)
                        .foregroundStyle(task.isUrgent ? AnyShapeStyle(.red) : AnyShapeStyle(.tertiary))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(task.isUrgent ? "Remove urgent flag" : "Mark urgent")
            }
        }
    }

    private func toggle() {
        task.isDone.toggle()
        task.completedAt = task.isDone ? .now : nil
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
