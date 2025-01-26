// events/deepseek_event.dart
import 'dart:convert';

import 'package:deepseek/enums/deepseek_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// bloc/deepseek_bloc.dart
class DeepseekBloc extends Bloc<DeepseekEvent, DeepseekState> {
  final DeepseekRepository repository;

  DeepseekBloc({required this.repository}) : super(DeepseekInitial()) {
    on<GenerateCompletion>(_onGenerateCompletion);
  }

  Future<void> _onGenerateCompletion(
    GenerateCompletion event,
    Emitter<DeepseekState> emit,
  ) async {
    emit(DeepseekLoading());
    try {
      final response = await repository.generateCompletion(
        event.prompt,
        event.model,
      );
      emit(DeepseekSuccess(response));
    } catch (e) {
      emit(DeepseekError(e.toString()));
    }
  }
}

class DeepseekError extends DeepseekState {
  final String error;
  DeepseekError(this.error);
}

abstract class DeepseekEvent {}

class DeepseekInitial extends DeepseekState {}

class DeepseekLoading extends DeepseekState {}

// repository/deepseek_repository.dart
class DeepseekRepository {
  final String baseUrl;
  final http.Client client;

  DeepseekRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<String> generateCompletion(String prompt, DeepseekModel model) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prompt': prompt,
          'model': model.value,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['response'];
      } else {
        throw Exception(
            'Failed to generate completion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// screens/deepseek_screen.dart
class DeepseekScreen extends StatelessWidget {
  final _promptController = TextEditingController();
  final DeepseekModel _selectedModel = DeepseekModel.chat;

  DeepseekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeepseekBloc(
        repository: DeepseekRepository(
          baseUrl: 'http://your-python-backend',
        ),
      ),
      child: BlocBuilder<DeepseekBloc, DeepseekState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('DeepSeek Explorer')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<DeepseekModel>(
                    value: _selectedModel,
                    items: DeepseekModel.values.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(model.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Handle model selection
                    },
                  ),
                  TextField(
                    controller: _promptController,
                    decoration:
                        const InputDecoration(labelText: 'Enter prompt'),
                    maxLines: 4,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DeepseekBloc>().add(
                            GenerateCompletion(
                              prompt: _promptController.text,
                              model: _selectedModel,
                            ),
                          );
                    },
                    child: const Text('Generate'),
                  ),
                  if (state is DeepseekLoading)
                    const CircularProgressIndicator()
                  else if (state is DeepseekSuccess)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(state.response),
                      ),
                    )
                  else if (state is DeepseekError)
                    Text(state.error,
                        style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// states/deepseek_state.dart
abstract class DeepseekState {}

class DeepseekSuccess extends DeepseekState {
  final String response;
  DeepseekSuccess(this.response);
}

class GenerateCompletion extends DeepseekEvent {
  final String prompt;
  final DeepseekModel model;

  GenerateCompletion({required this.prompt, required this.model});
}
