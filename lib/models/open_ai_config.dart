class OpenAIConfigState {
  OpenAIConfigState({
    required this.maxTokens,
    required this.temperature,
    required this.topP,
    required this.frequencyPenalty,
    required this.selectedGptModel,
    required this.isOpenAiApi,
    this.apiKey = '',
  });
  String selectedGptModel;
  String apiKey;
  int maxTokens;
  double temperature;
  double topP;
  double frequencyPenalty;
  bool isOpenAiApi;

  static const listGPTModels = [
    'v3-13b-hermes-q5_1',
    'gpt4all-j-v1.3-groovy',
  ];

  static const listGPTModelsOpenAi = [
    'gpt-3.5-turbo',
  ];

  Map<String, Object> toJson() {
    return {
      'selectedGptModel': selectedGptModel,
      'apiKey': apiKey,
      'maxTokens': maxTokens,
      'temperature': temperature,
      'topP': topP,
      'frequencyPenalty': frequencyPenalty,
      'isOpenAiApi': isOpenAiApi,
    };
  }

  static OpenAIConfigState fromJson(Map<String, dynamic> json) {
    return OpenAIConfigState(
      selectedGptModel: json['selectedGptModel'],
      apiKey: json['apiKey'],
      maxTokens: json['maxTokens'],
      temperature: json['temperature'],
      topP: json['topP'],
      frequencyPenalty: json['frequencyPenalty'],
      isOpenAiApi: json['isOpenAiApi'],
    );
  }
}
