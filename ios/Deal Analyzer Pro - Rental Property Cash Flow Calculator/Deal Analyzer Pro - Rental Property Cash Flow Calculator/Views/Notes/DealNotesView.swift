//
//  DealNotesView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI
import PhotosUI

/// Notes and media attached to a deal
struct DealNotesView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var noteText: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showingCamera: Bool = false
    @State private var showingVoiceRecorder: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Notes Text Area
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NOTES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextEditor(text: $viewModel.deal.notes)
                            .frame(minHeight: 150)
                            .padding(12)
                            .background(AppColors.inputBackground)
                            .cornerRadius(12)
                            .foregroundColor(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                        
                        // Character count
                        Text("\(viewModel.deal.notes.count) characters")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Quick Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK NOTES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            QuickNoteButton(text: "📍 Great location") {
                                appendNote("📍 Great location")
                            }
                            
                            QuickNoteButton(text: "🔧 Needs repairs") {
                                appendNote("🔧 Needs repairs")
                            }
                            
                            QuickNoteButton(text: "✅ Seller motivated") {
                                appendNote("✅ Seller motivated")
                            }
                            
                            QuickNoteButton(text: "⚠️ Verify numbers") {
                                appendNote("⚠️ Verify numbers")
                            }
                            
                            QuickNoteButton(text: "🏫 Good schools") {
                                appendNote("🏫 Good schools")
                            }
                            
                            QuickNoteButton(text: "📈 Rising area") {
                                appendNote("📈 Rising area")
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Media Section (Placeholder)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PHOTOS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if selectedImages.isEmpty {
                            // Empty state
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.textMuted)
                                
                                Text("No photos added")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(AppColors.inputBackground)
                            .cornerRadius(12)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                Button(action: {
                                                    selectedImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(.white)
                                                        .shadow(radius: 2)
                                                }
                                                .offset(x: 35, y: -35)
                                            )
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                                Label("Add from Library", systemImage: "photo.fill.on.rectangle.fill")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.primaryTeal)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.primaryTeal.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .onChange(of: selectedPhotos) { _, newItems in
                                Task {
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            selectedImages.append(image)
                                        }
                                    }
                                    selectedPhotos = []
                                }
                            }
                            
                            Button(action: { showingCamera = true }) {
                                Label("Camera", systemImage: "camera.fill")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.primaryTeal)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.primaryTeal.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Voice Notes (Placeholder)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("VOICE NOTES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.textMuted)
                            
                            Text("Tap to record a voice note")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(AppColors.inputBackground)
                        .cornerRadius(12)
                        .onTapGesture { showingVoiceRecorder = true }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Checklist
                    DealChecklistSection(viewModel: viewModel)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Notes & Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    private func appendNote(_ text: String) {
        if viewModel.deal.notes.isEmpty {
            viewModel.deal.notes = text
        } else {
            viewModel.deal.notes += "\n" + text
        }
    }
}

// MARK: - Quick Note Button

struct QuickNoteButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(AppColors.inputBackground)
                .cornerRadius(10)
        }
    }
}

// MARK: - Deal Checklist Section

struct DealChecklistSection: View {
    @Bindable var viewModel: DealViewModel
    
    let checklistItems = [
        "Verify rent with market comps",
        "Order property inspection",
        "Get insurance quotes",
        "Review comparable sales",
        "Check HOA documents",
        "Verify property taxes",
        "Get contractor estimates",
        "Check crime statistics",
        "Research school ratings",
        "Drive by the property"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DUE DILIGENCE CHECKLIST")
                .font(AppFonts.metricLabel)
                .foregroundColor(AppColors.textSecondary)
            
            ForEach(checklistItems, id: \.self) { item in
                ChecklistRow(
                    title: item,
                    isChecked: viewModel.deal.checklistItems.contains(item)
                ) {
                    if viewModel.deal.checklistItems.contains(item) {
                        viewModel.deal.checklistItems.removeAll { $0 == item }
                    } else {
                        viewModel.deal.checklistItems.append(item)
                    }
                }
            }
            
            // Progress
            let completed = viewModel.deal.checklistItems.count
            let total = checklistItems.count
            
            HStack {
                ProgressView(value: Double(completed), total: Double(total))
                    .tint(AppColors.successGreen)
                
                Text("\(completed)/\(total)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct ChecklistRow: View {
    let title: String
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isChecked ? AppColors.successGreen : AppColors.textMuted)
                
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(isChecked ? AppColors.textMuted : AppColors.textPrimary)
                    .strikethrough(isChecked)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    DealNotesView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
