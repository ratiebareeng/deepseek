import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class BackendBloc extends Cubit<String> {
  BackendBloc() : super('');
  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/data'));
    if (response.statusCode == 200) {
      emit(response.body);
    } else {
      emit('Failed to fetch data');
    }
  }
}
