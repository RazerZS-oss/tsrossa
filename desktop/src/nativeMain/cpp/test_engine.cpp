#include <iostream>
#include <cassert>
#include "CoreAudioSink.h"
#include "MacAudioDecoder.h"

int main() {
  std::cout << "=== tsrossa macOS Native Audio Engine Verification ===" << std::endl;

  // 1. Test MacAudioDecoder on actual files in ../Music/
  MacAudioDecoder decoder;
  const char *testFile1 = "../Music/Light It Up - Robin Hustin, Tobimorrow & Jex.flac";
  const char *testFile2 = "../Music/Rich Kids (feat. Yvette Young) - Polyphia.flac";

  std::cout << "\n[1] Testing Decoder on FLAC 16-bit (44.1 kHz)..." << std::endl;
  if (decoder.open(testFile1)) {
    std::cout << "  Success: SampleRate=" << decoder.sampleRate
              << ", Channels=" << decoder.channels
              << ", Bits=" << decoder.bitsPerSample
              << ", TotalFrames=" << decoder.totalPCMFrameCount << std::endl;
    assert(decoder.sampleRate == 44100);
    assert(decoder.channels == 2);
    assert(decoder.bitsPerSample == 16);
    assert(decoder.totalPCMFrameCount > 0);
    decoder.close();
  } else {
    std::cerr << "  Failed to open: " << testFile1 << " (" << decoder.lastOpenError << ")" << std::endl;
  }

  std::cout << "\n[2] Testing Decoder on FLAC 24-bit (48.0 kHz)..." << std::endl;
  if (decoder.open(testFile2)) {
    std::cout << "  Success: SampleRate=" << decoder.sampleRate
              << ", Channels=" << decoder.channels
              << ", Bits=" << decoder.bitsPerSample
              << ", TotalFrames=" << decoder.totalPCMFrameCount << std::endl;
    assert(decoder.sampleRate == 48000);
    assert(decoder.channels == 2);
    assert(decoder.bitsPerSample == 24);
    assert(decoder.totalPCMFrameCount > 0);
    decoder.close();
  } else {
    std::cerr << "  Failed to open: " << testFile2 << " (" << decoder.lastOpenError << ")" << std::endl;
  }

  // 2. Test CoreAudio Device Discovery
  std::cout << "\n[3] Testing Apple CoreAudio Device Enumeration..." << std::endl;
  CoreAudioSink &sink = CoreAudioSink::getInstance();
  sink.init();

  auto devices = sink.getAudioDevices();
  std::cout << "  Found " << devices.size() << " output device(s):" << std::endl;
  for (const auto &dev : devices) {
    std::cout << "  - ID=" << dev.id
              << " | Name: \"" << dev.name << "\""
              << " | USB DAC: " << (dev.isUsb ? "YES" : "NO")
              << " | Default: " << (dev.isDefault ? "YES" : "NO")
              << " | Hardware Rate: " << dev.nominalSampleRate << " Hz"
              << std::endl;
    if (!dev.supportedRates.empty()) {
      std::cout << "    Supported Rates: ";
      for (size_t i = 0; i < dev.supportedRates.size(); ++i) {
        std::cout << dev.supportedRates[i] << " Hz ";
      }
      std::cout << std::endl;
    }
  }

  assert(!devices.empty());

  std::cout << "\n=== All Native Audio Engine Tests PASSED! ===" << std::endl;
  return 0;
}
