//
//  FirebaseViewModel.swift
//  IphoneIpadFirebase
//
//  Created by Zelxius on 16/03/22.
//

import Foundation
import Firebase

class FirebaseViewModel: ObservableObject {
    
    @Published var show = false
    @Published var datos = [FirebaseModel]()
    
    func login(email:String, pass:String, completion: @escaping (_ done: Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if user != nil {
                print("Entro")
                completion(true)
            }else{
                if let error = error?.localizedDescription{
                    print("Error en firebase", error)
                }else{
                    print("Error en la app")
                }
            }
        }
    }
    
    func createUser(email:String, pass:String, completion: @escaping (_ done: Bool) -> Void){
        Auth.auth().createUser(withEmail: email, password: pass) { (user,error) in
            if user != nil {
                print("Entro y se registro")
                completion(true)
            }else{
                if let error = error?.localizedDescription{
                    print("Error en firebase", error)
                }else{
                    print("Error en la app")
                }
            }
        }
    }
    
    // BASE DE DATOS
    
    // GUARDAR
    func save(titulo:String, desc:String, plataforma:String, portada:Data, completion: @escaping (_ done: Bool) -> Void){
        
        let storage = Storage.storage().reference()
        let nombrePortada = UUID()
        let directorio = storage.child("imagenes/\(nombrePortada)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        directorio.putData(portada, metadata: metadata){ data,error in
            if error == nil {
                print("guardo la imagen")
                // GUARDAR TEXTO
                let db = Firestore.firestore()
                let id = UUID().uuidString
                guard let idUser = Auth.auth().currentUser?.uid else { return }
                guard let email = Auth.auth().currentUser?.email else { return }
                let campos : [String:Any] = ["titulo":titulo,"desc":desc,"portada":String(describing: directorio),"idUser":idUser,"email":email]
                db.collection(plataforma).document(id).setData(campos){ error in
                    if let error = error?.localizedDescription{
                        print("Error al guardar en firestore", error)
                    }else{
                        print("Guardo todo")
                        completion(true)
                    }
                }
                // TERMINO DE GUARDAR TEXTO
            }else{
                if let error = error?.localizedDescription{
                    print("Fallo al subir la imagen en storage", error)
                }else{
                    print("fallo la app")
                }
            }
        }
    }
    
    // MARK: MOSTRAR
    func getData(plataforma: String){
        let db = Firestore.firestore()
        db.collection(plataforma).addSnapshotListener { QuerySnapshot, error in
            if let error = error?.localizedDescription{
                print("error al mostrar datos", error)
            }else{
                self.datos.removeAll()
                for document in QuerySnapshot!.documents {
                    let valor = document.data()
                    let id = document.documentID
                    let titulo = valor["titulo"] as? String ?? "sin titulo"
                    let desc = valor["desc"] as? String ?? "sin desc"
                    let portada = valor["portada"] as? String ?? "sin portada"
                    DispatchQueue.main.async {
                        let registros = FirebaseModel(id: id, titulo: titulo, desc: desc, portada: portada)
                        self.datos.append(registros)
                    }
                }
            }
        }
    }
    
    // ELIMINAR
    func delete(index: FirebaseModel, plataforma: String){
        //eliminar firestore
        let id = index.id
        let db = Firestore.firestore()
        db.collection(plataforma).document(id).delete()
        //eliminar storage
        let imagen = index.portada
        let borrarImagen = Storage.storage().reference(forURL: imagen)
        borrarImagen.delete(completion: nil)
    }
        
        // EDITAR
        func edit(titulo: String, desc: String, plataforma: String, id:String, completion: @escaping (_ done:Bool) -> Void){
            let db = Firestore.firestore()
            let campos : [String:Any] = ["titulo":titulo,"desc":desc]
            db.collection(plataforma).document(id).updateData(campos){error in
                if let error = error?.localizedDescription {
                    print("Error al editar", error)
                }else{
                    print("Edito solo texto")
                    completion(true)
                }
            }
        }
    
    // EDITAR CON IMAGEN
    func editWithImage(titulo: String, desc: String, plataforma: String, id:String, index: FirebaseModel, portada: Data, completion: @escaping (_ done:Bool) -> Void){
        // eliminar imagen
        let imagen = index.portada
        let borrarImagen = Storage.storage().reference(forURL: imagen)
        borrarImagen.delete(completion: nil)
        
        // subir la nueva imagen
        let storage = Storage.storage().reference()
        let nombrePortada = UUID()
        let directorio = storage.child("imagenes/\(nombrePortada)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
            
        directorio.putData(portada, metadata: metadata){ data,error in
            if error == nil {
                print("guardo la imagen nueva")
                // EDITANDO TEXTO
                let db = Firestore.firestore()
                let campos : [String:Any] = ["titulo":titulo,"desc":desc,"portada":String(describing: directorio)]
                db.collection(plataforma).document(id).updateData(campos){error in
                    if let error = error?.localizedDescription {
                        print("Error al editar", error)
                    }else{
                        print("Edito solo texto")
                        completion(true)
                    }
                }
                   
                // TERMINO DE GUARDAR TEXTO
            }else{
                if let error = error?.localizedDescription{
                    print("Fallo al subir la imagen en storage", error)
                }else{
                    print("fallo la app")
                }
            }
        }
    }
}
