//
//  Tile.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 3/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import UIKit

// MARK: - Tile

struct Tile: Codable {
  var symbol: String
  var size: CGSize
  var brightness: CGFloat
  var r,g,b: UInt8
  lazy var color: UIColor = {
    UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
  }()

  init?(value: Int, size: CGFloat, weight: UIFont.Weight = .medium) {
    guard let letter = UnicodeScalar(value)?.escaped(asASCII: true) else {
      return nil
    }
    self.init(symbol: letter, size: size, weight: weight)
  }
  
  init?(symbol: String, size: CGFloat, weight: UIFont.Weight = .medium) {
    self.symbol = symbol
    let attributedLetter = NSAttributedString(string: symbol, attributes: [
      .font: UIFont.monospacedSystemFont(ofSize: size, weight: weight),
      .foregroundColor: UIColor.white
    ])
    let image = UIGraphicsImageRenderer(size: attributedLetter.size()).image { context in
      attributedLetter.draw(at: .zero)
    }
    self.size = image.size
    let ciImage = CIImage(image: image)
    guard let brightness = ciImage?.brightness,
      let (r,g,b) = ciImage?.averageRGB else {
      return nil
    }
    self.brightness = brightness
    self.r = r
    self.g = g
    self.b = b
  }
}
