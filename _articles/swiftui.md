---
layout: page
title: SwiftUI
leded: The iOS and macOS app development framework
---

## Boilerplate

### Item list view (with SwiftData)

```swift
import SwiftUI
import SwiftData

struct ItemListView: View {
    @Query(sort: \Item.createdAt) private var items: [Item]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.title)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation { modelContext.delete(item) }
                            }
                        }
                }
            }
            .navigationTitle("Items")
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No Items", systemImage: "tray")
                }
            }
            .toolbar {
                Button("Add", systemImage: "plus") {
                    modelContext.insert(Item(title: "New item"))
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    )
    container.mainContext.insert(Item(title: "Example"))
    return ItemListView().modelContainer(container)
}
```
