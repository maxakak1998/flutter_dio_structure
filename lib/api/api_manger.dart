

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
        method=describeEnum(HttpMethod.get);
        break;
      case APIType.testPost:
        path="post";
        method=describeEnum(HttpMethod.post);
        break;
      case APIType.placementDetail:
        path="placement/2034";
        baseUrl="https://dev3.vinceredev.com/api/v2/";
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