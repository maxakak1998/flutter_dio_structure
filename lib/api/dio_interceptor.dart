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
    baseUrl: "https://dev3.vinceredev.com/api/v2/",
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
      // TODO: Handle this case.
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
          "eyJraWQiOiJtUTBnSTNUXC9QdW1kV241V0tVblVnNStLYTUxK0dQNktrckVCSTg0TlgzWT0iLCJhbGciOiJSUzI1NiJ9.eyJvcmlnaW5fanRpIjoiNWEwYjJiNTYtNzYzMC00ZjRlLTlmZDUtZTQ0NzVmODUyM2U0Iiwic3ViIjoiZGQ5YzRhYzQtMGMxOC00NGQwLTk5YTQtNTYyZjQ0OTYzNzhiIiwiYXVkIjoiNnJuMTIwY210aTVjaW83bXNrcHJoMXNqZ2UiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXZlbnRfaWQiOiIxM2RkM2U2ZS1iYjA1LTQxMmYtYWViMS00YmI1YjY5MjkzZWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU5NjQ0NTMzMywiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmFwLXNvdXRoZWFzdC0xLmFtYXpvbmF3cy5jb21cL2FwLXNvdXRoZWFzdC0xX2JMVEZiTkVqaCIsImNvZ25pdG86dXNlcm5hbWUiOiJkZDljNGFjNC0wYzE4LTQ0ZDAtOTlhNC01NjJmNDQ5NjM3OGIiLCJleHAiOjE1OTY1MTc5NDksImlhdCI6MTU5NjUxNDM0OSwiZW1haWwiOiJxdWFuZy5uZ3V5ZW5AYXBwcy1jeWNsb25lLmNvbSJ9.TOCJz19zescRMmOa-xB9PGcpkqQGT_6sBbM3NpBWxk18Blkp1eDJ4XtOksYCOmmGC7EP2naJR9tIJDqqOBis8ZP7IOYHFXQjbhxy2OeA13hr42W5J25AKd9lINQHHJ_llQ0Dkp3eSxGb4eEHbdZ3jUn_zjAg5mNkOIbrAMrVID6v5iSmjXGbeVEBOxnnHuYg9tXS3PGyPPPiWUTRDC7P3P8J4nKnScuvMlPjJOB3tl3Cps5A0hz9tw2TfiUXmLwLZhgbcJ4L-8U6ke9B9ZgHEeuQd9e8qCd121S2AQ",
          'x-api-key': "7351252421522e1ea2182d5790d8f67c",
        };
        error.request.headers.addAll(authHeaders);
        dio.unlock();

        final Response prevResponse = await dio.request(error.request.path,
            data: error.request.data,
            queryParameters: error.request.queryParameters,
            options: error.request);

        return prevResponse;
      }
      else {
        final isOffline = _checkConnection(error);
        if (isOffline) return await _handleOfflineRequest(error);
        return error;
      }
      // TODO: Handle this case.
      break;
  }
  return error;
});

final responseInterceptor = InterceptorsWrapper(onResponse: (response) async {
  if (response.request.extra != null) {
    final instance = response.request.extra["createBy"];
    if (instance != null && instance is Decoder) {
      try {
        response.data = instance.fromJSON(response.data);
      } catch (e) {}
    }
  }
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
