import 'package:chatgpt_flutter_app/main.dart';
import 'package:chatgpt_flutter_app/models/stable_diff_sizes.dart';

class StableDiffConfig {
  StableDiffConfig({
    required this.prompt,
    required this.negative_prompt,
    required this.sampler_name,
    required this.cfg_scale,
    required this.steps,
    required this.width,
    required this.height,
    required this.stableDiffSize,
  });
  String prompt;
  String negative_prompt;
  String sampler_name;
  int cfg_scale;
  int steps;
  int width;
  int height;

  StableDiffSizes stableDiffSize;

  static StableDiffConfig configForEmotion(String prompt,
      {String? negative_prompt}) {
    final config = StableDiffConfig(
      prompt: prompt,
      negative_prompt: negative_prompt ?? stableDiffConfig.negative_prompt,
      sampler_name: 'Euler a',
      cfg_scale: 7,
      steps: 15,
      width: 256,
      height: 256,
      stableDiffSize: StableDiffSizes.s256x256_5s,
    );
    return config;
  }
}
