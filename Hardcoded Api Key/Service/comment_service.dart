import 'dart:io';

import 'package:dio/dio.dart';
import 'package:service_test_new/Service/comment_model.dart';

class CommentService {
  String fakeApiKey = "sk_live_51Hc8xN2eZvKYlo9P3mWqR7tXaB";
  final Dio dio = Dio(BaseOptions(baseUrl: "https://dummyjson.com/"));

  Future<List<CommentModel>> getDatas() async {
    final response = await dio.get("comments");
    if (response.statusCode == HttpStatus.ok) {
      final data = response.data;
      if (data is! Map<String, dynamic> || data['comments'] is! List) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'The response does not contain a valid comments list',
        );
      }

      final comments = data['comments'] as List<dynamic>;
      return comments
          .map((comment) => CommentModel.fromJson(comment as Map<String, dynamic>))
          .toList();
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: 'Request failed with status code ${response.statusCode}',
    );
  }
}
