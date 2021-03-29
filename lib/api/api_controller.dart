import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mysample/api/api_manger.dart';

import '../main.dart';
import '../model/placement_detail.dart';
import 'api_response.dart';
import 'dio_interceptor.dart';

Map<String, dynamic> authHeaders;

class APIController {
  static Future<T> request<T>(
      {GenericObject<T> createFrom,
      @required APIType apiType,
      Map<String, dynamic> params,
      Dio tokenDio,
      String extraPath,
      Map<String, dynamic> body}) async {
    assert(apiType != null);

    final RequestOptions option = APIManager.getOption(apiType);
    option.queryParameters = params;
    if (extraPath != null) option.path += extraPath;
    option.data = body;
    Response response;
    if (tokenDio != null)
      response = await tokenDio.request(option.path, options: option);
    else
      response = await dio.request(option.path, options: option);
    T apiWrapper;
    if (createFrom != null) apiWrapper = createFrom(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (apiWrapper is BaseAPIWrapper) return apiWrapper;

      ///If you want to use another object type such as primitive type, but you need to ensure that the response type will match your expected type
      if (response.data is T) {
        return response.data;
      } else {
        throw ErrorResponse(response,
            "Can not match the $T type with ${response.data.runtimeType}");
      }
    }
    throw ErrorResponse(response, response.statusMessage);
  }
}
