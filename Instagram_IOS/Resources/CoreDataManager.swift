//
//  CoreDataManager.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/15/26.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Create model programmatically
        let model = NSManagedObjectModel()
        
        // FeedPost Entity
        let feedPostEntity = NSEntityDescription()
        feedPostEntity.name = "FeedPostEntity"
        feedPostEntity.managedObjectClassName = "FeedPostEntity"
        
        var properties: [NSAttributeDescription] = []
        
        let postIdAttr = NSAttributeDescription()
        postIdAttr.name = "postId"
        postIdAttr.attributeType = .stringAttributeType
        postIdAttr.isOptional = false
        properties.append(postIdAttr)
        
        let userNameAttr = NSAttributeDescription()
        userNameAttr.name = "userName"
        userNameAttr.attributeType = .stringAttributeType
        userNameAttr.isOptional = false
        properties.append(userNameAttr)
        
        let userImageAttr = NSAttributeDescription()
        userImageAttr.name = "userImage"
        userImageAttr.attributeType = .stringAttributeType
        userImageAttr.isOptional = true
        properties.append(userImageAttr)
        
        let postImageAttr = NSAttributeDescription()
        postImageAttr.name = "postImage"
        postImageAttr.attributeType = .stringAttributeType
        postImageAttr.isOptional = false
        properties.append(postImageAttr)
        
        let likeCountAttr = NSAttributeDescription()
        likeCountAttr.name = "likeCount"
        likeCountAttr.attributeType = .integer32AttributeType
        likeCountAttr.isOptional = false
        properties.append(likeCountAttr)
        
        let likedByUserAttr = NSAttributeDescription()
        likedByUserAttr.name = "likedByUser"
        likedByUserAttr.attributeType = .booleanAttributeType
        likedByUserAttr.isOptional = false
        properties.append(likedByUserAttr)
        
        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false
        properties.append(timestampAttr)
        
        feedPostEntity.properties = properties
        
        // Reel Entity
        let reelEntity = NSEntityDescription()
        reelEntity.name = "ReelEntity"
        reelEntity.managedObjectClassName = "ReelEntity"
        
        var reelProperties: [NSAttributeDescription] = []
        
        let reelIdAttr = NSAttributeDescription()
        reelIdAttr.name = "reelId"
        reelIdAttr.attributeType = .stringAttributeType
        reelIdAttr.isOptional = false
        reelProperties.append(reelIdAttr)
        
        let reelUserNameAttr = NSAttributeDescription()
        reelUserNameAttr.name = "userName"
        reelUserNameAttr.attributeType = .stringAttributeType
        reelUserNameAttr.isOptional = false
        reelProperties.append(reelUserNameAttr)
        
        let reelUserImageAttr = NSAttributeDescription()
        reelUserImageAttr.name = "userImage"
        reelUserImageAttr.attributeType = .stringAttributeType
        reelUserImageAttr.isOptional = true
        reelProperties.append(reelUserImageAttr)
        
        let reelVideoAttr = NSAttributeDescription()
        reelVideoAttr.name = "reelVideo"
        reelVideoAttr.attributeType = .stringAttributeType
        reelVideoAttr.isOptional = false
        reelProperties.append(reelVideoAttr)
        
        let reelLikeCountAttr = NSAttributeDescription()
        reelLikeCountAttr.name = "likeCount"
        reelLikeCountAttr.attributeType = .integer32AttributeType
        reelLikeCountAttr.isOptional = false
        reelProperties.append(reelLikeCountAttr)
        
        let reelLikedByUserAttr = NSAttributeDescription()
        reelLikedByUserAttr.name = "likedByUser"
        reelLikedByUserAttr.attributeType = .booleanAttributeType
        reelLikedByUserAttr.isOptional = false
        reelProperties.append(reelLikedByUserAttr)
        
        let reelTimestampAttr = NSAttributeDescription()
        reelTimestampAttr.name = "timestamp"
        reelTimestampAttr.attributeType = .dateAttributeType
        reelTimestampAttr.isOptional = false
        reelProperties.append(reelTimestampAttr)
        
        reelEntity.properties = reelProperties
        
        model.entities = [feedPostEntity, reelEntity]
        
        // Create container with custom model
        let container = NSPersistentContainer(name: "InstagramDataModel", managedObjectModel: model)
        
        container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data store failed to load: \(error.localizedDescription)")
                // Don't fatal error - allow app to continue with empty store
            } else {
                print("Core Data store loaded successfully")
            }
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data context saved successfully")
            } catch {
                print("Error saving Core Data context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - FeedPost Operations
    
    func saveFeedPosts(_ posts: [FeedPost]) {
        let context = persistentContainer.viewContext
        
        // Delete old posts
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FeedPostEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting old feed posts: \(error.localizedDescription)")
        }
        
        // Save new posts
        for post in posts {
            let entity = NSEntityDescription.entity(forEntityName: "FeedPostEntity", in: context)!
            let feedPostEntity = NSManagedObject(entity: entity, insertInto: context)
            
            feedPostEntity.setValue(post.postId, forKey: "postId")
            feedPostEntity.setValue(post.userName, forKey: "userName")
            feedPostEntity.setValue(post.userImage, forKey: "userImage")
            feedPostEntity.setValue(post.postImage, forKey: "postImage")
            feedPostEntity.setValue(post.likeCount, forKey: "likeCount")
            feedPostEntity.setValue(post.likedByUser, forKey: "likedByUser")
            feedPostEntity.setValue(Date(), forKey: "timestamp")
        }
        
        saveContext()
        print("Saved \(posts.count) feed posts to Core Data")
    }
    
    func fetchFeedPosts() -> [FeedPost] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FeedPostEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            let posts = results.compactMap { entity -> FeedPost? in
                guard let postId = entity.value(forKey: "postId") as? String,
                      let userName = entity.value(forKey: "userName") as? String,
                      let postImage = entity.value(forKey: "postImage") as? String,
                      let likeCount = entity.value(forKey: "likeCount") as? Int,
                      let likedByUser = entity.value(forKey: "likedByUser") as? Bool else {
                    return nil
                }
                
                let userImage = entity.value(forKey: "userImage") as? String
                
                return FeedPost(
                    postId: postId,
                    userName: userName,
                    userImage: userImage,
                    postImage: postImage,
                    likeCount: likeCount,
                    likedByUser: likedByUser
                )
            }
            print("Fetched \(posts.count) feed posts from Core Data")
            return posts
        } catch {
            print("Error fetching feed posts from Core Data: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Reel Operations
    
    func saveReels(_ reels: [Reel]) {
        let context = persistentContainer.viewContext
        
        // Delete old reels
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ReelEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting old reels: \(error.localizedDescription)")
        }
        
        // Save new reels
        for reel in reels {
            let entity = NSEntityDescription.entity(forEntityName: "ReelEntity", in: context)!
            let reelEntity = NSManagedObject(entity: entity, insertInto: context)
            
            reelEntity.setValue(reel.reelId, forKey: "reelId")
            reelEntity.setValue(reel.userName, forKey: "userName")
            reelEntity.setValue(reel.userImage, forKey: "userImage")
            reelEntity.setValue(reel.reelVideo, forKey: "reelVideo")
            reelEntity.setValue(reel.likeCount, forKey: "likeCount")
            reelEntity.setValue(reel.likedByUser, forKey: "likedByUser")
            reelEntity.setValue(Date(), forKey: "timestamp")
        }
        
        saveContext()
        print("Saved \(reels.count) reels to Core Data")
    }
    
    func fetchReels() -> [Reel] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ReelEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            let reels = results.compactMap { entity -> Reel? in
                guard let reelId = entity.value(forKey: "reelId") as? String,
                      let userName = entity.value(forKey: "userName") as? String,
                      let reelVideo = entity.value(forKey: "reelVideo") as? String,
                      let likeCount = entity.value(forKey: "likeCount") as? Int,
                      let likedByUser = entity.value(forKey: "likedByUser") as? Bool else {
                    return nil
                }
                
                let userImage = entity.value(forKey: "userImage") as? String
                
                return Reel(
                    reelId: reelId,
                    userName: userName,
                    userImage: userImage,
                    reelVideo: reelVideo,
                    likeCount: likeCount,
                    likedByUser: likedByUser
                )
            }
            print("Fetched \(reels.count) reels from Core Data")
            return reels
        } catch {
            print("Error fetching reels from Core Data: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - NSManagedObject Subclasses

class FeedPostEntity: NSManagedObject {
    @NSManaged var postId: String
    @NSManaged var userName: String
    @NSManaged var userImage: String?
    @NSManaged var postImage: String
    @NSManaged var likeCount: Int32
    @NSManaged var likedByUser: Bool
    @NSManaged var timestamp: Date
}

class ReelEntity: NSManagedObject {
    @NSManaged var reelId: String
    @NSManaged var userName: String
    @NSManaged var userImage: String?
    @NSManaged var reelVideo: String
    @NSManaged var likeCount: Int32
    @NSManaged var likedByUser: Bool
    @NSManaged var timestamp: Date
}
