import 'dart:math';

import 'package:dio/dio.dart';

typedef T GenericObject<T>(_);

abstract class Decoder<T> {
  T fromJSON(Map<String, dynamic> json);
}

abstract class BaseAPIWrapper {
  Response response;
  dynamic data;

  BaseAPIWrapper({this.response, this.data}) {
    ///Ensure that you send right object for the APIWrapper, because we will use this object to call fromJSON() if it implements from the  abstract class Decoder
    ///so if data in APIWrapper you send is either null or object not implementing from Decoder, we just give you whatever the response is
    if (response != null) {
      if (data != null && data is Decoder)
        data = data.fromJSON(response.data);
      else
        data = response.data;
    }
  }
}

class APIResponse<T> extends BaseAPIWrapper {
  APIResponse({T data, Response response})
      : super(response: response, data: data);
}

class APIListResponse<T> extends BaseAPIWrapper {
  APIListResponse({T createBy, Response response}) : super(response: response) {
    data = new List<T>();
    if (response.data is List)
      response.data.forEach((item) {
        if (createBy is Decoder)
          data.add(createBy.fromJSON(item));
        else
          data.add(item);
      });
  }
}

class ErrorResponse extends BaseAPIWrapper {
  ErrorResponse(Response response, error)
      : super(response: response, data: error) {
    data = error;
  }
}
