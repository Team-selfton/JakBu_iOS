import Foundation

struct Todo: Codable, Identifiable {
    let id: Int
    let title: String
    let date: String
    var status: TodoStatus // Optimistic UI를 위해 var로 변경
}

enum TodoStatus: String, Codable {
    case TODO
    case DONE
}

struct CreateTodoRequest: Codable {
    let title: String
    let date: String
}

struct SetTodoStatusRequest: Codable {
    let done: Bool
}
