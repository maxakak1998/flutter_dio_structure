import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mysample/api/api_response.dart';

import 'api_controller.dart';

enum HttpMethod { post, get, put, delete, deleteWithBody, multipleFileUpload }
enum APIType { test, testPost, placementDetail, allOwners }

class APIManager {
  APIType type;
  String param;

  APIManager({
    this.type,
    this.param,
  });

  static RequestOptions getOption(APIType apiType) {
    String method, path, baseUrl;
    ResponseType responseType = ResponseType.json;
    switch (apiType) {
      case APIType.test:
        path = "get";
        baseUrl = "http://httpbin.org/";
        method = describeEnum(HttpMethod.get);
        break;
      case APIType.testPost:
        path = "post";
        baseUrl = "http://httpbin.org/";
        responseType = ResponseType.plain;
        method = describeEnum(HttpMethod.post);
        break;
      case APIType.placementDetail:
        path = "placement";
        method = describeEnum(HttpMethod.get);
        break;
      case APIType.allOwners:
        path = "user/summaries/all";
        method = describeEnum(HttpMethod.get);
        break;
    }
    return new RequestOptions(
      baseUrl: baseUrl,
      validateStatus: (code) {
        if (code <= 201) return true;
        return false;
      },
      path: path,
      responseType: responseType,
      method: method,
    );
  }
}
