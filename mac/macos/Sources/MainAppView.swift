import SwiftUI
import AppKit

public struct MainAppView: View {
    @ObservedObject private var engine = AudioEngine.shared
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var updater = UpdateManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Material You / Monet Ambient Background
            backgroundLayer
            
            // Main Architecture
            if vm.isTheaterMode {
                TheaterView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    // Upper Workspace: Left Navigation Sidebar + Content Area
                    HStack(spacing: 0) {
                        SidebarView()
                            .frame(width: 236)
                        
                        Rectangle()
                            .fill(vm.currentTheme.outline.opacity(0.18))
                            .frame(width: 1)
                        
                        VStack(spacing: 0) {
                            TopBarView()
                                .padding(.horizontal, 28)
                                .padding(.top, 18)
                                .padding(.bottom, 14)
                            
                            Divider()
                                .background(vm.currentTheme.outline.opacity(0.14))
                            
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Rectangle()
                        .fill(vm.currentTheme.outline.opacity(0.22))
                        .frame(height: 1)
                    
                    // Persistent Bottom Transport Bar
                    TransportBarView()
                        .frame(height: 90)
                }
            }
            
            // New Playlist Modal (Cmd + N)
            if vm.showNewPlaylistModal {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showNewPlaylistModal = false }
                
                NewPlaylistModalView()
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Save Active Queue as Playlist Modal
            if vm.showSaveQueueModal {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showSaveQueueModal = false }
                
                SaveQueueModalView()
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Hardware Diagnostics & Telemetry Modal (Cmd + D)
            if vm.showTelemetry {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showTelemetry = false }
                
                TelemetryModalView()
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Toast Notification Overlay
            if !vm.toastMessage.isEmpty {
                toastOverlay
            }
        }
        .frame(minWidth: 980, minHeight: 680)
        .onAppear {
            TsrossaBrandLogo.applyMacDockIcon()
            vm.loadInitialMusicDirectory()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                updater.checkForUpdates(userInitiated: false)
            }
        }
    }
    
    // =========================================================================
    // AMBIENT BACKGROUND
    // =========================================================================
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
                    colors: [vm.currentTheme.primary.opacity(0.16), Color.clear],
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
    
    // =========================================================================
    // TOAST OVERLAY
    // =========================================================================
    private var toastOverlay: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(vm.currentTheme.primary)
                Text(vm.toastMessage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(vm.currentTheme.surfaceContainerHigh)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(vm.currentTheme.primary.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.45), radius: 12, x: 0, y: 6)
            .padding(.top, 24)
            .transition(.move(edge: .top).combined(with: .opacity))
            
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
