//
//  ContentView.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 2/29/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - FilteredImageView

struct FilteredImageView: View {

  // MARK: - Private

  private typealias FilterType = FilteredImageModel.FilterType
  @ObservedObject private var model: FilteredImageModel
  private var pointSize: Binding<CGFloat>
  private var filterType: Binding<FilterType>

  init(model: FilteredImageModel = .init()) {
    filterType = model.filterType.makeBinding()
    pointSize = model.pointSize.makeBinding()
    self.model = model
  }

  // MARK: - View

  var body: some View {
    VStack(spacing: 8.0) {
      GeometryReader { geometry in
        Image(uiImage: self.model.image)
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .sideEffect {
          self.model.bounds.value = .init(
            origin: .zero,
            size: .init(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
          )
        }
        .overlay(
          self.model.progress.map { progress in
            AnyView(ZStack {
              Color(UIColor.white.withAlphaComponent(0.8))
              Text("Loading \(progress)%").font(.title)
            })
          } ?? AnyView(EmptyView())
        )
      }
      Picker(selection: self.filterType, label: EmptyView()) {
        ForEach(0..<FilterType.allCases.count) { index in
          Text(String(describing: FilterType.allCases[index])).tag(FilterType.allCases[index])
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      HStack {
        Text("Font")
        Slider(value: self.pointSize, in: (2.0...24.0))
        Text("\(self.pointSize.wrappedValue)pt")
      }
    }
    .padding()
  }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    FilteredImageView()
  }
}
