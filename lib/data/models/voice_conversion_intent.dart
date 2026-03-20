/// Parsed from speech (OpenAI) for fiat↔fiat or crypto↔crypto conversion.
class VoiceConversionIntent {
  final double amount;
  final String fromCode;
  final String toCode;
  final bool isCrypto;

  const VoiceConversionIntent({
    required this.amount,
    required this.fromCode,
    required this.toCode,
    required this.isCrypto,
  });
}
