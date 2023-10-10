import 'dart:convert';

import 'package:chatgpt_flutter_app/main.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

import 'models/open_ai_config.dart';
import 'models/prefs.dart';
import 'models/stable_diff_sizes.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final TextEditingController _frequencyPenaltyController =
      TextEditingController();
  final TextEditingController _maxTokensController = TextEditingController();
  final TextEditingController _selectedGptModelController =
      TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _topPController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _frequencyPenaltyController.text =
        openAIConfig!.frequencyPenalty.toString();
    _maxTokensController.text = openAIConfig!.maxTokens.toString();
    _selectedGptModelController.text = openAIConfig!.selectedGptModel;
    _temperatureController.text = openAIConfig!.temperature.toString();
    _topPController.text = openAIConfig!.topP.toString();
  }

  List<String> getListModels() {
    return (openAIConfig!.isOpenAiApi == false
        ? OpenAIConfigState.listGPTModels
        : OpenAIConfigState.listGPTModelsOpenAi);
  }

  @override
  Widget build(BuildContext context) {
    final availableModels = getListModels();
    final availableModelsDropDowns =
        availableModels.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 250,
          child: Card(
            semanticContainer: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckboxListTile(
                  value: openAIConfig!.isOpenAiApi,
                  onChanged: (v) {
                    setState(() {
                      openAIConfig!.isOpenAiApi = v!;
                      openAIConfig!.selectedGptModel = getListModels().first;
                      if (v == true) {
                        OpenAI.baseUrl = defaultBaseUrl;
                      } else {
                        OpenAI.baseUrl = defaultLocalBaseUrl;
                      }
                      Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                    });
                  },
                  title: const Text('OpenAI API/Local API'),
                ),
                DropdownButton<String>(
                  value: openAIConfig!.selectedGptModel,
                  selectedItemBuilder: (context) => availableModels
                      .map<Widget>((String item) => Text('Model: $item'))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      openAIConfig!.selectedGptModel = newValue!;
                    });
                    Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                  },
                  items: availableModelsDropDowns,
                ),
                if (openAIConfig!.isOpenAiApi)
                  TextField(
                    controller: _apiKeyController,
                    onChanged: (value) {
                      setState(() {
                        openAIConfig!.apiKey = value.trim();
                      });
                      if (value.length == 51) {
                        OpenAI.apiKey = value.trim();
                        openAIConfig!.apiKey = value.trim();
                        Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                    ),
                  ),
                TextField(
                  controller: _frequencyPenaltyController,
                  onChanged: (value) {
                    setState(() {
                      openAIConfig!.frequencyPenalty = double.parse(value);
                    });
                    Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                  },
                  decoration: const InputDecoration(
                    labelText: 'Frequency Penalty',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Tooltip(
                  message: 'Maximum lenght of the response in tokens',
                  child: TextField(
                    controller: _maxTokensController,
                    onChanged: (value) {
                      setState(() {
                        openAIConfig!.maxTokens = int.parse(value);
                      });
                      Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                    },
                    decoration: const InputDecoration(
                      labelText: 'Max Tokens',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                TextField(
                  controller: _temperatureController,
                  onChanged: (value) {
                    setState(() {
                      openAIConfig!.temperature = double.parse(value);
                    });
                    Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                  },
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _topPController,
                  onChanged: (value) {
                    setState(() {
                      openAIConfig!.topP = double.parse(value);
                    });
                    Prefs.setOpenAiConfig(jsonEncode(openAIConfig!.toJson()));
                  },
                  decoration: const InputDecoration(
                    labelText: 'Top P',
                  ),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<StableDiffSizes>(
                  value: stableDiffConfig.stableDiffSize,
                  selectedItemBuilder: (context) => StableDiffSizes.values
                      .map<Widget>((StableDiffSizes item) =>
                          Center(child: Text('Images size: ${item.name}')))
                      .toList(),
                  onChanged: (StableDiffSizes? newValue) {
                    setState(() {
                      stableDiffConfig.stableDiffSize = newValue!;
                    });
                  },
                  items: StableDiffSizes.values
                      .map<DropdownMenuItem<StableDiffSizes>>(
                          (StableDiffSizes value) {
                    return DropdownMenuItem<StableDiffSizes>(
                        value: value, child: Text(value.name));
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
