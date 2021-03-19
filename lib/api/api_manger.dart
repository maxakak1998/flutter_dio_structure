

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_controller.dart';

enum HttpMethod { post, get, put, delete, deleteWithBody, multipleFileUpload }
enum APIType {
  test,
  testPost,
  placementDetail
}
class APIManager {
  APIType type;
  String param;

  APIManager({
    this.type,
    this.param,
  });

  static RequestOptions getOption(APIType apiType) {
    String method,path,baseUrl;
    switch(apiType){
      case APIType.test:
        path="get";
        baseUrl="http://httpbin.org/";
        method=describeEnum(HttpMethod.get);
        break;
      case APIType.testPost:
        path="post";
        baseUrl="http://httpbin.org/";

        method=describeEnum(HttpMethod.post);
        break;
      case APIType.placementDetail:
        path="placement/2034";
        break;
    }
    return new RequestOptions(
          baseUrl: baseUrl,
      validateStatus: (code){
        if(code <=201)
          return true;
        return false;
      },
          path: path,
          method: method,
    );
  }
}