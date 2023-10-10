import 'package:dart_openai/src/core/builder/base_api_url.dart';
import 'package:dart_openai/src/core/constants/strings.dart';
import 'package:dart_openai/src/core/networking/client.dart';
import 'package:dart_openai/src/core/utils/logger.dart';
import 'package:dart_openai/src/core/models/completion/completion.dart';
import 'package:meta/meta.dart';

import '../../core/base/completion.dart';

import 'package:http/http.dart' as http;

/// {@template openai_completion}
/// This class is responsible for handling all the requests related to the completion in the OpenAI API such as creating a completion.
/// {@endtemplate}
@immutable
@protected
interface class OpenAICompletion implements OpenAICompletionBase {
  @override
  String get endpoint => OpenAIStrings.endpoints.completion;

  /// {@macro openai_completion}
  OpenAICompletion() {
    OpenAILogger.logEndpoint(endpoint);
  }

  /// Creates a new completion and returns a [OpenAICompletionModel] object.
  ///
  ///
  /// Given a prompt, the model will return one or more predicted completions, and can also return the probabilities of alternative tokens at each position.
  ///
  ///
  /// [model] is the id of the model to use for completion.
  ///
  /// You can get a list of available models using the [OpenAI.instance.model.list] method, or by visiting the [Models Overview](https://platform.openai.com/docs/models/overview) page.
  ///
  /// [prompt] is the prompt(s) to generate completions for, encoded as a [String], [List<String>] of strings or tokens.
  /// If the type of [prompt] is not [String] or [List<String>], an assert will be thrown, or it will be converted to a [String] using the [prompt.toString()] method.
  ///
  ///
  /// [suffix] The suffix that comes after a completion of inserted text.
  ///
  ///
  /// [maxTokens] is the maximum number of [tokens](https://platform.openai.com/tokenizer) to generate in the completion.
  ///
  ///
  /// [temperature] defines what sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  ///
  ///
  /// [topP] is an alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  ///
  ///
  /// [n] defines how many completions to generate for each prompt.
  ///
  ///
  /// [logprobs] Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens. For example, if logprobs is 5, the API will return a list of the 5 most likely tokens. The API will always return the logprob of the sampled token, so there may be up to logprobs+1 elements in the response..
  ///
  ///
  /// [echo] Echo back the prompt in addition to the completion.
  ///
  ///
  /// [stop] is an up to 4 list of sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
  ///
  ///
  /// [presencePenalty] defines number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  ///
  ///
  /// [frequencyPenalty] Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  ///
  ///
  /// [bestOf] Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
  /// When used with n, best_of controls the number of candidate completions and n specifies how many to return – best_of must be greater than n.
  ///
  ///
  /// [logitBias] Modify the likelihood of specified tokens appearing in the completion.
  /// Accepts a json object that maps tokens (specified by their token ID in the GPT tokenizer) to an associated bias value from -100 to 100. You can use this tokenizer tool (which works for both GPT-2 and GPT-3) to convert text to token IDs. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
  /// As an example, you can pass {"50256": -100} to prevent the <|endoftext|> token from being generated.
  ///
  ///
  /// [user] A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).
  ///
  /// Example:
  /// ```dart
  /// OpenAICompletionModel completion = await OpenAI.instance.completion.create(
  ///  model: "text-davinci-003",
  ///  prompt: "Dart is a progr",
  ///  maxTokens: 20,
  ///  temperature: 0.5,
  ///  n: 1,
  ///  stop: ["\n"],
  ///  echo: true,
  /// );
  /// ```
  @override
  Future<OpenAICompletionModel> create({
    required String model,
    prompt,
    String? suffix,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? n,
    int? logprobs,
    bool? echo,
    stop,
    double? presencePenalty,
    double? frequencyPenalty,
    int? bestOf,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
  }) async {
    assert(
      prompt is String || prompt is List<String> || prompt == null,
      "prompt field must be a String or List<String>",
    );

    assert(
      stop is String || stop is List<String> || stop == null,
      "stop field must be a String or List<String>",
    );

    return await OpenAINetworkingClient.post<OpenAICompletionModel>(
      to: BaseApiUrlBuilder.build(endpoint),
      body: {
        "model": model,
        if (prompt != null) "prompt": prompt,
        if (suffix != null) "suffix": suffix,
        if (maxTokens != null) "max_tokens": maxTokens,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (n != null) "n": n,
        if (logprobs != null) "logprobs": logprobs,
        if (echo != null) "echo": echo,
        if (stop != null) "stop": stop,
        if (presencePenalty != null) "presence_penalty": presencePenalty,
        if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
        if (bestOf != null) "best_of": bestOf,
        if (logitBias != null) "logit_bias": logitBias,
        if (user != null) "user": user,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAICompletionModel.fromMap(response);
      },
    );
  }

  /// This function creates a completion [Stream] of [OpenAIStreamCompletionModel], which it does stream the results as they are generated.

  ///
  /// [model] is the id of the model to use for completion.
  ///
  ///
  /// You can get a list of available models using the [OpenAI.instance.model.list] method, or by visiting the [Models Overview](https://platform.openai.com/docs/models/overview) page.
  ///
  ///
  /// [prompt] is the prompt(s) to generate completions for, encoded as a [String], [List<String>] of strings or tokens.
  /// If the type of [prompt] is not [String] or [List<String>], an assert will be thrown, or it will be converted to a [String] using the [prompt.toString()] method.
  ///
  ///
  /// [suffix] The suffix that comes after a completion of inserted text.
  ///
  ///
  /// [maxTokens] is the maximum number of [tokens](https://platform.openai.com/tokenizer) to generate in the completion.
  ///
  ///
  /// [temperature] defines what sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  ///
  ///
  /// [topP] is an alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  ///
  ///
  /// [n] defines how many completions to generate for each prompt.
  ///
  ///
  /// [logprobs] Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens. For example, if logprobs is 5, the API will return a list of the 5 most likely tokens. The API will always return the logprob of the sampled token, so there may be up to logprobs+1 elements in the response..
  ///
  ///
  /// [echo] Echo back the prompt in addition to the completion.
  ///
  ///
  /// [stop] is an up to 4 list of sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
  ///
  ///
  /// [presencePenalty] defines number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  ///
  ///
  /// [frequencyPenalty] Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  ///
  ///
  /// [bestOf] Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
  /// When used with n, best_of controls the number of candidate completions and n specifies how many to return – best_of must be greater than n.
  ///
  ///
  /// [logitBias] Modify the likelihood of specified tokens appearing in the completion.
  /// Accepts a json object that maps tokens (specified by their token ID in the GPT tokenizer) to an associated bias value from -100 to 100. You can use this tokenizer tool (which works for both GPT-2 and GPT-3) to convert text to token IDs. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
  /// As an example, you can pass {"50256": -100} to prevent the <|endoftext|> token from being generated.
  ///
  /// [user] A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).
  ///
  /// Example:
  /// ```dart
  /// Stream<OpenAIStreamCompletionModel> completionStream = OpenAI.instance.completion.createStream(
  ///  model: "text-davinci-003",
  ///  prompt: "Github is ",
  ///  maxTokens: 100,
  ///  temperature: 0.5,
  ///  topP: 1,
  /// );
  ///
  /// completionStream.listen((event) {
  ///  final firstCompletionChoice = event.choices.first;
  /// print(firstCompletionChoice.text); // ...
  /// });
  /// ```

  @override
  Stream<OpenAIStreamCompletionModel> createStream({
    required String model,
    prompt,
    String? suffix,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? n,
    int? logprobs,
    bool? echo,
    String? stop,
    double? presencePenalty,
    double? frequencyPenalty,
    int? bestOf,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
  }) {
    return OpenAINetworkingClient.postStream<OpenAIStreamCompletionModel>(
      to: BaseApiUrlBuilder.build(endpoint),
      body: {
        "model": model,
        "stream": true,
        if (prompt != null) "prompt": prompt,
        if (suffix != null) "suffix": suffix,
        if (maxTokens != null) "max_tokens": maxTokens,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (n != null) "n": n,
        if (logprobs != null) "logprobs": logprobs,
        if (echo != null) "echo": echo,
        if (stop != null) "stop": stop,
        if (presencePenalty != null) "presence_penalty": presencePenalty,
        if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
        if (bestOf != null) "best_of": bestOf,
        if (logitBias != null) "logit_bias": logitBias,
        if (user != null) "user": user,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIStreamCompletionModel.fromMap(response);
      },
    );
  }

  /// Creates a direct [Stream] of the completion [String] as it is generated.
  ///
  ///
  /// Given a prompt, the model will return one or more predicted completions, and can also return the probabilities of alternative tokens at each position.
  ///
  ///
  /// [model] is the id of the model to use for completion.
  ///
  /// You can get a list of available models using the [OpenAI.instance.model.list] method, or by visiting the [Models Overview](https://platform.openai.com/docs/models/overview) page.
  ///
  /// [prompt] is the prompt(s) to generate completions for, encoded as a [String], [List<String>] of strings or tokens.
  /// If the type of [prompt] is not [String] or [List<String>], an assert will be thrown, or it will be converted to a [String] using the [prompt.toString()] method.
  ///
  ///
  /// [suffix] The suffix that comes after a completion of inserted text.
  ///
  ///
  /// [maxTokens] is the maximum number of [tokens](https://platform.openai.com/tokenizer) to generate in the completion.
  ///
  ///
  /// [temperature] defines what sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  ///
  ///
  /// [topP] is an alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  ///
  ///
  /// [n] defines how many completions to generate for each prompt.
  ///
  ///
  /// [logprobs] Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens. For example, if logprobs is 5, the API will return a list of the 5 most likely tokens. The API will always return the logprob of the sampled token, so there may be up to logprobs+1 elements in the response..
  ///
  ///
  /// [echo] Echo back the prompt in addition to the completion.
  ///
  ///
  /// [stop] is an up to 4 list of sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
  ///
  ///
  /// [presencePenalty] defines number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  ///
  ///
  /// [frequencyPenalty] Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  ///
  ///
  /// [bestOf] Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
  /// When used with n, best_of controls the number of candidate completions and n specifies how many to return – best_of must be greater than n.
  ///
  ///
  /// [logitBias] Modify the likelihood of specified tokens appearing in the completion.
  /// Accepts a json object that maps tokens (specified by their token ID in the GPT tokenizer) to an associated bias value from -100 to 100. You can use this tokenizer tool (which works for both GPT-2 and GPT-3) to convert text to token IDs. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
  /// As an example, you can pass {"50256": -100} to prevent the <|endoftext|> token from being generated.
  ///
  ///
  /// [user] A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).
  ///
  /// Example:
  /// ```dart
  /// OpenAICompletionModel completion = await OpenAI.instance.completion.create(
  ///  model: "text-davinci-003",
  ///  prompt: "Dart is ",
  /// );
  /// ```
  /// Example:
  /// ```dart
  /// Stream<String> completionStream = OpenAI.instance.completion.createStreamText(
  ///  model: "text-davinci-003",
  ///  prompt: "Dart is ",
  /// );
  /// ```
  @override
  Stream<String> createStreamText({
    required String model,
    prompt,
    String? suffix,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? n,
    int? logprobs,
    bool? echo,
    String? stop,
    double? presencePenalty,
    double? frequencyPenalty,
    int? bestOf,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
  }) {
    Stream<OpenAIStreamCompletionModel> stream = createStream(
      model: model,
      prompt: prompt,
      suffix: suffix,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      n: n,
      logprobs: logprobs,
      echo: echo,
      stop: stop,
      presencePenalty: presencePenalty,
      frequencyPenalty: frequencyPenalty,
      bestOf: bestOf,
      logitBias: logitBias,
      user: user,
    );

    return stream.map((event) => event.choices.first.text);
  }
}
