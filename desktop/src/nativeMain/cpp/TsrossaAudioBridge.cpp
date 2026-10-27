#include "TsrossaAudioBridge.h"
#include "CoreAudioSink.h"
#include <string>
#include <vector>

static std::vector<DeviceInfo> s_cachedDevices;
static std::string s_lastTelemetry;

extern "C" {

bool tsrossa_init(void) {
  return CoreAudioSink::getInstance().init();
}

void tsrossa_shutdown(void) {
  CoreAudioSink::getInstance().shutdown();
}

int tsrossa_get_device_count(void) {
  s_cachedDevices = CoreAudioSink::getInstance().getAudioDevices();
  return (int)s_cachedDevices.size();
}

const char* tsrossa_get_device_name(int index) {
  if (index >= 0 && index < (int)s_cachedDevices.size()) {
    return s_cachedDevices[index].name.c_str();
  }
  return "";
}

uint32_t tsrossa_get_device_id(int index) {
  if (index >= 0 && index < (int)s_cachedDevices.size()) {
    return (uint32_t)s_cachedDevices[index].id;
  }
  return 0;
}

bool tsrossa_get_device_is_usb(int index) {
  if (index >= 0 && index < (int)s_cachedDevices.size()) {
    return s_cachedDevices[index].isUsb;
  }
  return false;
}

bool tsrossa_get_device_is_default(int index) {
  if (index >= 0 && index < (int)s_cachedDevices.size()) {
    return s_cachedDevices[index].isDefault;
  }
  return false;
}

double tsrossa_get_device_sample_rate(int index) {
  if (index >= 0 && index < (int)s_cachedDevices.size()) {
    return s_cachedDevices[index].nominalSampleRate;
  }
  return 0.0;
}

bool tsrossa_select_device(uint32_t deviceId) {
  return CoreAudioSink::getInstance().selectDevice((AudioDeviceID)deviceId);
}

bool tsrossa_play(const char *path) {
  if (!path) return false;
  return CoreAudioSink::getInstance().playTrack(path);
}

void tsrossa_pause(void) {
  CoreAudioSink::getInstance().pause();
}

void tsrossa_resume(void) {
  CoreAudioSink::getInstance().resume();
}

void tsrossa_stop(void) {
  CoreAudioSink::getInstance().stop();
}

bool tsrossa_seek(double seconds) {
  return CoreAudioSink::getInstance().seek(seconds);
}

bool tsrossa_is_playing(void) {
  return CoreAudioSink::getInstance().isPlaying();
}

double tsrossa_get_current_time(void) {
  return CoreAudioSink::getInstance().getCurrentTimeSeconds();
}

double tsrossa_get_total_duration(void) {
  return CoreAudioSink::getInstance().getTotalDurationSeconds();
}

const char* tsrossa_get_telemetry_json(void) {
  s_lastTelemetry = CoreAudioSink::getInstance().getTelemetryJson();
  return s_lastTelemetry.c_str();
}

}
