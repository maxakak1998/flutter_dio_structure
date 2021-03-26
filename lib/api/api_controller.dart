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
    final apiWrapper = createFrom();
    if (response.statusCode == 200) {
      ///If you use the object that implementing from BaseAPIWrapper
      if (apiWrapper is BaseAPIWrapper) {
        apiWrapper.response = response;

        ///Ensure that you send right object for the APIWrapper, because we will use this object to call fromJSON() if it implements from the Decoder abstract class
        ///so if data in APIWrapper you send is either null or object not implementing from Decoder, we just give you whatever the response is
        if (apiWrapper.data != null && apiWrapper.data is Decoder) {
          apiWrapper.data = apiWrapper.data.fromJSON(response.data);
        }
        return apiWrapper..data = response.data;
      } else {
        ///If you want to use another object type such as primitive type, but you need to ensure that the response type will match your expected type
        if (response.data is T) {
          return response.data;
        } else
          throw FormatException(
              "Can not match the $T type with ${response.data.runtimeType}");
      }
    }
    return response.data;
  }
}
