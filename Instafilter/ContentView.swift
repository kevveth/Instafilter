//
//  ContentView.swift
//  Instafilter
//
//  Created by Kenneth Oliver Rathbun on 5/3/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                }
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                    
                    Spacer()
                    
                    // share the picture
                }
            }
            .padding([.bottom, .horizontal])
            .navigationTitle("Instafilter")
        }
    }
    
    func changeFilter () { }
}

#Preview {
    ContentView()
}
