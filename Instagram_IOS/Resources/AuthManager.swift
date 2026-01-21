//
//  AuthManager.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/3/26.
//

import FirebaseDatabase
import FirebaseAuth

public class AuthManager{
    static let shared = AuthManager()
    // public
    
    public func registerNewUser(username: String, email: String, password: String, completion: @escaping (Bool)->Void){
        
        // check if username is available
        // check if email is available
    
        DatabaseManager.shared.canCreateNewUser(with: email, username: username){ canCreate in //
            if canCreate{ //
                //create account and link account to the database
            
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                guard error == nil, result != nil else{
                    //firebase auth could not create auth
                    completion(false)
                    return
                }
                // insert into database
                DatabaseManager.shared.insertNewUser(with: email, username: username){ inserted in
                    if inserted {
                        completion(true)
                        return
                    }
                    else{
                        completion(false) //upon failure to insert into the db  
                        return
                    }
                }
                
            }
                
            }
            else {
                //if either the username or the email does not exist
                completion(false)
            }
            
        }
    } //
    
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void){
        if let email = email {
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
           
        }
        else if let username = username{
            print(username)
        }
    }
    
}
