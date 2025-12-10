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
    // APIService를 사용하기 위한 준비
    // 실제 앱에서는 App Group을 설정하여 공유 데이터를 사용해야 할 수 있습니다.
    // 여기서는 APIService가 위젯 타겟에 포함되어 있고,
    // 인증 토큰이 User Defaults 또는 키체인 공유를 통해 접근 가능하다고 가정합니다.

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
            // 1시간 후에 타임라인을 새로고침하도록 설정
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchTodoEntry(completion: @escaping (TodoWidgetEntry) -> ()) {
        // APIService를 사용하여 오늘의 할일 목록을 가져옵니다.
        // 이 예제에서는 APIService가 Combine을 사용한다고 가정합니다.
        // 실제 구현 시에는 위젯 환경에 맞게 비동기 처리가 필요할 수 있습니다.
        
        // APIService.shared.getTodayTodos()가 Combine Publisher를 반환한다고 가정
        // 위젯은 UIKit을 사용하지 않으므로, API 호출 로직이 UIKit에 의존하지 않아야 합니다.
        // 여기서는 가상의 데이터로 대체합니다. 실제 APIService 호출 코드로 변경해야 합니다.
        
        // --- 가상 데이터 ---
        let sampleTodos = [
            Todo(id: 1, title: "오늘의 할일 1", date: "2025-12-10", status: .TODO),
            Todo(id: 2, title: "오늘의 할일 2", date: "2025-12-10", status: .TODO),
            Todo(id: 3, title: "완료된 할일 1", date: "2025-12-10", status: .DONE)
        ]
        
        let todoItems = sampleTodos.filter { $0.status == .TODO }
        let doneItems = sampleTodos.filter { $0.status == .DONE }
        
        let entry = TodoWidgetEntry(date: Date(), todoItems: todoItems, doneItems: doneItems)
        completion(entry)
        
        // --- 실제 APIService 호출 예시 (주석 처리) ---
        /*
        var cancellables = Set<AnyCancellable>()
        APIService.shared.getTodayTodos()
            .receive(on: DispatchQueue.main)
            .sink { completionResult in
                if case .failure(_) = completionResult {
                    // 에러 발생 시 빈 목록으로 엔트리 생성
                    let entry = TodoWidgetEntry(date: Date(), todoItems: [], doneItems: [])
                    completion(entry)
                }
            } receiveValue: { todos in
                let todoItems = todos.filter { $0.status == .TODO }
                let doneItems = todos.filter { $0.status == .DONE }
                let entry = TodoWidgetEntry(date: Date(), todoItems: todoItems, doneItems: doneItems)
                completion(entry)
            }
            .store(in: &cancellables) // 실제 사용 시에는 이 cancellable을 관리해야 합니다.
        */
    }
}

struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let todoItems: [Todo]
    let doneItems: [Todo]
}

struct JakBuWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘의 작부")
                .font(.headline)
                .foregroundColor(.blue)

            if entry.todoItems.isEmpty && entry.doneItems.isEmpty {
                Text("할일이 없습니다. 추가해보세요!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    if !entry.todoItems.isEmpty {
                        Text("☑️ 할일")
                            .font(.subheadline).bold()
                        ForEach(entry.todoItems.prefix(3)) { todo in
                            Text(todo.title)
                                .font(.footnote)
                        }
                    }
                }
                
                Divider().padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 4) {
                    if !entry.doneItems.isEmpty {
                        Text("👍 한일")
                            .font(.subheadline).bold()
                        ForEach(entry.doneItems.prefix(3)) { todo in
                            Text(todo.title)
                                .font(.footnote)
                                .strikethrough()
                                .foregroundColor(.gray)
                        }
                    }
                }
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
    TodoWidgetEntry(date: .now, todoItems: [], doneItems: [])
}