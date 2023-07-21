import SwiftUI

struct TodoItemsListView: View {
    @Binding var items: [TodoItem]
    @State var doneItemsCounter = 0
    @State var showDetailView = false
    @State var addingNewItem = false
    @State var itemToEdit = TodoItem(text: "", priority: .medium, isDone: false, createdDate: Date())
    @EnvironmentObject var itemsManager: TodoItemsManager

    @State var showDone: Bool = true

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    ForEach($items) { $item in
                        if !item.isDone || showDone {
                            TodoItemView(item: $item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    addingNewItem = false
                                    itemToEdit = item
                                    showDetailView = true
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        item.isDone.toggle()
                                        itemsManager.editItem(item)
                                    } label: {
                                        Image(systemName: "checkmark.circle")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        itemsManager.deleteItem(item)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                    }
                    .frame(minHeight: 38)
                    HStack {
                        Text("Новое")
                            .foregroundColor(.gray)
                            .frame(minHeight: 38)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        addingNewItem = true
                        itemToEdit = TodoItem(text: "", priority: .medium, isDone: false, createdDate: Date())
                        showDetailView = true
                    }

                } header: {
                    HStack {
                        Text("Выполнено - \(doneItemsCounter)")
                            .font(.system(size: 15))
                        Spacer()
                        Button {
                            showDone.toggle()
                            UserDefaults.standard.set(showDone, forKey: "showDone")
                        } label: {
                            Text(showDone ? "Скрыть" : "Показать")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .textCase(.none)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Мои дела")
            .toolbar {
                if itemsManager.active > 0 {
                    ProgressView()
                }
            }
            .sheet(isPresented: $showDetailView) {
                NavigationView {
                    TodoItemDetailView(item: $itemToEdit)
                        .navigationTitle("Дело")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Сохранить") {
                                    if addingNewItem {
                                        itemsManager.addItem(itemToEdit)
                                    } else {
                                        itemsManager.editItem(itemToEdit)
                                    }
                                    showDetailView = false
                                }
                                .disabled(itemToEdit.text.count == 0)
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Отмена") {
                                    showDetailView = false
                                }
                            }
                        }
                }
            }
            Button {
                addingNewItem = true
                itemToEdit = TodoItem(text: "", priority: .medium, isDone: false, createdDate: Date())
                showDetailView = true
            } label: {
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 44))
                        .shadow(radius: 12)
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 44))
                }
            }
        }
        .onAppear {
            showDone = UserDefaults.standard.value(forKey: "showDone") as? Bool ?? true
            updateDoneItemsCounter()
        }
        .onChange(of: items) { _ in
            updateDoneItemsCounter()
        }
    }

    func updateDoneItemsCounter() {
        doneItemsCounter = 0
        for item in items {
            doneItemsCounter += item.isDone ? 1 : 0
        }
    }
}

struct TodoItemsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodoItemsListView(items: .constant(TodoItem.samples))
                .environmentObject(TodoItemsManager())
        }
    }
}
