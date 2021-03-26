import 'package:dio/dio.dart';

typedef T GenericObject<T>();

abstract class Decoder<T> {
  T fromJSON(Map<String, dynamic> json);
}
abstract class BaseAPIWrapper{
  Response response;
  dynamic data;

  BaseAPIWrapper(this.response,this.data);
}
class APIResponse<T> extends BaseAPIWrapper{
  APIResponse({T data, Response response}):super(response,data);


}class APIListResponse<T> extends BaseAPIWrapper{
  APIListResponse({List<T> data, Response response}):super(response,data);
}