enum DeepseekModel {
  chat('deepseek-chat'),
  reasoner('deepseek-reasoner'),
  coder('deepseek-coder');

  final String value;
  const DeepseekModel(this.value);
}
