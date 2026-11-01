import SwiftUI
import AppKit

public struct NewPlaylistModalView: View {
    @ObservedObject private var vm = AppViewModel.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CREATE PLAYLIST OR SMART FILTER")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                    Text("New Playlist Module")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                }
                Spacer()
                Button(action: { vm.showNewPlaylistModal = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 1. Playlist Name Input
            VStack(alignment: .leading, spacing: 6) {
                Text("PLAYLIST NAME")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("e.g., Polyphia, Late Night 24-Bit, Favorites...", text: $vm.newPlaylistName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .padding(10)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                    )
            }
            
            // 2. Smart Auto-Filter Keyword
            VStack(alignment: .leading, spacing: 6) {
                Text("SMART AUTO-FILTER KEYWORD / ARTIST (OPTIONAL)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("e.g., Polyphia (auto-includes all matching tracks)", text: $vm.newPlaylistKeyword)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .padding(10)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                    )
                
                // 1-Click Quick-Pick Artist Chips from Library
                if !vm.distinctArtists.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Text("Quick Fill Artist:")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                            
                            ForEach(vm.distinctArtists.prefix(12), id: \.self) { artist in
                                Button(action: {
                                    vm.newPlaylistName = artist
                                    vm.newPlaylistKeyword = artist
                                }) {
                                    Text(artist)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(vm.newPlaylistKeyword == artist ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 4)
                                        .background(vm.newPlaylistKeyword == artist ? vm.currentTheme.primary : Color.white.opacity(0.08))
                                        .cornerRadius(8)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 2)
                    }
                }
            }
            
            // 3. Select / Toggle Specific Tracks from Library
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("MANUAL TRACK SELECTION (\(vm.newPlaylistSelectedPaths.count) SELECTED)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                    Spacer()
                    if !vm.newPlaylistSelectedPaths.isEmpty {
                        Button(action: { vm.newPlaylistSelectedPaths.removeAll() }) {
                            Text("Clear Selection")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(vm.tracks) { t in
                            let isChecked = vm.newPlaylistSelectedPaths.contains(t.path) ||
                                (!vm.newPlaylistKeyword.trimmingCharacters(in: .whitespaces).isEmpty &&
                                 (t.artist.localizedCaseInsensitiveContains(vm.newPlaylistKeyword) ||
                                  t.title.localizedCaseInsensitiveContains(vm.newPlaylistKeyword)))
                            Button(action: {
                                if vm.newPlaylistSelectedPaths.contains(t.path) {
                                    vm.newPlaylistSelectedPaths.remove(t.path)
                                } else {
                                    vm.newPlaylistSelectedPaths.insert(t.path)
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isChecked ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                                    Text(t.title)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(vm.currentTheme.textPrimary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(t.artist)
                                        .font(.system(size: 11))
                                        .foregroundColor(vm.currentTheme.textSecondary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(isChecked ? vm.currentTheme.primaryContainer.opacity(0.30) : Color.white.opacity(0.03))
                                .cornerRadius(8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(height: 170)
                .padding(6)
                .background(Color.black.opacity(0.22))
                .cornerRadius(10)
            }
            
            // Modal Action Buttons
            HStack {
                Button(action: { vm.showNewPlaylistModal = false }) {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: { vm.createPlaylistFromModal() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Create & Open Playlist")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(vm.currentTheme.onPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(vm.currentTheme.primary)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
            }
        }
        .padding(24)
        .frame(width: 540)
        .background(vm.currentTheme.surfaceContainerHigh)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(vm.currentTheme.outline.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.55), radius: 30, x: 0, y: 16)
    }
}

public struct SaveQueueModalView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("SAVE QUEUE AS PLAYLIST")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                    Text("Convert Active Queue to Playlist")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                }
                Spacer()
                Button(action: { vm.showSaveQueueModal = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 1. Playlist Name Input
            VStack(alignment: .leading, spacing: 6) {
                Text("PLAYLIST NAME")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("e.g., My Up Next Mix, Evening Queue...", text: $vm.saveQueuePlaylistName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .padding(10)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                    )
            }
            
            // 2. Track List Summary
            VStack(alignment: .leading, spacing: 6) {
                let count = (engine.currentTrack != nil ? 1 : 0) + vm.upNextQueue.count
                Text("TRACKS TO INCLUDE (\(count) TRACKS)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                ScrollView {
                    LazyVStack(spacing: 4) {
                        if let current = engine.currentTrack {
                            HStack(spacing: 10) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.primary)
                                Text("Now Playing: \(current.title)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                    .lineLimit(1)
                                Spacer()
                                Text(current.artist)
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(vm.currentTheme.primaryContainer.opacity(0.25))
                            .cornerRadius(8)
                        }
                        
                        ForEach(Array(vm.upNextQueue.enumerated()), id: \.element.id) { idx, t in
                            HStack(spacing: 10) {
                                Text("#\(idx + 1)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(vm.currentTheme.primary)
                                    .frame(width: 24, alignment: .leading)
                                Text(t.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                    .lineLimit(1)
                                Spacer()
                                Text(t.artist)
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(height: 160)
                .padding(6)
                .background(Color.black.opacity(0.22))
                .cornerRadius(10)
            }
            
            // Modal Action Buttons
            HStack {
                Button(action: { vm.showSaveQueueModal = false }) {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: { vm.saveCurrentQueueAsPlaylist() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.rectangle.on.rectangle")
                        Text("Save as New Playlist")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(vm.currentTheme.onPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(vm.currentTheme.primary)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
            }
        }
        .padding(24)
        .frame(width: 520)
        .background(vm.currentTheme.surfaceContainerHigh)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(vm.currentTheme.outline.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.55), radius: 30, x: 0, y: 16)
    }
}
