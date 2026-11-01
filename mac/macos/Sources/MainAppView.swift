import SwiftUI
import AppKit

public struct MainAppView: View {
    @ObservedObject private var engine = AudioEngine.shared
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var updater = UpdateManager.shared
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 1060
            
            ZStack {
                // Material You Dynamic Ambient Background
                backgroundLayer
                
                // 1. Mini-Player Mode (Pop-out Floating Window)
                if vm.isMiniPlayerMode {
                    MiniPlayerView()
                        .transition(.scale.combined(with: .opacity))
                }
                // 2. Fullscreen Theater Mode (Cmd + F)
                else if vm.isTheaterMode {
                    TheaterView()
                        .transition(.opacity)
                }
                // 3. Full 3-Column Aether Desktop Workspace
                else {
                    VStack(spacing: 0) {
                        // Upper Workspace: Sidebar + Center Stage + Right Inspector
                        HStack(spacing: 0) {
                            // Column 1: Left Navigation Sidebar
                            SidebarView()
                                .frame(width: 236)
                            
                            // Vertical Divider
                            Rectangle()
                                .fill(vm.currentTheme.outline.opacity(0.14))
                                .frame(width: 1)
                            
                            // Column 2: Main Center Stage
                            VStack(spacing: 0) {
                                TopBarView()
                                    .padding(.horizontal, 22)
                                    .padding(.top, 14)
                                    .padding(.bottom, 12)
                                
                                Divider()
                                    .background(vm.currentTheme.outline.opacity(0.12))
                                
                                ZStack {
                                    switch vm.activeTab {
                                    case .library:
                                        LibraryView()
                                    case .nowPlaying:
                                        NowPlayingView()
                                    case .playlist:
                                        QueueView()
                                    case .settings:
                                        SettingsView()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Column 3: Collapsible Right Inspector (Lyrics, Signal/EQ, Queue)
                            if vm.showRightInspector && !isCompact {
                                Rectangle()
                                    .fill(vm.currentTheme.outline.opacity(0.14))
                                    .frame(width: 1)
                                
                                InspectorView()
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Rectangle()
                            .fill(vm.currentTheme.outline.opacity(0.18))
                            .frame(height: 1)
                        
                        // Persistent Bottom Player Transport Bar
                        TransportBarView()
                            .frame(height: 86)
                    }
                }
                
                // Modals & Overlays
                if vm.showNewPlaylistModal {
                    Color.black.opacity(0.72)
                        .ignoresSafeArea()
                        .onTapGesture { vm.showNewPlaylistModal = false }
                    
                    NewPlaylistModalView()
                        .transition(.scale.combined(with: .opacity))
                }
                
                if vm.showSaveQueueModal {
                    Color.black.opacity(0.72)
                        .ignoresSafeArea()
                        .onTapGesture { vm.showSaveQueueModal = false }
                    
                    SaveQueueModalView()
                        .transition(.scale.combined(with: .opacity))
                }
                
                if vm.showTelemetry {
                    Color.black.opacity(0.72)
                        .ignoresSafeArea()
                        .onTapGesture { vm.showTelemetry = false }
                    
                    TelemetryModalView()
                        .transition(.scale.combined(with: .opacity))
                }
                
                if !vm.toastMessage.isEmpty {
                    toastOverlay
                }
            }
        }
        .frame(minWidth: 960, minHeight: 640)
        .onAppear {
            TsrossaBrandLogo.applyMacDockIcon()
            vm.loadInitialMusicDirectory()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                updater.checkForUpdates(userInitiated: false)
            }
        }
    }
    
    // Ambient Background Layer
    @ViewBuilder
    private var backgroundLayer: some View {
        if vm.bgCanvasMode == "BLACK" {
            Color.black.ignoresSafeArea()
        } else if vm.bgCanvasMode == "AURA", let artwork = vm.currentArtwork {
            Color.clear
                .background(vm.currentTheme.surfaceContainerLowest)
                .overlay(
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 85)
                        .opacity(0.32)
                        .saturation(1.35)
                )
                .clipped()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        vm.currentTheme.surfaceContainerLowest,
                        vm.currentTheme.surface
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [vm.currentTheme.primary.opacity(0.18), Color.clear],
                    center: .topLeading,
                    startRadius: 40,
                    endRadius: 680
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [vm.currentTheme.tertiary.opacity(0.10), Color.clear],
                    center: .bottomTrailing,
                    startRadius: 60,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
        }
    }
    
    // Floating Toast Notification Overlay
    private var toastOverlay: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(vm.currentTheme.primary)
                Text(vm.toastMessage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(vm.currentTheme.surfaceContainerHigh)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(vm.currentTheme.primary.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.40), radius: 10, x: 0, y: 5)
            .padding(.top, 22)
            .transition(.move(edge: .top).combined(with: .opacity))
            
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
