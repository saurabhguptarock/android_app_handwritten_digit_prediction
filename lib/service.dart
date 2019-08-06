import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> response(String imgData) async {
  var url = 'https://pure-stream-49009.herokuapp.com';
  var prediction = await http.post(url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"image": "$imgData"}));
  return prediction.body;
}
