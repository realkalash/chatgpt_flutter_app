import 'dart:convert';
import 'package:chatgpt_flutter_app/chat_gpt_page.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/open_ai_config.dart';
import 'models/prefs.dart';
import 'models/stable_diff_config.dart';
import 'models/stable_diff_sizes.dart';

StableDiffConfig stableDiffConfig = StableDiffConfig(
  prompt: '',
  negative_prompt: '',
  sampler_name: 'Euler a',
  cfg_scale: 7,
  steps: 15,
  width: 300,
  height: 300,
  stableDiffSize: StableDiffSizes.s256x256_5s,
);
OpenAIConfigState? openAIConfig = OpenAIConfigState(
  maxTokens: 2048,
  temperature: 0.28,
  topP: 0.95,
  frequencyPenalty: 1.1,
  selectedGptModel: '',
  isOpenAiApi: false,
  apiKey: '',
);

const defaultLocalBaseUrl = 'http://localhost:4891';
const defaultBaseUrl = 'https://api.openai.com';
const localStableDiffusionApi = 'http://127.0.0.1:7860/sdapi/v1/txt2img';

Future<void> main() async {
  await Prefs.init();
  final cachedConfig = Prefs.getOpenAiConfig();
  if (cachedConfig != null) {
    openAIConfig =
        OpenAIConfigState.fromJson(jsonDecode(Prefs.getOpenAiConfig()!));
  }
  OpenAI.apiKey = openAIConfig!.apiKey;
  OpenAI.baseUrl =
      openAIConfig!.isOpenAiApi ? defaultBaseUrl : defaultLocalBaseUrl;

  runApp(const ChatApp());
}

final mainFocus = FocusNode();

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  ThemeMode themeMode = ThemeMode.system;
  final lightTheme = ThemeData(scaffoldBackgroundColor: Colors.white);

  final darkTheme = ThemeData.dark().copyWith();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ChatGptPage(),
    );
  }
}

Image imageFromBase64String(String stringImage) {
  return Image.memory(
    base64Decode(stringImage),
    fit: BoxFit.cover,
  );
}
