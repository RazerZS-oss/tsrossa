import SwiftUI
import AppKit

public struct TheaterView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Ambient Aura Glow from Album Artwork / Deep Obsidian Background
            if let artwork = vm.currentArtwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 80)
                    .opacity(0.18)
                    .clipped()
            }
            Color.black.opacity(0.85)
            
            VStack(spacing: 0) {
                // TOP HUD TOOLBAR
                HStack(spacing: 16) {
                    // Exit Theater Mode
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.isTheaterMode = false
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                                .font(.system(size: 12, weight: .bold))
                            Text("Exit Theater (Esc)")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Theater Mode Status Indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(TsrossaColors.bitPerfectGold)
                            .frame(width: 7, height: 7)
                        Text("THEATER MODE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.bitPerfectGold)
                        Text("•")
                            .foregroundColor(vm.currentTheme.textMuted)
                        Text("BIT-PERFECT DIRECT COREAUDIO")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.black.opacity(0.40))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Autoplay Infinite Radio Toggle
                    Button(action: {
                        vm.isAutoplayRadio.toggle()
                        vm.showToast(vm.isAutoplayRadio ? "Autoplay Infinite Radio Enabled" : "Autoplay Radio Disabled")
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .semibold))
                            Text(vm.isAutoplayRadio ? "AUTOPLAY ON" : "AUTOPLAY OFF")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(vm.isAutoplayRadio ? vm.currentTheme.onPrimary : vm.currentTheme.textMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(vm.isAutoplayRadio ? vm.currentTheme.primary : Color.white.opacity(0.08))
                        .cornerRadius(18)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Autoplay Infinite Radio (Plays matching lossless music continuously)")
                    
                    // Liked Song Toggle
                    if let cur = engine.currentTrack {
                        let isLiked = vm.isTrackLiked(cur.path)
                        Button(action: {
                            vm.toggleLike(track: cur)
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(isLiked ? Color.red : vm.currentTheme.textSecondary)
                                .frame(width: 34, height: 34)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(isLiked ? "Remove from Liked Songs" : "Save to Liked Songs")
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // MAIN WIDESCREEN CONTENT
                HStack(spacing: 36) {
                    // LEFT COLUMN: Huge Album Artwork & Audiophile Identifiers
                    VStack(spacing: 22) {
                        Spacer(minLength: 10)
                        
                        ZStack {
                            if let artwork = vm.currentArtwork {
                                Image(nsImage: artwork)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 340, height: 340)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                                    )
                                    .shadow(color: vm.currentTheme.primary.opacity(0.45), radius: 36, x: 0, y: 18)
                            } else {
                                TsrossaBrandIcon(size: 340, cornerRadius: 24)
                                    .shadow(color: vm.currentTheme.primary.opacity(0.35), radius: 32, x: 0, y: 16)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text(engine.currentTrack?.title ?? "No Track Selected")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                            
                            Text(engine.subtitleText)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: 400)
                        
                        // Lossless Format & Signal Badges
                        HStack(spacing: 10) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(TsrossaColors.bitPerfectGold)
                                    .frame(width: 6, height: 6)
                                Text(engine.formatBadgeText)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(vm.currentTheme.onPrimaryContainer)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.currentTheme.primaryContainer.opacity(0.75))
                            .cornerRadius(16)
                            
                            if vm.isRamPlayback {
                                Text("RAM PINNED")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(TsrossaColors.audiophileCyan)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(TsrossaColors.audiophileCyan.opacity(0.18))
                                    .cornerRadius(16)
                            }
                            
                            if vm.isExclusiveHogMode {
                                Text("HOG MODE")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(TsrossaColors.bitPerfectGold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(TsrossaColors.bitPerfectGold.opacity(0.18))
                                    .cornerRadius(16)
                            }
                        }
                        
                        Spacer(minLength: 10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // RIGHT COLUMN: Synchronized Real-Time Lyrics or Up Next Queue
                    VStack(spacing: 14) {
                        // Switcher Header: Lyrics vs Queue
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    vm.theaterTabMode = "LYRICS"
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "quote.bubble")
                                    Text("SYNCHRONIZED LYRICS")
                                }
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.theaterTabMode == "LYRICS" ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(vm.theaterTabMode == "LYRICS" ? vm.currentTheme.primary : Color.white.opacity(0.08))
                                .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    vm.theaterTabMode = "QUEUE"
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "music.note.list")
                                    Text("UP NEXT & RADIO")
                                }
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.theaterTabMode == "QUEUE" ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(vm.theaterTabMode == "QUEUE" ? vm.currentTheme.primary : Color.white.opacity(0.08))
                                .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        
                        // Content Pane
                        if vm.theaterTabMode == "LYRICS" {
                            LyricsView(isTheater: true)
                        } else {
                            QueueView(isTheater: true)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 36)
                .frame(maxHeight: .infinity)
                
                // BOTTOM TRANSPORT BAR
                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 1)
                
                TransportBarView()
                    .frame(height: 90)
            }
        }
        .ignoresSafeArea()
    }
}
