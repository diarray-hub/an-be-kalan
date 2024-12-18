import "dart:convert";
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:literacy_app/constant.dart' show asrModelApiUri, asrModelApiToken;

/// Sends an audio file to the ASR model for inference
/// and returns the transcribed text.
///
/// This function checks the file extension to ensure it's either a `.flac` or `.wav`
/// format before proceeding. It then reads the file and sends it as a POST request
/// to the ASR model API. If the request is successful, it returns the transcribed
/// text. If the service is unavailable, it retries the request.
///
/// Args:
///   filePath (String): The path to the audio file to be transcribed.
///
/// Returns:
///   Future<String?>: The transcribed text from the ASR model if successful, or
///   `null` if the request fails or the file format is unsupported.
///
Future<String?> inferenceASRModel(String filePath) async {
  final apiUrl = Uri.parse(asrModelApiUri);

  // Check if the file is .m4a or .wav
  if (!filePath.endsWith('.m4a') && !filePath.endsWith('.wav')) {
    return null;
  }

  // Read the file
  final file = File(filePath);
  final fileBytes = await file.readAsBytes();

  // Set headers
  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $asrModelApiToken',
    'Content-Type': 'audio/wav',
  };

  try {
    // Send the POST request
    final response = await http.post(apiUrl, headers: headers, body: fileBytes);

    // Check the response status
    if (response.statusCode == 200) {
      final decodedString = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(decodedString);
      return data["text"];
    } else if (response.statusCode == 503){
      await Future.delayed(const Duration(seconds: 5));
      return inferenceASRModel(filePath);
    } else {
      return null;
    }
  } catch (e) {
    null;
  }
}
