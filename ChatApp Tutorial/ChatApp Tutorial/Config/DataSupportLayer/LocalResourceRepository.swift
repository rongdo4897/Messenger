//
//  LocalResourceRepository.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 09/06/2021.
//

import Foundation

class LocalResourceRepository {
    static let userDefault = UserDefaults.standard
    
    static func setUserLocally(user: User?) {
        guard let user = user else {
            userDefault.removeObject(forKey: Constants.kCurrentUser)
            return
        }
        do {
            try userDefault.setObject(user, forKey: Constants.kCurrentUser)
        } catch {
            
        }
    }
    
    static func getUserLocally() -> User? {
        do {
            let data = try userDefault.getObject(forKey: Constants.kCurrentUser, castTo: User.self)
            return data
        } catch {
            return nil
        }
    }
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }

    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"

    var errorDescription: String? {
        rawValue
    }
}

