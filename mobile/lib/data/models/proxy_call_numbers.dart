class ProxyCallNumbers {
  final String buyerProxyNumber;
  final String sellerProxyNumber;
  final String sessionSid;

  const ProxyCallNumbers({
    required this.buyerProxyNumber,
    required this.sellerProxyNumber,
    required this.sessionSid,
  });

  factory ProxyCallNumbers.fromMap(Map<String, dynamic> map) {
    return ProxyCallNumbers(
      buyerProxyNumber: map['buyer_proxy_number'] as String,
      sellerProxyNumber: map['seller_proxy_number'] as String,
      sessionSid: map['session_sid'] as String,
    );
  }
}
