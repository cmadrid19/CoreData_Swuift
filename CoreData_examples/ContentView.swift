//CoreData

/* CRUD
 Create
 Read
 Update
 Delete
 */


import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var potatoes: [NSManagedObject] = []
    @State var newPotatoString = ""
    @State var showSheet = false
    @State var modifyingPotato: String? = nil
    
    var body: some View {
        VStack{
            VStack{
                TextField("What is your favourite potato", text: $newPotatoString)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(5)
                Button(action: {
                    self.addNewPotato()
                }) {
                    Text("Add new potato")
                }
            }.padding()
            .background(Color.init(white: 0.9))
            .cornerRadius(10)
            .padding()
            
            
            ForEach(potatoes, id: \.self) { thisPotato in
                Button(action: {
                    self.modifyingPotato = (thisPotato as? Potato)?.stringAttribute ?? "Potato string error"
                    self.newPotatoString = (thisPotato as? Potato)?.stringAttribute ?? "Potato string error"
                    self.showSheet = true
                }) {
                    Text((thisPotato as? Potato)?.stringAttribute ?? "Potato string error")
                        .frame(width: 200, height: 20)
                }.sheet(isPresented: self.$showSheet){
                    VStack{
                        TextField("Give this potato some value", text: self.$newPotatoString)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(5)
                        
                        HStack{
                            Button(action: {
                                if let potatoToModify = self.modifyingPotato {
                                    self.deletePotato(thisPotatoString: potatoToModify)
                                }
                                
                            }) {
                                Text("Delete potato")
                            }
                            
                            Button(action: {
                                if let potatoToModify = self.modifyingPotato {
                                    self.updatePotato(currentPotatoString: potatoToModify, newPotatoString: self.$newPotatoString.wrappedValue)
                                }
                                
                            }) {
                                Text("Update potato")
                            }
                        }
                        
                    }.padding()
                    .background(Color.init(white: 0.9))
                    .cornerRadius(10)
                    .padding()
                }
                
            }
        }.onAppear(){
            self.loadPotatos()
        }
    }
    
    //Create - Add
    func addNewPotato(){
        
        //Intentamos coger el appDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //Se encarga de guardar el objeto
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Que tipo de entity tratamos
        let entity = NSEntityDescription.entity(forEntityName: "Potato", in: managedContext)!
        
        //Creamos una nueva instancia de ManagedObject de tipo entity
        let newPotato = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //le damos valor a la nueva instancia
        newPotato.setValue($newPotatoString.wrappedValue, forKeyPath: "stringAttribute")
        
        do{
            try managedContext.save()
            print("✅ Saved succesfully -- \($newPotatoString.wrappedValue)")
            self.loadPotatos()
        }catch let error as NSError {
            print("❌ Could not save -- \($newPotatoString.wrappedValue)")
        }
        
    }
    
    //Load - Retrieve
    func loadPotatos(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        } 
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //creamos una solicitud de busqueda de entity "Potato"
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Potato")
        
        do {
            potatoes = try managedContext.fetch(fetchRequest)
            self.showSheet = false
        }catch let error as NSError {
            print("❌ Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    //Update
    func updatePotato(currentPotatoString: String, newPotatoString: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Potato")
        fetchRequest.predicate = NSPredicate(format: "stringAttribute = %@", currentPotatoString)
        
        do {
            let fetchReturn = try managedContext.fetch(fetchRequest)
            let objectUpdate = fetchReturn[0] as! NSManagedObject // Solo cambiaremos la primera que coincida
            objectUpdate.setValue(newPotatoString, forKey: "stringAttribute")
            do {
                try managedContext.save()
                print("✅ Updated succesfully -- \(currentPotatoString) changed to \(newPotatoString)")
                self.loadPotatos()
            }catch let error as NSError {
                print("❌ Could not Update \(error), \(error.userInfo)")
            }
            
        }catch let error as NSError {
            print("❌ Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //Delete
    func deletePotato(thisPotatoString: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Potato")
        fetchRequest.predicate = NSPredicate(format: "stringAttribute = %@", thisPotatoString)
        
        do {
            let fetchReturn = try managedContext.fetch(fetchRequest)
            
            let objectDelete = fetchReturn[0] as! NSManagedObject
            managedContext.delete(objectDelete)
            
            do{
                try managedContext.save()
                print("✅ Deleted succesfully -- \(thisPotatoString)")
                self.loadPotatos()
            }catch let error as NSError {
                print("❌ Could not Delete \(thisPotatoString): \(error), \(error.userInfo)")
            }
        }catch let error as NSError {
            print("❌ Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
