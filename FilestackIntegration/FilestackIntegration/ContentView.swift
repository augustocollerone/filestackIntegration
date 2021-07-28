//
//  ContentView.swift
//  FilestackIntegration
//
//  Created by Augusto Collerone on 28/07/2021.
//

import SwiftUI
import Filestack
import FilestackSDK

struct ContentView: View {
    @State var showingSheet: Bool = false
    
    var body: some View {
        Button("Open image picker") {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            ImagePicker(
                selectedImage: { image in
                    uploadToFilestack(image: image)
                },
                sourceType: .photoLibrary
            )
        }
            .padding()
    }
    
    func uploadToFilestack(image: UIImage) {
        let apiKey = "ARB6RcxehSe22Dr3JzFSUz"
        let appSecret = ""
        
        let policy = Policy(expiry: .distantFuture, call: [.pick, .read, .stat, .write, .writeURL, .store, .convert, .remove, .exif])
        
        guard let security = try? Security(policy: policy, appSecret: appSecret) else {
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) as NSData? else {
            return
        }
        
        let config = Filestack.Config.builder
            .with(callbackURLScheme: "glideForms")
            .with(imageURLExportPreset: .current)
            .with(maximumSelectionLimit: 1)
            .with(availableCloudSources: [])
            .with(availableLocalSources: [.camera, .photoLibrary])
            .build()
        
        let client = Client(apiKey: apiKey, security: security, config: config)
        let storageOptions = StorageOptions(location: .s3, mimeType: "image/jpeg", access: .public)
        let uploadOptions = UploadOptions(preferIntelligentIngestion: true, startImmediately: true, deleteTemporaryFilesAfterUpload: true, storeOptions: storageOptions)
        
        client.uploadData(using: imageData, options: uploadOptions) { response in
            
            print("*AC response: ", response)
            print("*AC response error: ", response.error)

            if let url = response.json?["url"] as? String {
                print("*AC response URL: ", url)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
