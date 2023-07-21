import SwiftUI

struct TodoItemView: View {
    @Binding var item: TodoItem
    @EnvironmentObject var itemsManager: TodoItemsManager

    var body: some View {
        HStack {
            Button {
                item.isDone.toggle()
                itemsManager.editItem(item)
            } label: {
                if item.isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                } else if item.priority == .high {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.red)
                            .opacity(0.1)
                            .font(.system(size: 24))
                        Image(systemName: "circle")
                            .foregroundColor(.red)
                            .font(.system(size: 24, weight: .light))
                    }
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            VStack(alignment: .leading) {
                HStack {
                    if item.priority == .high && !item.isDone {
                        Image(systemName: "exclamationmark.2")
                            .foregroundColor(.red)
                            .font(.system(size: 17, weight: .bold))
                    }
                    Text(item.text)
                        .strikethrough(item.isDone, color: .gray)
                        .foregroundColor(item.isDone ?
                            .gray : (item.color == nil ? .primary : Color(hex: item.color ?? "FF0000")))
                        .font(.system(size: 17))
                        .lineLimit(item.isDone ? 1 : 3)
                }
                if let deadlineString = item.deadlineString {
                    HStack {
                        Text("\(Image(systemName: "calendar")) \(deadlineString)")
                            .font(.system(size: 15))
                            .foregroundColor(Color.gray)
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemView(item: .constant(TodoItem.samples[1]))
    }
}
