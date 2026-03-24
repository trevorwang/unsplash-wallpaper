//
//  SettingsView.swift
//  Unsplash Wallpaper
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("unsplashAccessKey") private var accessKey = ""
    @AppStorage("autoStart") private var autoStart = false
    @AppStorage("downloadLocation") private var downloadLocation = ""
    @AppStorage("imageQuality") private var imageQuality = ImageQuality.regular
    @AppStorage("changeInterval") private var changeInterval = ChangeInterval.hourly
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                accessKey: $accessKey,
                autoStart: $autoStart,
                downloadLocation: $downloadLocation
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            AppearanceSettingsView(
                imageQuality: $imageQuality,
                changeInterval: $changeInterval
            )
            .tabItem {
                Label("Appearance", systemImage: "photo")
            }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @Binding var accessKey: String
    @Binding var autoStart: Bool
    @Binding var downloadLocation: String
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unsplash API Access Key")
                        .font(.headline)
                    Text("Required for accessing Unsplash API. Get your key from unsplash.com/developers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Access Key", text: $accessKey)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.bottom, 8)
                
                Toggle("Start at login", isOn: $autoStart)
                
                HStack {
                    Text("Download location:")
                    Spacer()
                    Text(downloadLocation.isEmpty ? "Downloads" : downloadLocation)
                        .foregroundColor(.secondary)
                    Button("Choose...") {
                        chooseDownloadLocation()
                    }
                }
            }
        }
        .padding()
    }
    
    private func chooseDownloadLocation() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            downloadLocation = panel.url?.path ?? ""
        }
    }
}

struct AppearanceSettingsView: View {
    @Binding var imageQuality: ImageQuality
    @Binding var changeInterval: ChangeInterval
    
    var body: some View {
        Form {
            Section {
                Picker("Image Quality", selection: $imageQuality) {
                    ForEach(ImageQuality.allCases) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
                .pickerStyle(.segmented)
                
                Text("Higher quality images take longer to download and use more storage.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
            
            Section {
                Picker("Auto-change interval", selection: $changeInterval) {
                    ForEach(ChangeInterval.allCases) { interval in
                        Text(interval.description).tag(interval)
                    }
                }
                
                Text("Automatically change wallpaper at the selected interval.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("Unsplash Wallpaper")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("A beautiful wallpaper app powered by Unsplash")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack(spacing: 16) {
                Link("Unsplash", destination: URL(string: "https://unsplash.com")!)
                Link("GitHub", destination: URL(string: "https://github.com")!)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum ImageQuality: String, CaseIterable, Identifiable {
    case small = "Small"
    case regular = "Regular"
    case full = "Full"
    
    var id: String { rawValue }
}

enum ChangeInterval: String, CaseIterable, Identifiable {
    case never = "Never"
    case fifteenMinutes = "15 minutes"
    case thirtyMinutes = "30 minutes"
    case hourly = "1 hour"
    case daily = "Daily"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .never: return "Never"
        case .fifteenMinutes: return "Every 15 minutes"
        case .thirtyMinutes: return "Every 30 minutes"
        case .hourly: return "Every hour"
        case .daily: return "Every day"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .never: return 0
        case .fifteenMinutes: return 900
        case .thirtyMinutes: return 1800
        case .hourly: return 3600
        case .daily: return 86400
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
