import 'package:http/http.dart';
import 'package:http/http.dart' as http;

var baseUrl = "https://brasilapi.com.br/api/cep/v1/";

Future<Response> getCep(String cep) async {
  var response = await http.get(Uri.parse(baseUrl + cep));
  return response;
}