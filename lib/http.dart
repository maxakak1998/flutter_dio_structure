import 'package:dio/dio.dart';

 var dio = Dio()..interceptors.add(InterceptorsWrapper(
     onError: (error){
      print("KAKA Error ${error.message}");
     },
     onRequest: (request){
      print("KAKA ${request.data} ${request.path}");
     return request;
      },
     onResponse: (response){
      print("KAKA Response ${response.data}");
     }
 ));