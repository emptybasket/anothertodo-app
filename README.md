

# A Beginner Guide to SwiftData

SwiftData, a groundbreaking framework for data modeling and management, is designed to amplify your Swift apps' efficiency and reliability. Just like SwiftUI, SwiftData adopts a code-centric approach, eliminating the need for external file formats. It utilizes Swift's innovative macro system to facilitate a fluid and seamless API experience.

## A Look into SwiftData

SwiftData employs the expressivity offered by Swift's new language macros to ensure a seamless API interface. It is naturally integrated with SwiftUI and functions compatibly with other platform features, including CloudKit and Widgets. 

### Embracing @Model Macro

A key player in SwiftData's functionality is the `@Model` macro. It empowers you to define your data model's schema directly from your Swift code. SwiftData schemas are standard Swift code, but with a twist – you can annotate your properties with additional metadata when necessary. This simple act of class decoration with @Model triggers schema generation, transforming your classes' stored properties into persisted ones. 

```swift
    import SwiftData
    
    @Model
    class Trip {
        var name: String
        var destination: String
        var endDate: Date
        var startDate: Date
     
        var bucketList: [BucketListItem]? = []
        var livingAccommodation: LivingAccommodation?
    }
```
The real charm of SwiftData is its versatility. It's capable of adapting basic value types such as `String`, `Int`, and `Float`, and complex types like `structs`, `enums`, and `codable` types. All these become instantly usable as attributes. Furthermore, SwiftData allows for the creation of links between your model types through relationships and collections of model types. 

You can modify the way SwiftData builds your schema using metadata on your properties. By using @Attribute, you can add uniqueness constraints, while @Relationship can be employed to control the choice of inverses and specify delete propagation rules.

```swift
    @Model
    class Trip {
        @Attribute(.unique) var name: String
        var destination: String
        var endDate: Date
        var startDate: Date
     
        @Relationship(.cascade) var bucketList: [BucketListItem]? = []
        var livingAccommodation: LivingAccommodation?
    }
```

## Working with SwiftData 

To begin your journey with SwiftData, you'll need to acquaint yourself with two crucial objects: SwiftData's ModelContainer and ModelContext. 

### ModelContainer

The `ModelContainer` serves as the persistent backend for your model types. It can operate with default settings, or be customized with configurations and migration options. To create a model container, simply specify the model types you want to store. Additional customizations can be applied using a configuration to change your URL, CloudKit, group container identifiers, and migration options. Once your container is set up, you're ready to fetch and save data using model contexts.

##### Initialize with only a schema

```swift
let container = try ModelContainer([Trip.self, LivingAccommodation.self])
```

##### Initialize with configurations

```swift
    let container = try ModelContainer(
        for: [Trip.self, LivingAccommodation.self],
        configurations: ModelConfiguration(url: URL("path"))
    )
```

### ModelContext

`ModelContext` tracks changes to your models and provides various actions to operate on them. It's your primary interface for tracking updates, fetching data, saving changes, and even undoing those changes. In SwiftUI, you'll generally retrieve the `ModelContext` from your view's environment after creating your model container. 

```swift
    import SwiftUI
    
    struct ContextView : View {
        @Environment(\.modelContext) private var context
    }
```

SwiftData also benefits from new Swift native types like predicate and fetch descriptor, which offer a fully type-checked modern replacement for NSPredicate and significant enhancements to Swift's native sort descriptor. The implementation of your predicates is easy with Xcode's autocomplete support. 

##### Building a predicate

```swift
    let today = Date()
    let tripPredicate = #Predicate<Trip> { 
        $0.destination == "New York" &&
        $0.name.contains("birthday") &&
        $0.startDate > today
    }
```

Once you've decided which data you're interested in fetching, the new FetchDescriptor type can instruct your ModelContext to fetch those data.

##### Fetching with a FetchDescriptor

```swift
    let descriptor = FetchDescriptor<Trip>(predicate: tripPredicate)
    
    let trips = try context.fetch(descriptor)
```

SwiftData facilitates creating, deleting, and changing your data. After creating your model objects like any other Swift classes, you can insert them into the context and utilize SwiftData's features, such as change tracking and persistence. 

```swift
    @Environment(\.modelContext) private var context
    
    var myTrip = Trip(name: "Birthday Trip", destination: "New York")
    
    // Insert a new trip
    context.insert(myTrip)
    
    // Delete an existing trip
    context.delete(myTrip)
    
    // Manually save changes to the context
    try context.save()
```

You can learn more about SwiftData containers and contexts and driving its operations, by checking WWDC Session titled: "[Dive Deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)".

## Leveraging SwiftUI for SwiftData 

SwiftData was built with SwiftUI in mind, and the integration between the two couldn't be smoother. Whether it's setting up your SwiftData container, fetching data, or driving your view updates, APIs are in place to merge these frameworks effortlessly. With SwiftUI, you can configure your data store, toggle options, enable undo and autosave, and much more. 

SwiftData supports the all-new observable feature for your modeled properties. With this, SwiftUI will automatically refresh changes on any of the observed properties. 

## A sample ToDo App using what we learn so far

While studying for this article I tried also to create a sample app to reinforce what I understand so far. Let's break down and explore how to create a simple ToDo app using SwiftData. This app will allow you to create, view, update, and delete todo items.

<img width="656" alt="Sample TODO App" src="https://github.com/emptybasket/anothertodo-app/assets/98072257/28882429-66a2-416b-984a-d2310ddf0b8b">


## Creating the ToDo Model

The first step is to create a model for our ToDo items. In SwiftData, we use the `@Model` attribute to denote a Swift class as a data model. Our `ToDo` class has three properties: `id`, `name`, and `note`. 

The `id` is a unique identifier for each ToDo item, and we've decorated it with the `@Attribute(.unique)` attribute to enforce uniqueness. The `name` and `note` fields are simple strings to hold the task's title and additional notes respectively. We also have an initializer to help us create ToDo instances easily.

```swift
@Model
final class ToDo: Identifiable {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var note: String
    
    init(id: String = UUID().uuidString, name: String, note: String) {
        self.id = id
        self.name = name
        self.note = note
    }
}
```

## Creating a New ToDo Item

`AddToDoListItemScreen` is a SwiftUI `View` that allows us to create a new ToDo item. It has two `@State` properties for our text fields, and it retrieves the `ModelContext` from the environment. This context will allow us to insert and save our new ToDo items.

In our `body`, we have a `Form` with two `TextField`s for the name and the notes. We also have a `Button` that, when clicked, creates a new `ToDo` instance, inserts it into the `ModelContext`, and saves the context. If the save operation is successful, the view is dismissed and the new ToDo item is persisted.

```swift
struct AddToDoListItemScreen: View {
    
    @State private var name = ""
    @State private var noteDiscription = ""
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !name.isEmptyOrWithWhiteSpace && !noteDiscription.isEmptyOrWithWhiteSpace
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Title", text: $name)
                TextField("Enter your notes", text: $noteDiscription)
                Button("Save") {
                    let todo = ToDo(name: name, note: noteDiscription)
                    context.insert(todo)
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    dismiss()
                }.disabled(!isFormValid)
            }
            .navigationTitle("Add todo item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

## Viewing ToDo Items

The `ToDoListView` displays all of our ToDo items in a `List`. It takes an array of `ToDo`s as a parameter, and it also retrieves the `ModelContext` from the environment. 

In our `List`, we iterate over each `ToDo` and create a `NavigationLink` for it. Each `ToDo` can be clicked to navigate to its detail view.

We also have an `.onDelete` modifier on our `ForEach`. This modifier takes a function that deletes the `ToDo` at the specified index from the `ModelContext` and saves the changes.

```swift


struct ToDoListView: View {
    
    let todos: [ToDo]
    @Environment(\.modelContext) private var context
    
    private func deleteTodo(indexSet: IndexSet) {
        indexSet.forEach { index in
            let todo = todos[index]
            context.delete(todo)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(todos, id: \.id) { todo in
                NavigationLink(value: todo) {
                    VStack(alignment: .leading) {
                        Text(todo.name)
                            .font(.title3)
                        Text(todo.note)
                            .font(.caption)
                    }
                }
            }.onDelete(perform: deleteTodo)
        }.navigationDestination(for: ToDo.self) { todo in
            ToDoDetailScreen(todo: todo)
        }
    }
}
```

## Updating ToDo Items

The `ToDoDetailScreen` is a SwiftUI `View` that allows us to update a ToDo item. It takes a `ToDo` as a parameter, and it retrieves the `ModelContext` from the environment.

In our `body`, we have a `Form` with two `TextField`s for the name and the note, pre-populated with the current ToDo's data. We also have a `Button` that, when clicked, updates the `ToDo` instance's name and note, and then saves the `ModelContext`. If the save operation is successful, the view is dismissed, and the updated ToDo item is persisted.

```swift
struct ToDoDetailScreen: View {
    
    @State private var name: String = ""
    @State private var note: String = ""

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let todo: ToDo

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Note description", text: $note)
            
            Button("Update") {
                todo.name = name
                todo.note = note
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                
                dismiss()
            }
        }.onAppear {
            name = todo.name
            note = todo.note
        }
    }
}
```

## Bringing It All Together

Finally, we have the `ContentView`, which is the root of our application. It presents the `ToDoListView` wrapped in a `NavigationStack`. It also has an `Add` button in the toolbar that presents the `AddToDoListItemScreen` when clicked.

The `@Query` attribute is used to retrieve all ToDo items from the `ModelContext`, sorted by `id` in reverse order. This array is passed to the `ToDoListView`.

```swift
struct ContentView: View {
    
    @State private var isPresented: Bool = false
    @Query(sort: \.id, order: .reverse) private var todos: [ToDo]
    
    var body: some View {
        NavigationStack {
            VStack {
                ToDoListView(todos: todos)
                    .navigationTitle("TODO App")
            }
            .sheet(isPresented: $isPresented, content: {
                AddToDoListItemScreen()
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
```

And that's it! You've now seen a step-by-step explanation of how to create a simple ToDo app using SwiftData. It covers how to create, read, update, and delete data using SwiftData's key features.

## SwiftData: Your New Ally in App Development 

SwiftData stands as a potent new addition to your arsenal for managing data, designed with an intrinsic understanding of Swift's capabilities. It provides a code-centric approach that encourages a more direct and intuitive coding experience. With features such as persistence, undo and redo, iCloud synchronization, and widget development, SwiftData is a game-changer for your app development process.

If you're just starting with iOS development, SwiftData and SwiftUI's seamless integration offers an accessible entry point. Dive right in and start building high-performance, data-driven applications with SwiftData today.

#### Reference

 - [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
 - [Meet SwiftData](Meet%20SwiftData)
 - [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)

#### Learn more

 - [Introduction to SwiftData (WWDC23) by flo](https://www.youtube.com/watch?v=zojPt5TVsB8&t=5s&ab_channel=FlowritesCode)
 - [Hello SwiftData! by Mohammad Azam](https://www.youtube.com/watch?v=YxpMbjB9gKQ&ab_channel=azamsharp)
 - [[Paid Material] SwiftData - Declarative Data Persistence for SwiftUI](https://www.udemy.com/course/swiftdata-declarative-data-persistence-for-swiftui/)
