//
//  AuthService.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 14/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (_ errorMessage: String?,_ data: AnyObject?) -> Void

class AuthService{
    
    private static let _shared = AuthService()
    
    static var shared : AuthService {
        return _shared
    }
    
    var user : User? {
        return Auth.auth().currentUser
    }
    
    func login(email: String, password: String, onComplete: Completion?) {
        //Haremos el login
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = (error as NSError?) {
               //Ha habido un error
                print(error)
                /*
                if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
                    //Chequeamos el código de error
                    if errorCode == FIRAuthErrorCode.errorCodeUserNotFound {
                        //Creamos el usuario pues este no existe en FB
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if let error = (error as NSError?) {
                                //Mostrar el error pertinete al usuario
                                self.handleFirebaseError(error: error, onComplete: onComplete)
                            } else {
                                if user?.uid != nil {
                                    
                                    DatabaseService.shared.saveUser(uid: (user?.uid)!)
                                    
                                    //Hacemos el login del usuario
                                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                                        if let error = (error as NSError?) {
                                            //Mostramos el error al usuario
                                            self.handleFirebaseError(error: error, onComplete: onComplete)
                                        } else {
                                            //El login ha sido completado satisfactoriamente =D
                                            onComplete?(nil, user!)
                                        }
                                    })
                                }
                            }
                        })
                    } else {
                        //Chequeamos el resto de códigos de error...
                        self.handleFirebaseError(error: error, onComplete: onComplete)
                    }
                }*/
            } else {
                //Hemos hecho login correctamente y hay que mostrar el VC de Snap
                onComplete?(nil, user!)
            }
            
            
        })
    }
    
    
    
    func handleFirebaseError(error: NSError, onComplete: Completion?){
        print(error.debugDescription)
        /*if let errorCode = FIRAuthInternalErrorCode(rawValue: error.code){
            switch(errorCode){
            case .errorCodeInvalidEmail:
                onComplete?("Email incorrecto", nil)
                break
            case .errorCodeWrongPassword, .errorCodeInvalidCredential, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Contraseña incorrecta", nil)
                break
                
            case .errorCodeUserDisabled:
                onComplete?("Este usuario no tiene permisos para entrar", nil)
                break
                
            case .errorCodeEmailAlreadyInUse:
                onComplete?("No se ha podido crear la cuenta. Este email ya está registrado", nil)
                break
                
            case .errorCodeWeakPassword:
                onComplete?("Contraseña demasiado débil. Añade números y letras", nil)
                break
                
            default:
                onComplete?("Ha habido un problema para entrar. Prueba de nuevo.", nil)
            }
        }*/
    }
    
}
