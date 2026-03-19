/// Crypto logo URLs. Strategy: use spothq/cryptocurrency-icons (GitHub raw)
/// for symbols that exist; fallback to first-letter placeholder in widget.
/// Covers 500+ coins. Binance-specific symbols (1000PEPE etc) use fallback.
const _baseUrl =
    'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color';

String cryptoLogoUrl(String symbol) {
  final iconSymbol = symbol.toLowerCase();
  return '$_baseUrl/$iconSymbol.png';
}

/// Common crypto full names. Fallback: symbol.
const Map<String, String> cryptoNames = {
  'BTC': 'Bitcoin',
  'ETH': 'Ethereum',
  'USDT': 'Tether',
  'BNB': 'BNB',
  'SOL': 'Solana',
  'XRP': 'XRP',
  'USDC': 'USD Coin',
  'DOGE': 'Dogecoin',
  'ADA': 'Cardano',
  'AVAX': 'Avalanche',
  'TRX': 'TRON',
  'LINK': 'Chainlink',
  'DOT': 'Polkadot',
  'MATIC': 'Polygon',
  'LTC': 'Litecoin',
  'UNI': 'Uniswap',
  'ATOM': 'Cosmos',
  'ETC': 'Ethereum Classic',
  'XLM': 'Stellar',
  'NEAR': 'NEAR Protocol',
  'APT': 'Aptos',
  'ARB': 'Arbitrum',
  'OP': 'Optimism',
  'INJ': 'Injective',
  'FIL': 'Filecoin',
  'IMX': 'Immutable X',
  'SUI': 'Sui',
  'SEI': 'Sei',
  'PEPE': 'Pepe',
  'WIF': 'dogwifhat',
  'BONK': 'Bonk',
  'FLOKI': 'Floki',
};

String cryptoDisplayName(String symbol) =>
    cryptoNames[symbol.toUpperCase()] ?? symbol;
