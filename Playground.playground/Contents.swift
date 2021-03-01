import UIKit
import CoreData

let manager = InMemoryCoreDataStack()


let backgroundThread = manager.persistentContainer.newBackgroundContext()

var backgroundPerson: Person?
backgroundThread.performAndWait {
    let newPerson = Person(context: backgroundThread)
    newPerson.name = "Andrew"
    backgroundPerson = newPerson
}
try! backgroundThread.save()

let fetch: NSFetchRequest<Person> = Person.fetchRequest()
let fetchedPerson = try! backgroundThread.fetch(fetch)

assert(fetchedPerson.count == 1)
assert(fetchedPerson.first!.name! == "Andrew")

let anotherBT = manager.persistentContainer.newBackgroundContext()
anotherBT.performAndWait {
    let newPerson = Person(context: anotherBT)
    newPerson.name = "Andrew" + backgroundPerson!.name!
    print(backgroundPerson!.name!)
}
try! anotherBT.save()

let fetchedPeople = try! anotherBT.fetch(fetch)


DispatchQueue.global(qos: .background).async {
    for _ in 0...1000 {
        assert(fetchedPeople.count == 2)
        assert(fetchedPeople[0].name! == "AndrewAndrew")
    }
}




