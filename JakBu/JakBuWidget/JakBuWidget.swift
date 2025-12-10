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
        VStack {
            Spacer()
            ProgressCircleView(
                total: entry.todoItems.count + entry.doneItems.count,
                completed: entry.doneItems.count
            )
            Spacer()
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    var entry: TodoWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WidgetHeaderView()

            HStack(alignment: .top, spacing: 12) {
                // 할일 섹션
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "circle")
                            .font(.caption2)
                            .foregroundColor(Color(red: 0x5b/255, green: 0x8d/255, blue: 0xd5/255))
                        Text("할일")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white.opacity(0.8))
                    }

                    if entry.todoItems.isEmpty {
                        Text("없음")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.leading, 4)
                    } else {
                        ForEach(entry.todoItems.prefix(3)) { todo in
                            TodoRow(todo: todo)
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .frame(height: 60)
                    .overlay(Color.white.opacity(0.1))

                // 완료 섹션
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("완료")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white.opacity(0.8))
                    }

                    if entry.doneItems.isEmpty {
                        Text("없음")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.leading, 4)
                    } else {
                        ForEach(entry.doneItems.prefix(3)) { todo in
                            TodoRow(todo: todo)
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding()
    }
}

struct WidgetHeaderView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("JakBu")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0x6b/255, green: 0x9b/255, blue: 0xd8/255))
                Text("작심삼일 부수기")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
    }
}

struct TodoRow: View {
    let todo: Todo

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: todo.status == .DONE ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.status == .DONE ? .green : Color(red: 0x5b/255, green: 0x8d/255, blue: 0xd5/255))
                .font(.caption2)

            Text(todo.title)
                .font(.caption2)
                .lineLimit(1)
                .strikethrough(todo.status == .DONE, color: .white.opacity(0.4))
                .foregroundColor(todo.status == .DONE ? .white.opacity(0.5) : .white.opacity(0.9))
        }
        .padding(.horizontal, 4)
    }
}

struct ProgressCircleView: View {
    let total: Int
    let completed: Int

    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.5 {
            return Color(red: 0x5b/255, green: 0x8d/255, blue: 0xd5/255)
        } else {
            return Color(red: 0x6b/255, green: 0x9b/255, blue: 0xd8/255)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.2)
                .foregroundColor(.white)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut, value: progress)

            VStack(spacing: 2) {
                Text("\(completed)/\(total)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text("완료")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: 80, height: 80)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            WidgetHeaderView()
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)

                Text("모든 할일 완료!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("새로운 할일을 추가해보세요")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding()
    }
}

struct JakBuWidget: Widget {
    let kind: String = "JakBuWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JakBuWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0x1e/255, green: 0x2a/255, blue: 0x3f/255),
                            Color(red: 0x1a/255, green: 0x23/255, blue: 0x32/255),
                            Color(red: 0x0f/255, green: 0x15/255, blue: 0x20/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
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