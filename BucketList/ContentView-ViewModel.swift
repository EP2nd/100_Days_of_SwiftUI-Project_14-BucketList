//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Edwin Przeźwiecki Jr. on 08/02/2023.
//

import LocalAuthentication
import MapKit

extension ContentView {
    
    @MainActor class ViewModel: ObservableObject {
        
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        
        @Published var isUnlocked = false
        /// Challenge 2:
        @Published var authenticationFailed = false
        @Published var errorMessage: String = "Authentication error"
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    
                    /// Challenge 2:
                    Task { @MainActor in
                        if success {
                            // await MainActor.run {
                            self.isUnlocked = true
                            // }
                        } else {
                            self.errorMessage = "We could not authenticate you.\nPlease try again."
                            self.authenticationFailed = true
                        }
                    }
                }
            } else {
                Task { @MainActor in
                    self.errorMessage = "Your device does not support biometric authentication."
                    self.authenticationFailed = true
                }
            }
        }
    }
}
