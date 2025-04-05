//
//  RealtimeMonitor.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 06/04/25.
//

//import Foundation
//import FirebaseDatabase
//
//class FirebaseManager {
//    static let shared = FirebaseManager()
//
//    private var ref: DatabaseReference!
//
//    private init() {
//        Database.database().isPersistenceEnabled = true
//        ref = Database.database().reference()
//    }
//
//    func saveGameData(gameData: GameData, gameId: String) {
////        let firebaseData = GameDataForFirebase(gameData: gameData)
//
//        // Convert GameData to a JSON-compatible dictionary
//        guard let jsonData = try? JSONEncoder().encode(gameData) else {
//            print("Error encoding game data")
//            return
//        }
//        
//        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
//            print("Error serializing game data")
//            return
//        }
//
//        // Save to Firebase
//        ref.child("games").child(gameId).setValue(json) { (error, ref) in
//            if let error = error {
//                print("Data could not be saved: \(error).")
//            } else {
//                print("Data saved successfully!")
//            }
//        }
//    }
//
//    func observeGameData(gameId: String, completion: @escaping (GameData?) -> Void) {
//        ref.child("games").child(gameId).observe(.value) { (snapshot) in
//            guard let value = snapshot.value as? [String: Any] else {
//                completion(nil)
//                return
//            }
//            
//            guard let jsonData = try? JSONSerialization.data(withJSONObject: value) else {
//                completion(nil)
//                return
//            }
//            
//            guard let firebaseData = try? JSONDecoder().decode(GameDataForFirebase.self, from: jsonData) else {
//                completion(nil)
//                return
//            }
//            
//            var gameData = GameData()
//            gameData.playerDeck = firebaseData.playerDeck
//            gameData.currentPlayer = Player(rawValue: firebaseData.currentPlayer) ?? Player.player1
//            gameData.allPlayers = firebaseData.allPlayers.map { Player(rawValue: $0) ?? Player.player1 }
//
//            var stash: [Player: [CardDetail]] = [:]
//            firebaseData.currentStash.forEach { (key, value) in
//                stash[Player(rawValue: key) ?? Player.player1] = value
//            }
//            gameData.currentStash = stash
//            
//            completion(gameData)
//        }
//    }
//
//    func removeObserver(gameId: String) {
//        ref.child("games").child(gameId).removeAllObservers()
//    }
//}
