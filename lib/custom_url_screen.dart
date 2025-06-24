import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/api_test_provider.dart';
import 'domain/api_request_model.dart';

class CustomUrlScreen extends ConsumerWidget {
  const CustomUrlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(apiTestProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // JWT 토큰 입력
            TextField(
              decoration: const InputDecoration(
                labelText: 'JWT 토큰',
                border: OutlineInputBorder(),
                hintText: 'Bearer 토큰을 입력하세요',
              ),
              onChanged:
                  (value) =>
                      ref.read(apiTestProvider.notifier).updateJwtToken(value),
            ),
            if (state.hasValidToken) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'JWT 토큰이 설정되었습니다',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // HTTP 메서드 선택
            DropdownButtonFormField<HttpMethod>(
              value: state.method,
              decoration: const InputDecoration(
                labelText: 'HTTP 메서드',
                border: OutlineInputBorder(),
              ),
              items:
                  HttpMethod.values.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method.value),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(apiTestProvider.notifier).updateMethod(value);
                }
              },
            ),
            const SizedBox(height: 16),
            // Endpoint 입력
            TextField(
              decoration: const InputDecoration(
                labelText: '엔드포인트 URL 입력란',
                border: OutlineInputBorder(),
                hintText: 'https://api.example.com/endpoint',
              ),
              onChanged:
                  (value) =>
                      ref.read(apiTestProvider.notifier).updateEndpoint(value),
            ),
            const SizedBox(height: 16),
            // HTTP 메서드별 입력 필드
            if (state.method == HttpMethod.get) ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Query 입력란',
                  border: OutlineInputBorder(),
                  hintText: 'ex) key1=value1&key2=value2',
                ),
                onChanged:
                    (value) => ref
                        .read(apiTestProvider.notifier)
                        .updateQueryParams(value),
              ),
            ] else ...[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Body 데이터 (JSON)',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText:
                        state.method == HttpMethod.delete
                            ? '{"deleteExample": "data"} (선택사항)'
                            : '{"postExample": "data1"}',
                  ),
                  maxLines: null,
                  expands: true,
                  onChanged:
                      (value) =>
                          ref.read(apiTestProvider.notifier).updateBody(value),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // 요청 보내기 버튼
            ElevatedButton(
              onPressed:
                  state.isLoading
                      ? null
                      : () => ref.read(apiTestProvider.notifier).sendRequest(),
              child:
                  state.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('요청 보내기'),
            ),
            // 에러 메시지
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],
            // 응답 결과
            if (state.response != null) ...[
              const SizedBox(height: 16),
              const Text(
                '응답 결과:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(child: Text(state.response!)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
