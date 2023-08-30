//
//  LoginViewController.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 10/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailTextField: RoundTextField!
    
    @IBOutlet weak var passwordTextField: RoundTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.emailTextField.text    = "jb@frogames.es"
        self.passwordTextField.text = "frogames"
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        if let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            (email.characters.count > 0 && password.characters.count > 0) {
            //Hay que hacer el login
            AuthService.shared.login(email: email, password: password, onComplete: {
                (message, data) in
                
                guard message == nil else {
                    let alert = UIAlertController(title: "Ha habido un error", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
                
            })
        } else {
            let alert = UIAlertController(title: "Usuario y contraseña incorrectos", message: "Por favor, rellena el usuario y contraseña para seguir.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated:true)
        }
        
    }
    
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
