//
//  PixelBuffer.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 3/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import UIKit

// MARK: - PixelBuffer

class PixelBuffer {
  
  // MARK: - Private

  private let cfData:CFData
  private let pointer: UnsafePointer<UInt8>
  private let bytesPerRow: Int
  private let width: Int
  private let height: Int

  // MARK: - Instance

  init?(image: UIImage) {
    guard let cgImage = image.cgImage,
      let cfData = cgImage.dataProvider?.data,
      let pointer = CFDataGetBytePtr(cfData) else {
        return nil
    }
    assert(cgImage.bitsPerPixel == 32)
    bytesPerRow = cgImage.bytesPerRow
    self.cfData = cfData
    self.pointer = pointer
    width = Int(image.size.width)
    height = Int(image.size.height)
  }

  func rgba(x: Int, y: Int) -> (UInt8, UInt8, UInt8, UInt8)? {
    guard (0..<width) ~= x && (0..<height) ~= y else {
      return nil
    }
    let bytesPerPixel = 4
    let offset = (x * bytesPerPixel + y * bytesPerRow)
    return (pointer[offset], pointer[offset + 1], pointer[offset + 2], pointer[offset + 3])
  }

  func brightnessAndColor(x: Int, y: Int) -> (CGFloat, UIColor) {
    guard let (r,g,b,_) = rgba(x: x, y: y) else {
      return (.zero, .black)
    }
    return (
      (CGFloat(r) / 255) * 0.229 + (CGFloat(g) / 255) * 0.587 + (CGFloat(b) / 255) * 0.114,
      UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    )
  }

  func brightness(x: Int, y: Int) -> CGFloat {
    guard let (r,g,b,_) = rgba(x: x, y: y) else {
      return .zero
    }
    return (CGFloat(r) / 255) * 0.229 + (CGFloat(g) / 255) * 0.587 + (CGFloat(b) / 255) * 0.114
  }
}
