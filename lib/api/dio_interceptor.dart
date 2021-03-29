import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:mysample/model/placement_detail.dart';

import 'api_controller.dart';
import 'api_manger.dart';
import 'api_response.dart';

enum API_ERROR {
  NO_FOUND_AUTH,
}

BaseOptions baseOptions = new BaseOptions(
    baseUrl: "https://test.vinceredev.com/api/v2/",
    connectTimeout: 5000,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    receiveTimeout: 5000,
    validateStatus: (code) {
      if (code <= 201) return true;
      return false;
    });

final dio = new Dio(baseOptions)
  ..interceptors.addAll([
    requestInterceptor,
    errorInterceptor,
    responseInterceptor,
    LogInterceptor(responseBody: false)
  ]);
final tokenDio = new Dio(baseOptions)..interceptors.add(errorInterceptor);

final requestInterceptor =
    InterceptorsWrapper(onRequest: (requestOption) async {
  if (authHeaders == null) {
    return DioError(error: API_ERROR.NO_FOUND_AUTH, type: DioErrorType.DEFAULT);
  }
  requestOption.headers.addAll(authHeaders);

  return requestOption;
});

final errorInterceptor = InterceptorsWrapper(onError: (DioError error) async {
  switch (error.type) {
    case DioErrorType.CONNECT_TIMEOUT:
      // TODO: Handle this case.
      break;
    case DioErrorType.SEND_TIMEOUT:
      // TODO: Handle this case.
      break;
    case DioErrorType.RECEIVE_TIMEOUT:
      // TODO: Handle this case.
      break;
    case DioErrorType.RESPONSE:
      switch (error.response.statusCode) {
        case 404:
          print("Handle this error");
          return error.response;
      }
      break;
    case DioErrorType.CANCEL:
      if (CancelToken.isCancel(error)) {
        print("Token was canceled");
      }
      break;
    case DioErrorType.DEFAULT:
      if (error.error == API_ERROR.NO_FOUND_AUTH) {
        dio.lock();
        await APIController.request(
          apiType: APIType.test,
          tokenDio: tokenDio,
        );
        authHeaders = {
          'id-token':
              "eyJraWQiOiJtUTBnSTNUXC9QdW1kV241V0tVblVnNStLYTUxK0dQNktrckVCSTg0TlgzWT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI0ZmFiODdkNS1kOTJiLTRkNmItODRkYy0wMzMyZmFiNmFjOWIiLCJhdWQiOiI2cm4xMjBjbXRpNWNpbzdtc2twcmgxc2pnZSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJldmVudF9pZCI6IjVkYTAzYWQ2LTdkZWEtNDdiOS1iN2I0LWZlYmYwYWRkMDA5NSIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjE2NzMwMjkzLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAuYXAtc291dGhlYXN0LTEuYW1hem9uYXdzLmNvbVwvYXAtc291dGhlYXN0LTFfYkxURmJORWpoIiwiY29nbml0bzp1c2VybmFtZSI6IjRmYWI4N2Q1LWQ5MmItNGQ2Yi04NGRjLTAzMzJmYWI2YWM5YiIsImV4cCI6MTYxNjczMzk1NiwiaWF0IjoxNjE2NzMwMzU3LCJlbWFpbCI6Im5obmdoaWEyNDA2QGdtYWlsLmNvbSJ9.THSjPIJnEm1sFkKt4gywEo1yY9ByYv_BklXPxPk3fVyw9Nx_NBUzVpT-r-6vXILjZ_TV5NEZee9AX_PxwMMeUxK4FbeFvNSgtLydIlkM-vilSkxnZRdRsKG96q6z7qz89pd7vhBL1oanBtIWFx2zVx0lw65vkmf8R0XjOBvIcfbXqJRGSEnZtAZXo73PX7wffuGq-cZMbvMK_ERibTPwjyZ0aaQvXl58cT9U2POutEKpKaOIpl4E7dYeIjFkEvEyq1f05x318xvQ9XGMkhowf7JbTbIbAkmNsYIY20IA4As8OliU0Z5_G8_RDS0oCY-ugfDQa0Etq2m6zYAKeyKouw",
          'x-api-key': "7351252421522e1ea2182d5790d8f67c",
        };
        error.request.headers.addAll(authHeaders);
        dio.unlock();

        final Response prevResponse = await dio.request(error.request.path,
            data: error.request.data,
            queryParameters: error.request.queryParameters,
            options: error.request);
        return prevResponse;
      } else {
        final isOffline = _checkConnection(error);
        if (isOffline) return await _handleOfflineRequest(error);
        return error;
      }
      // TODO: Handle this case.
      break;
  }
  return error.response;
});

final responseInterceptor = InterceptorsWrapper(onResponse: (response) async {

  return response;
});

_handleOfflineRequest(DioError error) async {
  Completer<Response> offlineCompleter = new Completer();
  Connectivity().onConnectivityChanged.listen((connectionState) async {
    if (connectionState != ConnectivityResult.none) {
      dio.unlock();
      final Response response = await dio.request(error.request.path,
          data: error.request.data,
          queryParameters: error.request.queryParameters,
          options: error.request);
      if (response != null)
        offlineCompleter.complete(response);
      else
        offlineCompleter.completeError(DioErrorType.DEFAULT);
      offlineCompleter = new Completer();
    }
  });
  return offlineCompleter.future;
}

_checkConnection(DioError error) {
  return error.type == DioErrorType.DEFAULT &&
      error.error != null &&
      error.error is SocketException;
}
