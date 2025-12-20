//
//  AnimatedComponents.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

// MARK: - Animated Number Display

/// Animates number changes with counting effect
struct AnimatedNumber: View {
    let value: Double
    let format: NumberFormat
    let color: Color
    let font: Font
    
    @State private var displayValue: Double = 0
    
    enum NumberFormat {
        case currency
        case percent
        case decimal(places: Int)
        case integer
    }
    
    var formattedValue: String {
        switch format {
        case .currency:
            return CurrencyFormatter.format(displayValue)
        case .percent:
            return String(format: "%.1f%%", displayValue)
        case .decimal(let places):
            return String(format: "%.\(places)f", displayValue)
        case .integer:
            return String(Int(displayValue))
        }
    }
    
    var body: some View {
        Text(formattedValue)
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText(value: displayValue))
            .onChange(of: value) { _, newValue in
                withAnimation(.spring(duration: 0.3)) {
                    displayValue = newValue
                }
            }
            .onAppear {
                displayValue = value
            }
    }
}

// MARK: - Pulsing Dot

/// Animated pulsing indicator
struct PulsingDot: View {
    let color: Color
    @State private var isPulsing: Bool = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// MARK: - Shimmer Effect

/// Skeleton loading shimmer effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: phase
                    )
                    .onAppear { phase = 1 }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Scale Button Style

/// Button style with scale animation on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Bounce Effect

struct BounceEffect: ViewModifier {
    @State private var isBouncing: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBouncing ? 1.05 : 1.0)
            .animation(
                Animation.interpolatingSpring(stiffness: 300, damping: 10)
                    .repeatCount(1),
                value: isBouncing
            )
            .onTapGesture {
                isBouncing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isBouncing = false
                }
            }
    }
}

// MARK: - Slide In Modifier

struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible: Bool = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : 20)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }
}

// MARK: - Glow Effect

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Gradient Border

struct GradientBorder: ViewModifier {
    let colors: [Color]
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
    }
}

extension View {
    func gradientBorder(
        colors: [Color] = [AppColors.primaryTeal, AppColors.primaryNavy],
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16
    ) -> some View {
        modifier(GradientBorder(colors: colors, lineWidth: lineWidth, cornerRadius: cornerRadius))
    }
}

#Preview("Animated Number") {
    VStack(spacing: 20) {
        AnimatedNumber(
            value: 1234.56,
            format: .currency,
            color: .green,
            font: .largeTitle
        )
        
        HStack {
            PulsingDot(color: .green)
            Text("Live")
        }
    }
    .padding()
    .background(AppColors.background)
}
