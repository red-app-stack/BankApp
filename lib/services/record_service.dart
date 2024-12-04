// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';

// class AudioRecorder implements Record {
//   final _audioRecorder = Record();
//   bool _isRecording = false;

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   Future<bool> hasPermission() async {
//     final status = await Permission.microphone.status;
//     if (!status.isGranted) {
//       final result = await Permission.microphone.request();
//       return result.isGranted;
//     }
//     return true;
//   }

//   @override
//   Future<void> start({
//     String? path,
//     AudioEncoder encoder = AudioEncoder.aacLc,
//     int bitRate = 128000,
//     int sampleRate = 44100,
//     int numChannels = 2,
//     InputDevice? device,
//   }) async {
//     if (await hasPermission()) {
//       final localPath = await _localPath;
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
//       await _audioRecorder.start(
//         path: path ?? '$localPath/$fileName',
//         encoder: encoder,
//         bitRate: bitRate,
//         samplingRate: sampleRate,
//         numChannels: numChannels,
//         device: device,
//       );
//       _isRecording = true;
//     }
//   }

//   @override
//   Future<String?> stop() async {
//     if (!_isRecording) return null;
//     final path = await _audioRecorder.stop();
//     _isRecording = false;
//     return path;
//   }

//   @override
//   Future<void> pause() => _audioRecorder.pause();

//   @override
//   Future<void> resume() => _audioRecorder.resume();

//   @override
//   Future<bool> isRecording() => _audioRecorder.isRecording();

//   @override
//   Future<bool> isPaused() => _audioRecorder.isPaused();

//   @override
//   Future<Amplitude> getAmplitude() => _audioRecorder.getAmplitude();

//   @override
//   Future<void> dispose() => _audioRecorder.dispose();

//   @override
//   Future<List<InputDevice>> listInputDevices() => _audioRecorder.listInputDevices();

//   bool get isRecording => _isRecording;
// }
