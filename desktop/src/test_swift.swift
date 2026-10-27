import Foundation

print("=== Sequential Dynamic Sample Rate Switching Test ===")
_ = tsrossa_init()

let track1 = "../Music/Light It Up - Robin Hustin, Tobimorrow & Jex.flac"
print("\n--- Track 1 (16-bit / 44.1 kHz) ---")
if tsrossa_play(track1) {
    print("Telemetry Track 1:\n", String(cString: tsrossa_get_telemetry_json()))
    Thread.sleep(forTimeInterval: 0.5)
    print("Played for:", tsrossa_get_current_time(), "s")
    tsrossa_stop()
}

let track2 = "../Music/Rich Kids (feat. Yvette Young) - Polyphia.flac"
print("\n--- Track 2 (24-bit / 48.0 kHz) Dynamic Rate Switch ---")
if tsrossa_play(track2) {
    print("Telemetry Track 2:\n", String(cString: tsrossa_get_telemetry_json()))
    Thread.sleep(forTimeInterval: 0.5)
    print("Played for:", tsrossa_get_current_time(), "s")
    tsrossa_stop()
}

tsrossa_shutdown()
print("\n=== Dynamic Rate Switching Test Completed Successfully! ===")
