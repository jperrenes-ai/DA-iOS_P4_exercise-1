import SwiftUI

struct ToDoListView: View {
    @ObservedObject var viewModel: ToDoListViewModel
    @State private var newTodoTitle = ""
    @State private var isShowingAlert = false
    @State private var isAddingTodo = false
    
    // New state for filter index
    @State private var filterIndex = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Selection du type des taches (all, Done, Not done)
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        Button(action: {
                            filterIndex = index
                            viewModel.applyFilter(at: index)
                        }) {
                            Text(filterTitle(for: index))
                                .font(.subheadline)
                                .fontWeight(filterIndex == index ? .semibold : .regular)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    // Ombre sur le bouton actif.
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(filterIndex == index ? Color.white : Color.clear)
                                        .shadow(
                                            color: filterIndex == index ? Color.black.opacity(0.2) : Color.clear,
                                            radius: 2,
                                            x: 0,
                                            y: 1
                                        )
                                )
                        }
                    }
                }
                .padding(3)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
                .padding(.horizontal)

                // Liste des taches
                List {
                    ForEach(viewModel.toDoItems) { item in
                        HStack {
                            Button(action: {
                                viewModel.toggleTodoItemCompletion(item)
                            }) {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(item.isDone ? .green : .primary)
                            }
                            Text(item.title)
                                .font(item.isDone ? .subheadline : .body)
                                .strikethrough(item.isDone)
                                .foregroundColor(item.isDone ? .gray : .primary)
                        }
                    }
                    
                    .onDelete { indices in
                        indices.forEach { index in
                            let item = viewModel.toDoItems[index]
                            viewModel.removeTodoItem(item)
                        }
                    }
                }
                .padding(.top, 10)

                // Sticky bottom view for adding todos
                if isAddingTodo {
                    HStack {
                        TextField("Enter Task Title", text: $newTodoTitle)
                            .padding(.leading)

                        Spacer()
                        
                        Button(action: {
                            if newTodoTitle.isEmpty {
                                isShowingAlert = true
                            } else {
                                viewModel.add(
                                    item: .init(
                                        title: newTodoTitle
                                    )
                                )
                                newTodoTitle = "" // Reset newTodoTitle to empty.
                                isAddingTodo = false // Close the bottom view after adding
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
                
                // Button to toggle the bottom add view
                Button(action: {
                    isAddingTodo.toggle()
                }) {
                    Text(isAddingTodo ? "Close" : "Add Task")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()

            }
            .navigationBarTitle("To-Do List")
            .navigationBarItems(trailing: EditButton())
        }
    }

    // Renvoie le titre du bouton de filtre selon son index.
    private func filterTitle(for index: Int) -> String {
        switch index {
        case 1: return "Done"
        case 2: return "Not Done"
        default: return "All"
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(
            viewModel: ToDoListViewModel(
                repository: ToDoListRepository()
            )
        )
    }
}
