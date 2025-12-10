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
        print("🔍 [Widget] App Group ID: \(appGroupIdentifier)")

        guard let defaults = sharedDefaults else {
            print("❌ [Widget] App Group UserDefaults를 찾을 수 없습니다.")
            print("   Xcode에서 위젯 타겟의 App Groups 설정을 확인하세요!")
            return []
        }

        print("✅ [Widget] UserDefaults 접근 성공")

        guard let data = defaults.data(forKey: todosKey) else {
            print("⚠️ [Widget] 저장된 할일 데이터가 없습니다. (key: \(todosKey))")

            // 저장된 모든 키 확인
            let allKeys = defaults.dictionaryRepresentation().keys
            print("   저장된 키 목록: \(allKeys)")
            return []
        }

        print("✅ [Widget] 데이터 발견! 크기: \(data.count) bytes")

        do {
            let decoder = JSONDecoder()
            let todos = try decoder.decode([Todo].self, from: data)
            print("✅ [Widget] 데이터 로드 완료: \(todos.count)개")
            for (index, todo) in todos.enumerated() {
                print("   [\(index+1)] \(todo.title) - \(todo.status)")
            }
            return todos
        } catch {
            print("❌ [Widget] 할일 로드 실패: \(error.localizedDescription)")
            return []
        }
    }
}
