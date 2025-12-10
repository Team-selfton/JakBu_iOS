import WidgetKit
import SwiftUI
import Combine

// MARK: - Data Models
// 위젯 타겟이 Todo 모델에 접근할 수 있도록 임시로 모델을 여기에 복사합니다.
// 가장 좋은 방법은 이 모델들을 별도의 프레임워크로 분리하거나,
// 메인 앱과 위젯 타겟 모두에 이 파일들을 포함시키는 것입니다.
struct Todo: Codable, Identifiable {
    let id: Int
    let title: String
    let date: String
    let status: TodoStatus
}

enum TodoStatus: String, Codable {
    case TODO
    case DONE
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry(date: Date(), todoItems: [
            Todo(id: 1, title: "운동하기", date: "2025-12-10", status: .TODO)
        ], doneItems: [
            Todo(id: 2, title: "코딩 공부", date: "2025-12-10", status: .DONE)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> ()) {
        fetchTodoEntry { entry in
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> ()) {
        fetchTodoEntry { entry in
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchTodoEntry(completion: @escaping (TodoWidgetEntry) -> ()) {
        // SharedDataManager를 통해 실제 데이터 로드
        let sharedManager = WidgetSharedDataManager.shared
        let allTodos = sharedManager.loadTodos()

        print("📊 [Widget] 전체 로드된 할일: \(allTodos.count)개")

        let todoItems = allTodos.filter { $0.status == .TODO }
        let doneItems = allTodos.filter { $0.status == .DONE }

        print("📊 [Widget] TODO: \(todoItems.count)개, DONE: \(doneItems.count)개")

        let entry = TodoWidgetEntry(date: Date(), todoItems: todoItems, doneItems: doneItems)
        completion(entry)
    }
}

struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let todoItems: [Todo]
    let doneItems: [Todo]
}

// MARK: - Views

struct JakBuWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        if entry.todoItems.isEmpty && entry.doneItems.isEmpty {
            EmptyStateView()
        } else {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            default:
                MediumWidgetView(entry: entry)
            }
        }
    }
}

struct SmallWidgetView: View {
    var entry: TodoWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            WidgetHeaderView()
            
            Spacer()

            ProgressCircleView(
                total: entry.todoItems.count + entry.doneItems.count,
                completed: entry.doneItems.count
            )
            
            Spacer()
            
            Text("남은 할일: \(entry.todoItems.count)개")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    var entry: TodoWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeaderView()
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("할일")
                        .font(.caption).bold().foregroundColor(.secondary)
                    ForEach(entry.todoItems.prefix(3)) { todo in
                        TodoRow(todo: todo)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("한일")
                        .font(.caption).bold().foregroundColor(.secondary)
                    ForEach(entry.doneItems.prefix(2)) { todo in
                        TodoRow(todo: todo)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}


struct WidgetHeaderView: View {
    var body: some View {
        HStack {
            Text("작부")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Spacer()
            Image(systemName: "paperplane.fill")
                .foregroundColor(.blue)
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: todo.status == .DONE ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.status == .DONE ? .green : .blue)
                .font(.subheadline)
            
            Text(todo.title)
                .font(.subheadline)
                .strikethrough(todo.status == .DONE, color: .secondary)
                .foregroundColor(todo.status == .DONE ? .secondary : .primary)
        }
    }
}

struct ProgressCircleView: View {
    let total: Int
    let completed: Int
    
    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.2)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            VStack {
                Text("\(completed)/\(total)")
                    .font(.headline)
                    .bold()
                Text("완료")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct EmptyStateView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("오늘의 모든 할일을 완료했어요!")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("새로운 할일을 추가해보세요.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct JakBuWidget: Widget {
    let kind: String = "JakBuWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JakBuWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("작부 위젯")
        .description("오늘의 할일을 위젯에서 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    JakBuWidget()
} timeline: {
    TodoWidgetEntry(date: .now, todoItems: [
        Todo(id: 1, title: "운동하기", date: "2025-12-10", status: .TODO),
        Todo(id: 2, title: "책읽기", date: "2025-12-10", status: .TODO)
    ], doneItems: [
        Todo(id: 3, title: "코딩 공부", date: "2025-12-10", status: .DONE)
    ])
}

#Preview(as: .systemSmall) {
    JakBuWidget()
} timeline: {
    TodoWidgetEntry(date: .now, todoItems: [
        Todo(id: 1, title: "운동하기", date: "2025-12-10", status: .TODO),
        Todo(id: 2, title: "책읽기", date: "2025-12-10", status: .TODO)
    ], doneItems: [
        Todo(id: 3, title: "코딩 공부", date: "2025-12-10", status: .DONE)
    ])
}

#Preview(as: .systemSmall) {
    JakBuWidget()
} timeline: {
    TodoWidgetEntry(date: .now, todoItems: [], doneItems: [])
}