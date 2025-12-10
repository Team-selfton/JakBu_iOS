import Foundation

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

struct CreateTodoRequest: Codable {
    let title: String
    let date: String
}

struct SetTodoStatusRequest: Codable {
    let done: Bool
}
