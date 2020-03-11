//
//  FilteredImageModel.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 3/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//


import SwiftUI
import Combine

class FilteredImageModel: ObservableObject {

  // MARK: - FilterType

  enum FilterType: CaseIterable, CustomStringConvertible {
    case none, asciiMono, asciiColor, emoji, emojiFlags
    private static let asciiSet = try! FileService.read(type: TileSet.self, from: "asciiSet.json")
    private static let emojiSet = try! FileService.read(type: TileSet.self, from: "emojiSet.json")
    private static let emojiFlagsSet = try! FileService.read(type: TileSet.self, from: "emojiFlagsSet.json")
    var tileSet: TileSet {
      switch self {
      case .none, .asciiMono, .asciiColor: return Self.asciiSet
      case .emoji: return Self.emojiSet
      case .emojiFlags: return Self.emojiFlagsSet
      }
    }
    var description: String {
      switch self {
      case .none: return "None"
      case .asciiMono: return "ASCII Mono"
      case .asciiColor: return "ASCII Color"
      case .emoji: return "Emoji"
      case .emojiFlags: return "Emoji flags"
      }
    }
  }

  // MARK: - Outputs

  @Published var image: UIImage = .init()
  @Published var progress: Int? = nil

  // MARK: - Inputs

  let inputImage = CurrentValueSubject<UIImage, Never>(#imageLiteral(resourceName: "a"))
  let pointSize = CurrentValueSubject<CGFloat, Never>(22)
  let filterType = CurrentValueSubject<FilterType, Never>(.asciiMono)
  let bounds = CurrentValueSubject<CGRect, Never>(.zero)

  // MARK: - Instance

  private var subscriptions: Set<AnyCancellable> = []
  init() {
    let progressSubject = CurrentValueSubject<Int?, Never>(nil)

    progressSubject
      .receive(on: RunLoop.main)
      .assign(to: \.progress, on: self)
      .store(in: &subscriptions)

    progressSubject
      .filter { $0 == nil }
      .removeDuplicates()
      .map { [inputImage, filterType, pointSize, bounds] _ -> AnyPublisher<UIImage, Never> in
        Publishers.CombineLatest4(
          inputImage,
          filterType,
          pointSize,
          bounds
        )
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .removeDuplicates(by: {
          $0.0 == $1.0 && $0.1 == $1.1 && $0.2 == $1.2
        })
        .map { combined -> UIImage in
          progressSubject.value = 0
          let (inputImage, filterType, pointSize, bounds) = combined
          let tileset: TileSet
          switch filterType {
          case .none:
            progressSubject.value = nil
            return inputImage
          case .asciiColor, .asciiMono:
            tileset = .makeAscii(points: pointSize)
          case .emoji:
            tileset = .makeEmoji(points: pointSize)
          case .emojiFlags:
            tileset = .makeEmojiFlags(points: pointSize)
          }
          let tileSize = tileset.calculateSize(points: pointSize)
          let columns = Int((bounds.size.width / tileSize.width).rounded(.up))
          let rows = Int((bounds.size.height / tileSize.height).rounded(.up))
          let resizedBounds = CGRect(origin: .zero, size: .init(width: columns, height: rows))
          let format = UIGraphicsImageRendererFormat()
          format.scale = 1
          let minimumDimension = min(inputImage.size.width, inputImage.size.height)
          let croppedImage = UIGraphicsImageRenderer(size: .init(width: minimumDimension, height: minimumDimension), format: format).image { _ in
            inputImage.draw(at: .init(
              x: (minimumDimension - inputImage.size.width) / 2,
              y: (minimumDimension - inputImage.size.height) / 2)
            )
          }
          let image = UIGraphicsImageRenderer(bounds: resizedBounds, format: format).image { context in
            croppedImage.draw(in: resizedBounds)
          }
          guard let pixelBuffer = PixelBuffer(image: image) else {
            progressSubject.value = nil
            return UIImage()
          }
          let output = UIGraphicsImageRenderer(bounds: bounds).image { context in
            UIColor.black.setFill()
            UIBezierPath(rect: bounds).fill()
            (0..<rows).forEach { row in
              progressSubject.value = Int(Double(row)/Double(rows)*100)
              (0..<columns).forEach { column in
                let point = CGPoint(
                  x: CGFloat(column) * tileSize.width,
                  y: CGFloat(row) * tileSize.height
                )
                let letter: NSMutableAttributedString
                switch filterType {
                case .none:
                  letter = NSMutableAttributedString()
                case .asciiColor:
                  let (brightness, color) = pixelBuffer.brightnessAndColor(x: column, y: row)
                  let tile = tileset.tile(for: brightness)
                  letter = NSMutableAttributedString(
                    string: tile.symbol,
                    attributes: [ .font: UIFont.systemFont(ofSize: pointSize), .foregroundColor: color]
                  )
                case .asciiMono:
                  let brightness = pixelBuffer.brightness(x: column, y: row)
                  let tile = tileset.tile(for: brightness)
                  letter = NSMutableAttributedString(
                    string: tile.symbol,
                    attributes: [ .font: UIFont.systemFont(ofSize: pointSize), .foregroundColor: UIColor.white]
                  )
                case .emoji, .emojiFlags:
                  let (r,g,b,_) = pixelBuffer.rgba(x: column, y: row) ?? (0,0,0,1)
                  let tile = tileset.tile(r: r, g: g, b: b)
                  letter = NSMutableAttributedString(
                    string: tile.symbol,
                    attributes: [ .font: UIFont.systemFont(ofSize: pointSize), .foregroundColor: UIColor.white]
                  )
                }
                letter.draw(at: point)
              }
            }
          }
          progressSubject.value = nil
          return output
        }
        .eraseToAnyPublisher()
      }
      .switchToLatest()
      .receive(on: RunLoop.main)
      .assign(to: \.image, on: self)
      .store(in: &subscriptions)
  }
}
