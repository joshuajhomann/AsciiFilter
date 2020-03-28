//
//  FileService.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 3/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Foundation

// MARK: - FileService

enum FileService {
  static func write<Encoded: Encodable>(_ encodable: Encoded, to filename: String) throws {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let fileURL = documentDirectory.appendingPathComponent(filename)
    let data = try JSONEncoder().encode(encodable)
    try data.write(to: fileURL)
  }

  static func read<Decoded: Decodable>(type: Decoded.Type, from filename: String) throws -> Decoded  {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let fileURL = documentDirectory.appendingPathComponent(filename)
    let data = try Data(contentsOf: fileURL)
    return try JSONDecoder().decode(type, from: data)
  }

  static func read<Decoded: Decodable>(type: Decoded.Type, name filename: String, extension: String) throws -> Decoded  {

    let fileURL = Bundle.main.url(forResource: filename, withExtension: `extension`)
    let data = try Data(contentsOf: fileURL ?? URL(string:"a")!)
    return try JSONDecoder().decode(type, from: data)
  }
}
