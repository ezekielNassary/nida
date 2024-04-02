import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nida/utils/const.dart';

class Nida {
  Nida();

  Future<dynamic> userData(String Nin) async {
    Map<String, dynamic> responseJson;
    Map<String, dynamic> param = {};
    Uri url = Uri.parse('$baseUrl/$Nin');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    try {
      final response = await http
          .post(
            url,
            headers: headers ?? {},
            body: param.isNotEmpty ? jsonEncode(param) : null,
          )
          .timeout(const Duration(seconds: 30));
      // print(
      //     'response api****$url********$param*********${response.statusCode}');
      // responseJson = _response(response.body);

      Map<String, dynamic> result = json.decode(response.body);
      responseJson = result['obj'];
      // print(responseJson);
    } on SocketException {
      throw ApiException('No Internet connection');
    } on TimeoutException {
      throw ApiException('Something went wrong, Server not responding');
    } on Exception catch (e) {
      throw ApiException('Something went wrong with ${e.toString()}');
    }
    return responseJson;
  }

  dynamic _response(response) {
    switch (response.statusCode) {
      case 200:
        // var responseJson = json.decode(response.body.toString());
        return response;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }
}

class ApiException implements Exception {
  ApiException(this.errorMessage);

  String errorMessage;

  @override
  String toString() {
    return errorMessage;
  }
}

class CustomException implements Exception {
  final message;
  final prefix;
  CustomException([this.message, this.prefix]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
      : super(message, 'Error During Communication: ');
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, 'Invalid Input: ');
}
