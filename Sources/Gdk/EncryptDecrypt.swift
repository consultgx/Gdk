//
//  File.swift
//  
//
//  Created by G on 2023-03-29.
//

import Foundation
import Security



class EncDecClient {
    
    static func encDecExample() {
        // RSA key pair
        let keySize = 2048
        let privateKeyAttr: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: "com.g.privatekey".data(using: .utf8)!
        ]
        let publicKeyAttr: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: "com.g.publickey".data(using: .utf8)!
        ]
        let keyPairAttr: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: keySize,
            kSecPrivateKeyAttrs as String: privateKeyAttr,
            kSecPublicKeyAttrs as String: publicKeyAttr
        ]
        var error: Unmanaged<CFError>?
        guard let keyPair = SecKeyCreateRandomKey(keyPairAttr as CFDictionary, &error) else {
            print("Error creating key pair: \(error!.takeRetainedValue() as Error)")
            return
        }
        // Encrypt a string using the public key
        let plaintext = "How are you"
        let plaintextData = plaintext.data(using: .utf8)!
        guard let encryptedData = SecKeyCreateEncryptedData(keyPair, .rsaEncryptionOAEPSHA512, plaintextData as CFData, &error) else {
            print("Error encrypting data: \(error!.takeRetainedValue() as Error)")
            return
        }
        let encryptedString = (encryptedData as Data).base64EncodedString()

        // Decrypt the string using the private key
        guard let decryptedData = SecKeyCreateDecryptedData(keyPair, .rsaEncryptionOAEPSHA512, encryptedData as CFData, &error) else {
            print("Error decrypting data: \(error!.takeRetainedValue() as Error)")
            return
        }
        let decryptedString = String(data: decryptedData as Data, encoding: .utf8)!

        print("Original: \(plaintext)")
        print("Encrypted: \(encryptedString)")
        print("Decrypted: \(decryptedString)")

    }
}


class EncDecClient1 {
    
    static func buffers(fromData data: Data, bufferSize: Int) -> [Data] {
        guard data.count > bufferSize else {
          return [data]
        }
        
        var buffers: [Data] = []
        
        for i in 0..<bufferSize {
          let start = i * bufferSize
          
          let lengthOffset = start + bufferSize
          let length = lengthOffset < data.count ? bufferSize : data.count - start
          
          let bufferRange = Range<Data.Index>(NSMakeRange(start, length))!
          buffers.append(data.subdata(in: bufferRange))
        }
        
        return buffers
      }
    
    static func encDecExample() {
        let pubKeyData = Data(base64Encoded: "com.g.publickey")!
            
        let query: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
            ]
            
        var unmanagedError: Unmanaged<CFError>?
            
        guard let publicKey = SecKeyCreateWithData(pubKeyData as CFData, query as CFDictionary, &unmanagedError) else {
            print (unmanagedError!.takeRetainedValue() as Error)
            return
        }
        
        // encrypt
        let input = "How are you".data(using: .utf8)!
        let bufferSize = SecKeyGetBlockSize(publicKey) - 11
        let buffers = buffers(fromData: input, bufferSize: bufferSize)
           
        var encryptedData = Data()
        
        for buffer in buffers {
            var encryptionError: Unmanaged<CFError>?
            
            guard let encryptedBuffer = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, buffer as CFData, &encryptionError) as Data? else {
                print(encryptionError!.takeRetainedValue() as Error)
                return
            }
            
            encryptedData.append(encryptedBuffer)
        }
        let encryptedString = encryptedData.base64EncodedString()
        print(encryptedString)
    }
}


