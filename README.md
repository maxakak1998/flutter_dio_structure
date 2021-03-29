# **Overall:**

  The simple structure for parsing generic object with Dio and json_serializable package.

# **Components conception**

  1. **APIController**: Collect each request config, neccessary information and send the request through Dio.
  2. **APIManager**: This is the place we will set up each request config in detail ( URL, Method,...).
  3. **APIResponse**:  This file will include the response which implemeting the abstract class named BaseAPIWrapper. 
  4. **Dio Interceptor**: This file will include all the Interceptors and BaseOptions ( baseURL, base header).

# **Features**

  - Call api refresh token automatically.
  - Queue the requests if the connection is offline and re-do it when we're online.
  - Support primitive response type like String
  - Support complex type like List<T>

# **How to use**

  ##  **Use with primitive response type**
  
```dart
     APIController.request<APIResponse<String>>(
                apiType: APIType.testPost,
                createFrom: (response) => APIResponse(response: response))
```
****     
```dart
       APIController.request<String>(apiType: APIType.testPost))
```
       
  ## **Use with Response implemetens from BaseAPIWrapper**
```dart
   APIController.request<APIResponse<PlacementDetail>>(
                    apiType: APIType.placementDetail,
                    extraPath: "/2122",
                    createFrom: (response) => APIResponse(data: PlacementDetail(),response: response))
```
****
```dart
 APIController.request<APIListResponse<Owner>>(
                apiType: APIType.allOwners,
                createFrom: (response) =>APIListResponse(createBy: Owner(),response: response))
```
