//
//  ContentView.swift
//  Instafilter
//
//  Created by Kenneth Oliver Rathbun on 5/3/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 50.0
    @State private var filterScale = 0.5
    
    @State private var selectedImage: PhotosPickerItem?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilters = false
    
    @State private var beginImage: CIImage?
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedImage) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .onChange(of: selectedImage, loadImage)
                
                Spacer()
                
                if selectedImage != nil {
                    VStack {
                        let inputKeys = currentFilter.inputKeys
                        
                        if inputKeys.contains(kCIInputIntensityKey) {
                            HStack{
                                Text("Intensity")
                                Slider(value: $filterIntensity)
                                    .onChange(of: filterIntensity, applyProcessing)
                            }
                        }
                        
                        if inputKeys.contains(kCIInputRadiusKey) {
                            HStack{
                                Text("Radius")
                                Slider(value: $filterRadius)
                                    .onChange(of: filterRadius, applyProcessing)
                            }
                        }
                        
                        if inputKeys.contains(kCIInputScaleKey) {
                            HStack{
                                Text("Scale")
                                Slider(value: $filterScale)
                                    .onChange(of: filterScale, applyProcessing)
                            }
                        }
                        
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Button("Change Filter", action: changeFilter)
                            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                                Button("Edges") { setFilter(CIFilter.edges()) }
                                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                                Button("Vignette") { setFilter(CIFilter.vignette()) }
                                Button("Cancel", role: .cancel) { }
                            }
                        
                        Spacer()
                        
                        if let processedImage {
                            ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                        }
                    }
                }
            }
            .tint(.purple)
            .padding([.bottom, .horizontal])
            .navigationTitle("Instafilter")
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)}

        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    func changeFilter () {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedImage?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    @MainActor 
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        if filterCount >= 3 {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
