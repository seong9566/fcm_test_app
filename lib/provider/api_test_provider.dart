import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../domain/api_request_model.dart';

class ApiTestState {
  final String endpoint;
  final String body;
  final String? response;
  final bool isLoading;
  final String? error;
  final HttpMethod method;
  final Map<String, String> queryParams;
  final String jwtToken;

  ApiTestState({
    this.endpoint = '',
    this.body = '',
    this.response,
    this.isLoading = false,
    this.error,
    this.method = HttpMethod.get,
    this.queryParams = const {},
    this.jwtToken = '',
  });

  ApiTestState copyWith({
    String? endpoint,
    String? body,
    String? response,
    bool? isLoading,
    String? error,
    HttpMethod? method,
    Map<String, String>? queryParams,
    String? jwtToken,
  }) {
    return ApiTestState(
      endpoint: endpoint ?? this.endpoint,
      body: body ?? this.body,
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      method: method ?? this.method,
      queryParams: queryParams ?? this.queryParams,
      jwtToken: jwtToken ?? this.jwtToken,
    );
  }

  bool get hasValidToken => jwtToken.isNotEmpty;
}

class ApiTestNotifier extends StateNotifier<ApiTestState> {
  ApiTestNotifier() : super(ApiTestState());

  void updateEndpoint(String endpoint) {
    state = state.copyWith(endpoint: endpoint);
  }

  void updateBody(String body) {
    state = state.copyWith(body: body);
  }

  void updateMethod(HttpMethod method) {
    state = state.copyWith(method: method);
  }

  void updateJwtToken(String token) {
    state = state.copyWith(jwtToken: token);
  }

  void updateQueryParams(String queryString) {
    try {
      final params = <String, String>{};
      if (queryString.isNotEmpty) {
        final pairs = queryString.split('&');
        for (var pair in pairs) {
          final keyValue = pair.split('=');
          if (keyValue.length == 2) {
            params[keyValue[0]] = keyValue[1];
          }
        }
      }
      state = state.copyWith(queryParams: params);
    } catch (e) {
      state = state.copyWith(error: '쿼리 파라미터 형식이 올바르지 않습니다.');
    }
  }

  String _buildUrl() {
    final uri = Uri.parse(state.endpoint);
    if (state.method == HttpMethod.get && state.queryParams.isNotEmpty) {
      return uri.replace(queryParameters: state.queryParams).toString();
    }
    return state.endpoint;
  }

  Future<void> sendRequest() async {
    try {
      state = state.copyWith(isLoading: true, error: null, response: null);

      final request = ApiRequestModel(
        endpoint: _buildUrl(),
        body: state.body,
        method: state.method,
        jwtToken: state.jwtToken,
      );

      http.Response response;
      switch (request.method) {
        case HttpMethod.get:
          response = await http.get(
            Uri.parse(request.endpoint),
            headers: request.headers,
          );
          break;
        case HttpMethod.post:
          response = await http.post(
            Uri.parse(request.endpoint),
            headers: request.headers,
            body: request.body,
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(
            Uri.parse(request.endpoint),
            headers: request.headers,
            body: request.body.isEmpty ? null : request.body,
          );
          break;
        case HttpMethod.patch:
          response = await http.patch(
            Uri.parse(request.endpoint),
            headers: request.headers,
            body: request.body,
          );
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        state = state.copyWith(
          response: const JsonEncoder.withIndent('  ').convert(responseData),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: 'Error: ${response.statusCode} - ${response.body}',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Error: $e', isLoading: false);
    }
  }
}

final apiTestProvider = StateNotifierProvider<ApiTestNotifier, ApiTestState>((
  ref,
) {
  return ApiTestNotifier();
});
