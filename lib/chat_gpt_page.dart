import 'dart:convert';
import 'dart:developer';

import 'package:chatgpt_flutter_app/chat_drawer.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'count_timer.dart';
import 'main.dart';
import 'models/stable_diff_config.dart';
import 'models/stable_diff_sizes.dart';

class ChatGptPage extends StatefulWidget {
  const ChatGptPage({super.key});

  @override
  State<ChatGptPage> createState() => _ChatGptPageState();
}


class _ChatGptPageState extends State<ChatGptPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _tokensController = TextEditingController();
  final scrollController = ScrollController();
  bool _isStableDiffWorking = false;
  bool _showSettingsDrawer = false;
  var _isShiftPressed = false;

  _sendStableDiffusionRequest(
    String prompt, {
    String negativePrompt = '<easynegative:1.0>, low quality, weird face',
  }) async {
    try {
      setState(() {
        stableDiffConfig.prompt = prompt;
        stableDiffConfig.negative_prompt = negativePrompt;
        _isStableDiffWorking = true;
      });
      if (stableDiffConfig.stableDiffSize == StableDiffSizes.s256x256_5s) {
        stableDiffConfig.width = 256;
        stableDiffConfig.height = 256;
      } else if (stableDiffConfig.stableDiffSize ==
          StableDiffSizes.s300x300_10s) {
        stableDiffConfig.width = 300;
        stableDiffConfig.height = 300;
      } else if (stableDiffConfig.stableDiffSize ==
          StableDiffSizes.s400x400_30s) {
        stableDiffConfig.width = 400;
        stableDiffConfig.height = 400;
      } else if (stableDiffConfig.stableDiffSize ==
          StableDiffSizes.m500x500_60s) {
        stableDiffConfig.width = 500;
        stableDiffConfig.height = 500;
      } else if (stableDiffConfig.stableDiffSize ==
          StableDiffSizes.b500x768_80s) {
        stableDiffConfig.width = 500;
        stableDiffConfig.height = 768;
      } else if (stableDiffConfig.stableDiffSize ==
          StableDiffSizes.b768x500_80s) {
        stableDiffConfig.width = 768;
        stableDiffConfig.height = 500;
      }
      final map = <String, dynamic>{
        'prompt': stableDiffConfig.prompt,
        'negative_prompt': negativePrompt,
        'sampler_name': stableDiffConfig.sampler_name,
        'cfg_scale': stableDiffConfig.cfg_scale,
        "steps": stableDiffConfig.steps,
        "width": stableDiffConfig.width,
        "height": stableDiffConfig.height,
      };
      log('request generate image: $map');
      final response = await http.post(
        Uri.parse(localStableDiffusionApi),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map),
      );
      log('response: ${response.body}');
      final mapResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final images = mapResponse['images'] as List<dynamic>;
      final firstImage = images.firstOrNull as String?;
      setState(() {
        _isStableDiffWorking = false;
      });
      if (firstImage != null) {
        return firstImage;
      }
      return null;
    } catch (e) {
      log('Error: $e');
      setState(() {
        _isStableDiffWorking = false;
      });
      return null;
    }
  }

  _sendStableDiffusionEmotionRequest(StableDiffConfig config) async {
    try {
      setState(() {
        _isStableDiffWorking = true;
      });

      final map = <String, dynamic>{
        'prompt': config.prompt,
        'negative_prompt': config.negative_prompt,
        'sampler_name': config.sampler_name,
        'cfg_scale': config.cfg_scale,
        "steps": config.steps,
        "width": config.width,
        "height": config.height,
      };
      log('request generate image: $map');
      final response = await http.post(
        Uri.parse(localStableDiffusionApi),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map),
      );
      log('response: ${response.body}');
      final mapResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final images = mapResponse['images'] as List<dynamic>;
      final firstImage = images.firstOrNull as String?;
      setState(() {
        _isStableDiffWorking = false;
      });
      if (firstImage != null) {
        return firstImage;
      }
      return null;
    } catch (e) {
      log('Error: $e');
      setState(() {
        _isStableDiffWorking = false;
      });
      return null;
    }
  }

  void scrollToBottomList() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void openImageFullScreen(Image image, int? index) {
    if (index == null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: image,
          );
        },
      );
    }

    /// open dialog at full screen with merging of 32 pixels on all sides
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Hero(
            tag: '$index',
            transitionOnUserGestures: true,
            child: image,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // openAIConfig.selectedGptModel = OpenAIConfigState.listGPTModels.first;
    _tokensController.text = 2048.toString();
    openAIConfig!.maxTokens = int.tryParse(_tokensController.text) ?? 150;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleSendMessage() {
    final message = _inputController.text;
    log('Sending message: $message');
    if (message.isNotEmpty) {
      _inputController.clear();
      // _sendChatRequest(message);
      _sendChatStreamedRequest(message);
    }
  }

  Future _sendResetChatRequest() async {
    try {
      await OpenAI.instance.chat.create(
        model: openAIConfig!.selectedGptModel,
        messages: [
          const OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system, content: 'reset')
        ],
        maxTokens: 1,
      );
    } catch (e) {
      log('Error: $e');
    } finally {
      setState(() {
        _isChatGptWorking = false;
        _messages.clear();
        _uncompletedMessages.clear();
      });
    }
  }

  Future<void> _handleSendMessageToStableDiffusion() async {
    final prompt = _inputController.text.toString();
    setState(() {
      _messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      );
    });
    final image = await _sendStableDiffusionRequest(
      prompt,
      negativePrompt: '<easynegative:1.0>, low quality, weird face',
    );
    if (image != null) {
      setState(() {
        _messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: image,
            role: OpenAIChatMessageRole.stableDiffusion,
          ),
        );
      });
      await Future.delayed(const Duration(milliseconds: 500));
      scrollToBottomList();
    }
  }

  Future<void> _handleSendEmotionToStableDiffusion(String textQuery) async {
    final prompt = textQuery;
    if (kDebugMode) {
      setState(() {
        _messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: prompt,
            role: OpenAIChatMessageRole.user,
          ),
        );
      });
    }
    final image = await _sendStableDiffusionEmotionRequest(
      StableDiffConfig.configForEmotion(prompt,
          negative_prompt: '<easynegative:1.0>, low quality, weird face'),
    );
    if (image != null) {
      setState(() {
        _messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: image,
            role: OpenAIChatMessageRole.stableDiffusion,
          ),
        );
      });
      await Future.delayed(const Duration(milliseconds: 500));
      scrollToBottomList();
    }
  }

  Stream<OpenAIStreamChatCompletionModel>? realTimeAnswerSubscription;

  _sendChatStreamedRequest(String message) async {
    setState(() {
      _isChatGptWorking = true;
      _messages.add(
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, content: message),
      );
    });
    // Stream<OpenAIStreamCompletionModel> completionStream =
    //     OpenAI.instance.completion.createStream(
    //   model: openAIConfig.selectedGptModel,
    //   prompt: message,
    //   maxTokens: 100,
    //   temperature: 0.5,
    //   topP: 1,
    //   echo: true,
    // );

    final maxTokens = int.tryParse(_tokensController.text) ?? 150;
    final last5Messages = _messages.reversed.take(5).toList();
    realTimeAnswerSubscription = OpenAI.instance.chat.createStream(
      model: openAIConfig!.selectedGptModel,
      messages: [
        for (final message in last5Messages.reversed)
          OpenAIChatCompletionChoiceMessageModel(
            role: message.role,
            content: message.content,
          ),
        // OpenAIChatCompletionChoiceMessageModel(
        //   role: OpenAIChatMessageRole.user,
        //   content: message,
        // )
      ],
      maxTokens: maxTokens,
      stop: ['stop'],
      // temperature: 0.28,
      // topP: 0.95,
      // frequencyPenalty: 1.1,
    );
    realTimeAnswerSubscription?.listen(
      (event) {
        // log('event: $event');
        if (event.haveChoices == false ||
            event.choices.last.finishReason == 'stop') {
          setState(() {
            _isChatGptWorking = false;
          });
          return;
        }
        // we need to append all the messages to _realtimeAnswerMessage;
        final choices = event.choices.map((e) => e.delta).toList();
        final delta = choices.map((e) => e.content).join(' ');
        // log('delta: $delta');
        setState(() {
          _realtimeAnswerMessage += delta;
          if (_realtimeAnswerMessage != '' && _messages.isNotEmpty) {
            _messages.removeLast();
          }
          _messages.add(
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.assistant,
              content: _realtimeAnswerMessage,
            ),
          );
        });
      },
      cancelOnError: true,
      onDone: () {
        log('onDone');
        final lastMessageFromRealtimeAnswer = _realtimeAnswerMessage;
        if (lastMessageFromRealtimeAnswer.isNotEmpty) {
          _realtimeAnswerMessage = '';
        }
      },
      onError: (error) {
        log('onError: $error');
      },
    );
    setState(() {});
  }

  final listPromptsForCode = [
    'on python',
    'on dart',
    'on flutter',
  ];
  _sendChatRequest(String message) async {
    final isContinue = message == 'continue';

    final content = '$message. Use markdown syntax';
    log('content: $content');

    setState(() {
      _isChatGptWorking = true;
      if (!isContinue) {
        _messages.add(
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user, content: message),
        );
      }
    });

    final maxTokens = int.tryParse(_tokensController.text) ?? 150;
    try {
      final response = await OpenAI.instance.chat.create(
        model: openAIConfig!.selectedGptModel,
        messages: isContinue
            ? _messages
                .map((e) => OpenAIChatCompletionChoiceMessageModel(
                    role: e.role, content: e.content))
                .toList()
            : [
                OpenAIChatCompletionChoiceMessageModel(
                    role: OpenAIChatMessageRole.user, content: content)
              ],
        maxTokens: maxTokens,
        stop: ['stop'],
        temperature: 0.28,
        topP: 0.95,
        frequencyPenalty: 1.1,
      );
      if (response.choices.isNotEmpty) {
        _messages.add(response.choices.first.message);
        if (response.choices.first.finishReason == 'length') {
          _uncompletedMessages.add(_messages.length - 1);
        }
      }
    } catch (e) {
      log('Error: $e');
      setState(() {
        _messages.add(
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system, content: 'Error: $e'),
        );
      });
    }

    setState(() {
      _isChatGptWorking = false;
    });
  }

  List<OpenAIChatCompletionChoiceMessageModel> _messages = [];
  String _realtimeAnswerMessage = '';
  final List<int> _uncompletedMessages = [];

  bool _isChatGptWorking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('ChatGPT Flutter App'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: _sendResetChatRequest,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Row(
        children: [
          if (_showSettingsDrawer) const ChatDrawer(),
          Expanded(
            child: Column(
              children: [
                Text('Random seed: ${DateTime.now().millisecondsSinceEpoch}'),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        Color? tileColor =
                            message.role == OpenAIChatMessageRole.system
                                ? theme.colorScheme.secondary.withOpacity(0.2)
                                : null;
                        final isUncompletedMessage =
                            _uncompletedMessages.contains(index);
                        if (isUncompletedMessage) {
                          tileColor = Colors.red.withOpacity(0.2);
                        }
                        final codeRegExp = RegExp(r'```.*```', dotAll: true);
                        final containsCode =
                            codeRegExp.hasMatch(message.content.toString());
                        final codeInMessage = containsCode
                            ? codeRegExp.stringMatch(message.content)
                            : null;

                        if (message.role ==
                            OpenAIChatMessageRole.stableDiffusion) {
                          final imageWidget =
                              imageFromBase64String(message.content);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.primaryColor,
                              child: const Icon(Icons.android_outlined,
                                  color: Colors.white),
                            ),
                            title: const SelectableText(''),
                            subtitle: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                height: 300,
                                width: 300,
                                child: Hero(
                                  tag: '$index',
                                  child: InkWell(
                                    onTap: () =>
                                        openImageFullScreen(imageWidget, index),
                                    child: imageWidget,
                                  ),
                                ),
                              ),
                            ),
                            trailing: const Text('Stable diffusion'),
                            tileColor: tileColor,
                          );
                        }

                        return Card(
                          semanticContainer: false,
                          color: Theme.of(context).cardColor.withOpacity(0.8),
                          child: ListTile(
                            tileColor: tileColor,
                            leading: CircleAvatar(
                              backgroundColor: message.role ==
                                      OpenAIChatMessageRole.assistant
                                  ? theme.primaryColor
                                  : const Color(0xff138a6e),
                              child: Icon(
                                  message.role == OpenAIChatMessageRole.user
                                      ? Icons.person
                                      : Icons.android_outlined,
                                  color: Colors.white),
                            ),
                            subtitle: Wrap(
                              children: [
                                if (codeInMessage != null)
                                  ElevatedButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: codeInMessage));
                                      },
                                      child: const Text('Copy code')),
                              ],
                            ),
                            title: MarkdownBody(
                              data: message.content.toString(),
                              selectable: true,
                              shrinkWrap: false,
                              styleSheet:
                                  MarkdownStyleSheet.fromTheme(theme).copyWith(
                                code: const TextStyle(
                                  backgroundColor: Colors.transparent,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            trailing: message.role == OpenAIChatMessageRole.user
                                ? const Text('You')
                                : isUncompletedMessage
                                    ? TextButton(
                                        onPressed: () {
                                          _uncompletedMessages.remove(index);
                                          _sendChatRequest('continue');
                                        },
                                        child: const Text('continue'),
                                      )
                                    : const Text('Bot'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_isChatGptWorking || _isStableDiffWorking)
                  const Row(
                    children: [
                      Center(
                        child: SizedBox.square(
                            dimension: 24, child: CircularProgressIndicator()),
                      ),
                      CountdownTimerWidget(),
                    ],
                  ),
                if (_isShiftPressed) const Text('Append new line mode'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: theme.colorScheme.secondary),
                    ),
                    child: Row(
                      children: [
                        /// add attachment button
                        InkWell(
                          onTap: () {
                            // _sendChatRequest('continue');
                            // _inputController.text =
                            //     'laughing very hard, white hair, blue eyes, 1girl, 14 years old girl, eyes on camera, girl is talking, white solid background, simple outfit, short hairstyle';
                            _handleSendEmotionToStableDiffusion(
                              'laughing very hard, white hair, blue eyes, 1girl, 14 years old girl, eyes on camera, girl is talking, white solid background, simple outfit, short hairstyle',
                            );
                          },
                          child: const Card(
                            margin: EdgeInsets.zero,
                            shape: CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.attach_file),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RawKeyboardListener(
                            focusNode: mainFocus,
                            autofocus: false,
                            includeSemantics: false,
                            onKey: (event) {
                              if (event
                                      .isKeyPressed(LogicalKeyboardKey.enter) &&
                                  !_isShiftPressed) {
                                _handleSendMessage();
                              }
                              if (_isShiftPressed && event.isShiftPressed) {
                                return;
                              }
                              if (!_isShiftPressed && !event.isShiftPressed) {
                                return;
                              }
                              if (event.isShiftPressed) {
                                setState(() {
                                  _isShiftPressed = true;
                                });
                              } else {
                                setState(() {
                                  _isShiftPressed = false;
                                });
                              }
                            },
                            child: TextField(
                              key: const Key('chat_input'),
                              controller: _inputController,
                              maxLines: 8,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                              ),
                            ),
                          ),
                        ),
                        Card(
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _handleSendMessage,
                          ),
                        ),
                        Card(
                          child: GestureDetector(
                            onSecondaryTapDown:
                                _chooseSizeStableDiffImageForGenerate,
                            child: IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: _handleSendMessageToStableDiffusion,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            scrollToBottomList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _chooseSizeStableDiffImageForGenerate(TapDownDetails details) {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          details.globalPosition,
          details.globalPosition,
        ),
        Offset.zero & (overlay?.semanticBounds.size ?? const Size(200, 200)),
      ),
      items: StableDiffSizes.values.map((e) {
        final isSelected = e == stableDiffConfig.stableDiffSize;
        return PopupMenuItem(
          value: e,
          child: Text('${e.name} ${isSelected ? '✓' : ''}'),
        );
      }).toList(),
    ).then((value) {
      if (value == null) return;
      // Handle menu item selection
      setState(() {
        stableDiffConfig.stableDiffSize = value;
      });
    });
  }

  void _showSettings() {
    setState(() {
      _showSettingsDrawer = !_showSettingsDrawer;
    });
  }
}
