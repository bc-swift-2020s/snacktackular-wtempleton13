//
//  Photo.swift
//  Snacktacular
//
//  Created by Will Templeton on 4/19/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String //universal unique identifier
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date ]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("Error could not convert data to image format")
            return completed(false )
        }
        documentUUID = UUID().uuidString
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData)
        
        uploadTask.observe(.success) { (snapshot) in
            let dataToSave = self.dictionary
            // if we have saved a record, we'll have a document ID
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("**** ERROR: updating document \(self.documentUUID) in \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    completed(true)
                }
            }
            
            uploadTask.observe(.failure) { (snapshot) in
                if let error = snapshot.error {
                    print("🚫 ERROR: upload task for file \(self.documentUUID) failed in spot \(spot.documentID)")
                }
                return completed(false)
            }
            // Create dictionary representing data to save
            
        }
    }
}

