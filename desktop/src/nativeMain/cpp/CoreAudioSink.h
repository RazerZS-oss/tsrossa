#pragma once

#include <CoreAudio/CoreAudio.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

#include <atomic>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "MacAudioCommon.h"
#include "MacAudioDecoder.h"

struct DeviceInfo {
  AudioDeviceID id;
  std::string uid;
  std::string name;
  bool isUsb;
  bool isDefault;
  Float64 nominalSampleRate;
  std::vector<Float64> supportedRates;
};

class CoreAudioSink {
public:
  static CoreAudioSink &getInstance() {
    static CoreAudioSink instance;
    return instance;
  }

  CoreAudioSink();
  ~CoreAudioSink();

  bool init();
  void shutdown();

  std::vector<DeviceInfo> getAudioDevices();
  bool selectDevice(AudioDeviceID deviceId);
  AudioDeviceID getActiveDevice() const { return m_activeDevice; }

  bool playTrack(const std::string &filePath);
  void pause();
  void resume();
  void stop();
  bool seek(double seconds);

  bool isPlaying() const { return m_isPlaying.load(); }
  double getCurrentTimeSeconds() const;
  double getTotalDurationSeconds() const;

  std::string getTelemetryJson();

private:
  static OSStatus renderCallback(
      void *inRefCon,
      AudioUnitRenderActionFlags *ioActionFlags,
      const AudioTimeStamp *inTimeStamp,
      UInt32 inBusNumber,
      UInt32 inNumberFrames,
      AudioBufferList *ioData);

  OSStatus handleRender(
      AudioUnitRenderActionFlags *ioActionFlags,
      const AudioTimeStamp *inTimeStamp,
      UInt32 inNumberFrames,
      AudioBufferList *ioData);

  bool setupAudioUnit(AudioDeviceID deviceId, Float64 sampleRate, UInt32 channels, UInt32 bitDepth);
  void teardownAudioUnit();

  bool setDeviceSampleRate(AudioDeviceID deviceId, Float64 targetRate);
  bool setHogMode(AudioDeviceID deviceId, bool enable);

  AudioDeviceID m_activeDevice = kAudioObjectUnknown;
  AudioComponentInstance m_audioUnit = nullptr;

  std::atomic<bool> m_isPlaying{false};
  std::atomic<bool> m_isPaused{false};
  std::atomic<uint64_t> m_currentFrameIndex{0};
  uint64_t m_totalFrames = 0;
  uint32_t m_sampleRate = 0;
  uint32_t m_channels = 0;
  uint32_t m_bitsPerSample = 0;

  std::vector<int32_t> m_pcmBuffer;
  bool m_isMemoryLocked = false;
  std::string m_currentFilePath;

  std::mutex m_engineMutex;
};
