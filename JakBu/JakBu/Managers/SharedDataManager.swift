import Foundation
import WidgetKit

/// 앱과 위젯 간 데이터 공유를 위한 매니저
class SharedDataManager {

    static let shared = SharedDataManager()

    // App Group Identifier - Xcode에서 설정한 것과 동일해야 함
    private let appGroupIdentifier = "group.com.yourcompany.jakbu"

    private let todosKey = "shared_todos"
    private let lastUpdateKey = "shared_last_update"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    private init() {}

    // MARK: - Save Data

    /// 할일 목록을 공유 저장소에 저장
    func saveTodos(_ todos: [Todo]) {
        guard let defaults = sharedDefaults else {
            print("❌ App Group UserDefaults를 찾을 수 없습니다. App Groups 설정을 확인하세요.")
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(todos)
            defaults.set(data, forKey: todosKey)
            defaults.set(Date(), forKey: lastUpdateKey)
            defaults.synchronize()

            print("✅ 위젯용 데이터 저장 완료: \(todos.count)개")

            // 위젯 업데이트 트리거
            reloadAllWidgets()
        } catch {
            print("❌ 할일 저장 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Load Data

    /// 공유 저장소에서 할일 목록 불러오기
    func loadTodos() -> [Todo] {
        guard let defaults = sharedDefaults else {
            print("❌ App Group UserDefaults를 찾을 수 없습니다.")
            return []
        }

        guard let data = defaults.data(forKey: todosKey) else {
            print("⚠️ 저장된 할일 데이터가 없습니다.")
            return []
        }

        do {
            let decoder = JSONDecoder()
            let todos = try decoder.decode([Todo].self, from: data)
            print("✅ 위젯용 데이터 로드 완료: \(todos.count)개")
            return todos
        } catch {
            print("❌ 할일 로드 실패: \(error.localizedDescription)")
            return []
        }
    }

    /// 마지막 업데이트 시간
    func lastUpdateDate() -> Date? {
        return sharedDefaults?.object(forKey: lastUpdateKey) as? Date
    }

    // MARK: - Widget Control

    /// 모든 위젯 새로고침
    func reloadAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 위젯 새로고침 요청")
    }

    /// 특정 위젯만 새로고침
    func reloadWidget(kind: String) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }

    // MARK: - Debug

    /// 공유 데이터 상태 확인 (디버깅용)
    func checkSharedData() {
        if let defaults = sharedDefaults {
            print("✅ App Group 접근 가능")
            print("  - Group ID: \(appGroupIdentifier)")
            print("  - 저장된 할일 수: \(loadTodos().count)")
            if let lastUpdate = lastUpdateDate() {
                print("  - 마지막 업데이트: \(lastUpdate)")
            }
        } else {
            print("❌ App Group 접근 불가")
            print("  - Xcode에서 App Groups 설정을 확인하세요")
            print("  - 메인 앱과 위젯 모두 같은 그룹 ID를 사용해야 합니다")
        }
    }
}
