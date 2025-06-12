//
//  ShapesView.swift
//  editTheBox
//
//  Created by Shelly on 10/06/2025.
//help from chatGPT and "creating 3D shapes" from apple
import SwiftUI
import RealityKit
// A view that displays a 3D box entity and allows the user to control its position and color.
struct ShapesView: View {
    // Controls the horizontal (X-axis) position of the box
    @State private var xOffset: Float = 0.0
    //Controls the vertical (Y-axis) position of the box
    @State private var yOffset: Float = 0.0
    //The currently selected color for the box via a SwiftUI ColorPicker
    @State private var selectedColor: Color = .white
    //this changes its size
    @State private var shapeScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            RealityView { content in
                // Add the cube entity when the view is first created
                addGeometryShapes(to: content)
            } update: { content in
                updateBoxPositionAndColor()
            }
            .frame(height: 300)
            
            // Sliders and Color Picker UI
            VStack(spacing: 20) {
                // Reset button
                Button("Reset") {
                    resetCubeProperties()
                }
                .padding(.top, 10)
                .bold()
                .buttonStyle(.borderedProminent)
                
                VStack {
                    // X-axis slider control
                    Text("X Position: \(xOffset, specifier: "%.2f")")
                        .bold()
                    Slider(value: $xOffset, in: -0.5...0.5, step: 0.01)
                }
                //Y-axis slider control
                VStack {
                    Text("Y Position: \(yOffset, specifier: "%.2f")")
                        .bold()
                    Slider(value: $yOffset, in: -0.5...0.5, step: 0.01)
                }
                VStack {
                    Text("Shape Size")
                        .bold()
                    Slider(value: $shapeScale, in: 0.5...2.0, step: 0.1)
                }
                .padding()
                
                HStack{
                    Text("Cube Colour:")
                        .font(.title3)
                        .bold()
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                        .padding(.vertical, 4)
                }
            }
            .font(.title3)
            .fontWeight(.bold)
            .padding()
        }
    }
    //Adds the cube entity to the RealityView content
    func addGeometryShapes(to content: RealityViewContent) {
        content.add(Self.boxEntity)
    }
    //updates the cube's position and color based on SwiftUI state
    
    func updateBoxPositionAndColor() {
        //Update position
        Self.boxEntity.position = [xOffset, yOffset, 0]
        // Update scale
        Self.boxEntity.setScale([Float(shapeScale), Float(shapeScale), Float(shapeScale)], relativeTo: nil)
        
        // Convert the SwiftUI Color to UIColor, which SimpleMaterial accepts
        let uiColor = UIColor(selectedColor)
        
        // Update the box's material to use the selected color
        if var model = Self.boxEntity.components[ModelComponent.self] {
            model.materials = [
                SimpleMaterial(color: uiColor, isMetallic: false)
            ]
            Self.boxEntity.components.set(model)
        }
    }
    func spinCube() { //not sully working but i wanted it to
        // Start from current rotation (should be identity after reset)
        let currentRotation = Self.boxEntity.transform.rotation
        
        // Spin an additional 180 degrees on Y-axis relative to current rotation
        let spinIncrement = simd_quatf(angle: .pi, axis: [0, 1, 0])
        let targetRotation = simd_mul(currentRotation, spinIncrement)
        
        let spinTransform = Transform(
            scale: [1, 1, 1],
            rotation: targetRotation,
            translation: [0, 0, 0]
        )
        
        Self.boxEntity.move(to: spinTransform, relativeTo: nil, duration: 0.6, timingFunction: .easeInOut)
    }

    
    // Resets position and color to defaults
    func resetCubeProperties() {
        // Spin the cube visibly after pressing reset
        spinCube()
        
        //reset state
        xOffset = 0.0
        yOffset = 0.0
        selectedColor = .white
        shapeScale = 1.0
    }
}
#Preview(windowStyle: .automatic) {
    ShapesView()
}
