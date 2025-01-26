// main.dart
import 'dart:convert';

import 'package:deepseek/enums/deepseek_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'bloc/backend_bloc.dart';

void main() {
  runApp(const MyApp());
}

class DeepSeekExplorer extends StatefulWidget {
  const DeepSeekExplorer({super.key});

  @override
  State<DeepSeekExplorer> createState() => _DeepSeekExplorerState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSeek Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        child: const DeepSeekExplorer(),
        create: (BuildContext context) => BackendBloc(),
      ),
    );
  }
}

class _DeepSeekExplorerState extends State<DeepSeekExplorer> {
  final TextEditingController _promptController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  String _selectedModel = DeepseekModel.chat.value;

  final List<String> _models =
      DeepseekModel.values.map((model) => model.value).toList();

  @override
  Widget build(BuildContext context) {
    final backendBloc = BlocProvider.of<BackendBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepSeek Explorer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<BackendBloc, Map<String, dynamic>>(
          builder: (context, state) {
        if (state.isNotEmpty && state['isLoading'] == 'isLoading') {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: const InputDecoration(
                  labelText: 'Select Model',
                  border: OutlineInputBorder(),
                ),
                items: _models.map((String model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedModel = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Enter your prompt',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    (state.isNotEmpty && state['isLoading'] == 'isLoading')
                        ? null
                        : () {
                            if (_promptController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Prompt cannot be empty'),
                                ),
                              );
                              return;
                            }
                            backendBloc.deepSeek(
                                prompt: _promptController.text,
                                model: _selectedModel);
                          },
                child: (state.isNotEmpty && state['isLoading'] == 'isLoading')
                    ? const CircularProgressIndicator()
                    : const Text('Generate'),
              ),
              const SizedBox(height: 16),
              if (state.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: Text(state['response']['content'].toString()),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _getResponse() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prompt': _promptController.text,
          'model': _selectedModel,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = json.decode(response.body)['response'];
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
