import Foundation

/// 위젯용 공유 데이터 매니저 (앱과 동일한 로직)
class WidgetSharedDataManager {

    static let shared = WidgetSharedDataManager()

    // App Group Identifier - 앱과 동일해야 함
    private let appGroupIdentifier = "group.com.yourcompany.jakbu"

    private let todosKey = "shared_todos"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    private init() {}

    // MARK: - Load Data

    /// 공유 저장소에서 할일 목록 불러오기
    func loadTodos() -> [Todo] {
        guard let defaults = sharedDefaults else {
            print("❌ [Widget] App Group UserDefaults를 찾을 수 없습니다.")
            return []
        }

        guard let data = defaults.data(forKey: todosKey) else {
            print("⚠️ [Widget] 저장된 할일 데이터가 없습니다.")
            return []
        }

        do {
            let decoder = JSONDecoder()
            let todos = try decoder.decode([Todo].self, from: data)
            print("✅ [Widget] 데이터 로드 완료: \(todos.count)개")
            return todos
        } catch {
            print("❌ [Widget] 할일 로드 실패: \(error.localizedDescription)")
            return []
        }
    }
}
