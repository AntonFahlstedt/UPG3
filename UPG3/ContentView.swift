//
//  ContentView.swift
//  UPG3
//
//  Created by Anton Fahlstedt on 2023-12-18.
//

import SwiftUI

struct CatFact: Codable {
    var fact: String
}

struct ContentView: View {
    @State private var fact = ""
    @State private var imageData: Data?
    @State private var reloadButtonPressed = false

    var body: some View {
        VStack {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }

            Text(fact)
                .padding()
                .font(.system(size: 20))

            Button("New fact") {
                reloadButtonPressed.toggle()
            }
            .font(.system(size: 20))
            .buttonStyle(MyButtonStyle())
        }
        .onAppear() {
            Task {
                await loadCatData()
            }
        }
        .onChange(of: reloadButtonPressed) { newValue in
            if newValue {
                Task {
                    await loadCatData()
                    reloadButtonPressed = false
                }
            }
        }
    }

    func loadCatData() async {
        do {
            let factURL = URL(string: "https://catfact.ninja/fact")!

            let (factData, _) = try await URLSession.shared.data(from: factURL)

            let factDecoder = JSONDecoder()
            let catFact = try factDecoder.decode(CatFact.self, from: factData)

            fact = catFact.fact
            try await loadImageData()
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    func loadImageData() async throws {
        let imageURL = URL(string: "https://cataas.com/cat")!
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        self.imageData = imageData
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(60)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
