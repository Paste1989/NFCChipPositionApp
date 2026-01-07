//
//  NFCChipPositionView.swift
//  NFCChipPositionDemoApp
//
//  Created by Saša Brezovac on 30.10.2025..
//

import SwiftUI

struct NFCChipPositionView: View {
    @StateObject var viewModel = NFCChipPositionViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("NFC position detector")
                .font(.title)
            Text("Machine String: \(viewModel.machine)")
            Text("Model: \(viewModel.marketingName)")
            Text("NFC position: \(viewModel.nfcPosition.rawValue)")
                .bold()
                .foregroundColor(viewModel.nfcPosition == NFCPosition.noNFC ? .red : .primary)
                .padding(.vertical)
            
            if viewModel.nfcPosition != NFCPosition.noNFC {
                ZStack {
                    Rectangle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .frame(width: 200, height: 400)
                    Circle()
                        .frame(width: 50, height: 50)
                        .offset(y: viewModel.animateOffset)
                        .animation(.spring(), value: viewModel.animateOffset)
                }
            }
            
            Button {
                viewModel.refresh()
            } label: {
                Text("Refresh")
            }
        }
        .padding()
        .onAppear(perform: viewModel.refresh)
    }
}

#Preview {
    NFCChipPositionView(viewModel: .init())
}
