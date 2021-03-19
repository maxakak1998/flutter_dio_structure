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
  static Future<Response<T>> request<T>(
      {GenericObject<T> createFrom,
      @required APIType apiType,
      Map<String, dynamic> params,
      Dio tokenDio,
      Map<String, dynamic> body}) async {
    assert(apiType != null);

    final RequestOptions option = APIManager.getOption(apiType);
    option.queryParameters = params;
    option.data = body;
    if (createFrom != null) option.extra = {"createBy": createFrom()};
    Response<T> response;
    if (tokenDio != null)
      response = await tokenDio.request<T>(option.path, options: option);
    else
      response = await dio.request<T>(option.path, options: option);

    return response;
  }
}
