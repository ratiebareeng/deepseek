import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class BackendBloc extends Cubit<Map<String, dynamic>> {
  BackendBloc() : super({});
  Future<void> deepSeek({required String prompt, required String model}) async {
    emit({'isLoading': 'isLoading'});

    // await http.get(Uri.parse('http://localhost:5000/api/data'));
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/deepSeek'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'prompt': prompt,
        'model': model,
      }),
    );
    if (response.statusCode == 200) {
      emit({
        'response': jsonDecode(response.body) as Map<String, dynamic>,
        'statusCode': response.statusCode
      });
    } else {
      emit({
        'response': 'Error: ${response.body}',
        'statusCode': response.statusCode
      });
    }
  }

  Future<void> fetchData() async {
    emit({'isLoading': 'isLoading'});
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/data'));
    if (response.statusCode == 200) {
      emit({
        'response': jsonDecode(response.body) as Map<String, dynamic>,
        'statusCode': response.statusCode
      });
    } else {
      emit({
        'response': 'Error: ${response.statusCode}',
        'statusCode': response.statusCode
      });
    }
  }
}
