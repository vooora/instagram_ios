//
//  DatabaseManager.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/3/26.
//


import FirebaseDatabase

public class DatabaseManager{
    static let shared = DatabaseManager()
    
    let database = Database.database(
        url: "https://instagram-ios-2c294-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).reference()


    
    public func canCreateNewUser(with email: String, username: String, completion: (Bool)-> Void){
        
        completion(true)
        
    }
    
    public func insertNewUser(with email: String, username: String, completion: @escaping (Bool)->Void){
        database.child(email.safeDatabaseKey()).setValue(["username": username]){error, _ in
            if error == nil {
                //completion = true
                completion(true)
                return
            }
            else{
                //failed
                completion(false)
                return
            }
        }
        
    }
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        database.child("posts").observeSingleEvent(of: .value) { snapshot in
            var posts: [Post] = []

            guard let value = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            for (key, postData) in value {
                if let postDict = postData as? [String: Any],
                   let post = Post(id: key, dictionary: postDict) {
                    posts.append(post)
                }
            }

            completion(posts.reversed()) // newest first
        }
    }


    
}
