//
//  PropertyPhotosView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI
import PhotosUI

/// Property photos gallery for documenting deals
struct PropertyPhotosView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photos: [UIImage] = []
    @State private var showingCamera: Bool = false
    @State private var showingPhotoPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Photo Grid
                    if photos.isEmpty {
                        emptyState
                    } else {
                        photoGrid
                    }
                    
                    // Add Photos Section
                    addPhotosSection
                    
                    // Photo Categories
                    photoCategoriesSection
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Property Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textMuted)
            
            Text("No Photos Yet")
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Add photos of the property for your records")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Photo Grid
    
    private var photoGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PHOTOS (\(photos.count))")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(photos.indices, id: \.self) { index in
                    PhotoThumbnail(image: photos[index]) {
                        let idx = index
                        withAnimation {
                            _ = photos.remove(at: idx)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Add Photos Section
    
    private var addPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADD PHOTOS")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 12) {
                PhotoSourceButton(
                    icon: "camera.fill",
                    title: "Camera",
                    color: .blue
                ) {
                    showingCamera = true
                }
                
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: 24))
                        Text("Library")
                            .font(AppFonts.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .onChange(of: selectedItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        photos.append(image)
                    }
                }
                selectedItems = []
            }
        }
    }
    
    // MARK: - Photo Categories
    
    private var photoCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SUGGESTED SHOTS")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: 8) {
                PhotoCategoryRow(icon: "house.fill", title: "Exterior Front")
                PhotoCategoryRow(icon: "house.circle", title: "Exterior Back")
                PhotoCategoryRow(icon: "sofa.fill", title: "Living Areas")
                PhotoCategoryRow(icon: "bed.double.fill", title: "Bedrooms")
                PhotoCategoryRow(icon: "sink.fill", title: "Kitchen")
                PhotoCategoryRow(icon: "shower.fill", title: "Bathrooms")
                PhotoCategoryRow(icon: "wrench.and.screwdriver.fill", title: "Issues/Repairs Needed")
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnail: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .cornerRadius(8)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Photo Source Button

struct PhotoSourceButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(AppFonts.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Photo Category Row

struct PhotoCategoryRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 28)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Image(systemName: "camera")
                .foregroundColor(AppColors.textMuted)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    PropertyPhotosView(viewModel: DealViewModel())
}
