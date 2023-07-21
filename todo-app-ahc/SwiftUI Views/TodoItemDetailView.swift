import SwiftUI

struct TodoItemDetailView: View {
    @Binding var item: TodoItem
    @State var turnDeadlineOn = false
    @State var showCalendar = false
    @State var deadline = Date().advanced(by: 3600*24)
    @State var showColorPicker = false
    @State var itemColor = Color.primary
    @EnvironmentObject var itemsManager: TodoItemsManager
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Section {
                TextEditor(text: $item.text)
                    .frame(minHeight: 120)
                    .foregroundColor(item.color == nil ? .primary : itemColor)
            }
            Section {
                HStack {
                    Text("Важность")
                        .font(.system(size: 17))
                    Spacer()
                    Picker("Важность", selection: $item.priority) {
                        Image(systemName: "arrow.down").tag(Priority.low)
                        Text("нет").tag(Priority.medium)
                        Image(systemName: "exclamationmark.2").tag(Priority.high)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(height: 38)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Сделать до")
                            .font(.system(size: 17))
                        if let deadlineString = item.deadlineString {
                            Text(deadlineString)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        if turnDeadlineOn {
                            showCalendar.toggle()
                        }
                    }
                    Toggle("", isOn: $turnDeadlineOn)
                        .onChange(of: turnDeadlineOn) { needDeadline in
                            item.deadline = needDeadline ? deadline : nil
                        }
                }
                .frame(height: 38)
                if showCalendar && turnDeadlineOn {
                    DatePicker("", selection: $deadline, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .onChange(of: deadline) { newDeadline in
                            item.deadline = newDeadline
                        }
                }
            }
            Section {
                HStack {
                    Toggle("Выбрать цвет", isOn: $showColorPicker)
                        .onChange(of: showColorPicker) { needColor in
                            item.color = needColor ? itemColor.toHex() : nil
                        }
                }
                if showColorPicker {
                    HStack {
                        Rectangle().foregroundColor(itemColor).frame(width: 150).cornerRadius(12)
                        Spacer()
                        Text(item.color ?? "-")
                    }
                    ColorPickerSwiftUIView(color: $itemColor)
                        .onChange(of: itemColor) { newColor in
                            item.color = newColor.toHex()
                        }
                }
            }
            .frame(height: 38)
            Section {
                HStack(alignment: .center) {
                    Spacer()
                    Button {
                        itemsManager.deleteItem(item)
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Удалить")
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .frame(height: 38)
        }
        .onAppear {
            turnDeadlineOn = !(item.deadline == nil)
            deadline = item.deadline ?? Date().addingTimeInterval(3600*24)
            if let color = item.color {
                itemColor = Color(hex: color)
            }
            showColorPicker = !(item.color == nil)
        }
    }
}

struct TodoItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodoItemDetailView(item: .constant(TodoItem.samples[0]))
        }
    }
}
