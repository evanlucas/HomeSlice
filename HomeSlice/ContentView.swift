//
//  ContentView.swift
//  HomeSlice
//
//  Created by Evan Lucas on 10/29/20.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var home = Home()

  var body: some View {
    Text("Hello, world!")
        .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
