enum HttpMethod {
  get,
  post,
  delete,
  patch;

  String get value {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.patch:
        return 'PATCH';
    }
  }
}

class ApiRequestModel {
  final String endpoint;
  final String body;
  final String? jwtToken;
  final HttpMethod method;

  ApiRequestModel({
    required this.endpoint,
    required this.body,
    required this.method,
    this.jwtToken,
  });

  Map<String, String> get headers {
    final headers = {'Content-Type': 'application/json'};

    if (jwtToken != null) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }

    return headers;
  }
}
