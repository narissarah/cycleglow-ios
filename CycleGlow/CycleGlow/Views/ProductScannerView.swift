import SwiftUI
import PhotosUI

/// Product scanner view with camera capture and ingredient analysis
struct ProductScannerView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var cameraController = CameraController()
    @State private var novaService = NovaAPIService()
    
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var analysis: ProductAnalysis?
    @State private var showingResults = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Phase banner
                    phaseBanner
                    
                    // Scanner hero
                    scannerHero
                    
                    // Action buttons
                    actionButtons
                    
                    // Last scan result
                    if let analysis = analysis {
                        resultCard(analysis)
                    }
                    
                    // How it works
                    howItWorks
                }
                .padding(.bottom, 30)
            }
            .background(
                Theme.backgroundPink.ignoresSafeArea()
            )
            .navigationTitle("Scanner")
            .sheet(isPresented: $showingCamera) {
                cameraSheet
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        capturedImage = image
                        await analyzeImage(image)
                    }
                }
            }
        }
    }
    
    // MARK: - Phase Banner
    
    private var phaseBanner: some View {
        HStack {
            Image(systemName: viewModel.currentPhase.icon)
                .foregroundColor(viewModel.currentPhase.color)
            Text("Scanning for \(viewModel.currentPhase.rawValue) Phase")
                .font(.subheadline.bold())
                .foregroundColor(viewModel.currentPhase.color)
            Spacer()
            Text("Day \(viewModel.currentDay)")
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(viewModel.currentPhase.color.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Scanner Hero
    
    private var scannerHero: some View {
        VStack(spacing: 12) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.purple.opacity(0.1))
                        .frame(height: 200)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.purple)
                        
                        Text("Scan Your Skincare")
                            .font(.title3.bold())
                        
                        Text("Take a photo of any product to see if it's right for your current cycle phase")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }
            }
            
            if novaService.isAnalyzing {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(Theme.purple)
                    Text("Analyzing ingredients...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showingCamera = true
            } label: {
                Label("Camera", systemImage: "camera.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.purple)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                showingPhotoPicker = true
            } label: {
                Label("Gallery", systemImage: "photo.on.rectangle")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .foregroundColor(Theme.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .disabled(novaService.isAnalyzing)
    }
    
    // MARK: - Results Card
    
    private func resultCard(_ analysis: ProductAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with overall rating
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.productName)
                        .font(.headline)
                    Text(analysis.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                overallBadge(analysis.overallRating)
            }
            
            Divider()
            
            // Ingredient list
            Text("Ingredients Analysis")
                .font(.subheadline.bold())
            
            ForEach(analysis.ingredients) { ingredient in
                ingredientRow(ingredient)
            }
            
            // Powered by label
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                    Text("Powered by Amazon Nova")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func ingredientRow(_ ingredient: AnalyzedIngredient) -> some View {
        HStack(spacing: 10) {
            Image(systemName: ingredient.status.icon)
                .foregroundColor(ingredient.status.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(ingredient.name)
                        .font(.caption.bold())
                    Text("• \(ingredient.category.rawValue)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Text(ingredient.reason)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(ingredient.status.label)
                .font(.caption2.bold())
                .foregroundColor(ingredient.status.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(ingredient.status.color.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    private func overallBadge(_ status: IngredientStatus) -> some View {
        VStack(spacing: 2) {
            Image(systemName: status.icon)
                .font(.title2)
                .foregroundColor(status.color)
            Text(status.label)
                .font(.caption2.bold())
                .foregroundColor(status.color)
        }
        .padding(10)
        .background(status.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - How It Works
    
    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How It Works")
                .font(.subheadline.bold())
            
            step(number: "1", icon: "camera.fill", text: "Take a photo of your skincare product")
            step(number: "2", icon: "cpu", text: "Amazon Nova AI reads the ingredient list")
            step(number: "3", icon: "sparkles", text: "We match ingredients to your cycle phase")
            step(number: "4", icon: "checkmark.circle.fill", text: "Get green/yellow/red recommendations")
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private func step(number: String, icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.purple)
                .frame(width: 28, height: 28)
                .background(Theme.purple.opacity(0.12))
                .clipShape(Circle())
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Camera Sheet
    
    private var cameraSheet: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if cameraController.isAuthorized {
                CameraView(session: cameraController.session)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button("Cancel") {
                            cameraController.stopSession()
                            showingCamera = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                        
                        // Capture button
                        Button {
                            Task {
                                if let image = await cameraController.capturePhoto() {
                                    capturedImage = image
                                    cameraController.stopSession()
                                    showingCamera = false
                                    await analyzeImage(image)
                                }
                            }
                        } label: {
                            Circle()
                                .fill(.white)
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.5), lineWidth: 4)
                                        .frame(width: 82, height: 82)
                                )
                        }
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        Color.clear
                            .frame(width: 60, height: 44)
                            .padding()
                    }
                    .padding(.bottom, 30)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Camera access required")
                        .foregroundColor(.white)
                    Text("Go to Settings → CycleGlow → Camera")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button("Close") {
                        showingCamera = false
                    }
                    .foregroundColor(Theme.purple)
                    .padding(.top)
                }
            }
        }
        .task {
            await cameraController.requestPermission()
            cameraController.setupSession()
            cameraController.startSession()
        }
    }
    
    // MARK: - Analysis
    
    private func analyzeImage(_ image: UIImage) async {
        withAnimation {
            analysis = nil
        }
        
        let result = await novaService.analyzeProduct(image: image, phase: viewModel.currentPhase)
        
        withAnimation(.spring(response: 0.5)) {
            analysis = result
        }
    }
}
