import 'package:http/http.dart' as http;

Future<String> response(String imgData) async {
  var url = 'https://pure-stream-49009.herokuapp.com';
  var prediction = await http.post(url, body: {'image': '$imgData'});
  return prediction.body;
}
