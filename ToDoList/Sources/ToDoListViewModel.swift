import SwiftUI

final class ToDoListViewModel: ObservableObject {
    // MARK: - Private properties

    private let repository: ToDoListRepositoryType

    // Liste complète de toutes les tâches (jamais filtrée).
    private var allToDoItems: [ToDoItem] = []

    // Mémorise le filtre actuellement sélectionné (0 = All, 1 = Done, 2 = Not Done).
    private var currentFilterIndex: Int = 0

    // MARK: - Init

    init(repository: ToDoListRepositoryType) {
        self.repository = repository
        self.allToDoItems = repository.loadToDoItems()
        self.toDoItems = self.allToDoItems
    }

    // MARK: - Outputs

    /// Publisher for the list of to-do items (version affichée à l'écran).
    @Published var toDoItems: [ToDoItem] = []

    // MARK: - Inputs

    // Add a new to-do item with priority and category
    func add(item: ToDoItem) {
        allToDoItems.append(item)
        repository.saveToDoItems(allToDoItems)
        applyFilter(at: currentFilterIndex)
    }

    /// Toggles the completion status of a to-do item.
    func toggleTodoItemCompletion(_ item: ToDoItem) {
        if let index = allToDoItems.firstIndex(where: { $0.id == item.id }) {
            allToDoItems[index].isDone.toggle()
            repository.saveToDoItems(allToDoItems)
            applyFilter(at: currentFilterIndex)
        }
    }

    /// Removes a to-do item from the list.
    func removeTodoItem(_ item: ToDoItem) {
        allToDoItems.removeAll { $0.id == item.id }
        repository.saveToDoItems(allToDoItems)
        applyFilter(at: currentFilterIndex)
    }

    /// Apply the filter to update the list.
    func applyFilter(at index: Int) {
        currentFilterIndex = index
        switch index {
        case 1:
            // Done : on garde uniquement les tâches terminées.
            toDoItems = allToDoItems.filter { $0.isDone }
        case 2:
            // Not Done : on garde uniquement les tâches non terminées.
            toDoItems = allToDoItems.filter { !$0.isDone }
        default:
            // All : on affiche tout.
            toDoItems = allToDoItems
        }
    }
}
