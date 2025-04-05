//
//  RealtimeMonitor.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 06/04/25.
//

import Foundation
import FirebaseDatabase

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private var ref: DatabaseReference!

    private init() {
        Database.database().isPersistenceEnabled = true
        ref = Database.database(url: "https://bluff-master-1-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    }

    // Save game data to Firebase
    func saveGameData(gameData: GameData, gameId: String) {
        do {
            let jsonData = try JSONEncoder().encode(gameData)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

            guard let json = jsonObject else {
                print("Error: Failed to convert encoded GameData to JSON dictionary")
                return
            }

            ref.child("games").child(gameId).setValue(json) { error, _ in
                if let error = error {
                    print("❌ Failed to save data: \(error)")
                } else {
                    print("✅ Game data saved successfully for gameId: \(gameId)")
                }
            }
        } catch {
            print("❌ Error during encoding or serialization: \(error)")
        }
    }

    // Observe game data from Firebase and decode into GameData
    func observeGameData(gameId: String, completion: @escaping (GameData?) -> Void) {
        ref.child("games").child(gameId).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("⚠️ No data found for gameId: \(gameId)")
                completion(nil)
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let decodedGameData = try JSONDecoder().decode(GameData.self, from: jsonData)
                completion(decodedGameData)
            } catch {
                print("❌ Failed to decode GameData: \(error)")
                completion(nil)
            }
        })
    }

    // Remove Firebase observers
    func removeObserver(gameId: String) {
        ref.child("games").child(gameId).removeAllObservers()
        print("🔌 Observers removed for gameId: \(gameId)")
    }
}
