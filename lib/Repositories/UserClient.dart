import 'package:crud_app/Models/AuthResponse.dart';
import 'package:crud_app/Models/LoginStructure.dart';
import 'package:crud_app/Models/User.dart';
import 'package:dio/dio.dart';
import 'DataService.dart';

const String BaseUrl = "https://cmsc2204-mobile-api.onrender.com/Auth";

class UserClient {
  final _dio = Dio(BaseOptions(baseUrl: BaseUrl));
  DataService _dataService = DataService();

  Future<AuthResponse?> Login(LoginStructure user) async {
    try {
      var response = await _dio.post("/login",
          data: {'username': user.username, 'password': user.password});

      var data = response.data['data'];

      var authResponse = new AuthResponse(data['userId'], data['token']);

      if (authResponse.token != null) {
        await _dataService.AddItem("token", authResponse.token);
      }

      return authResponse;
    } catch (error) {
      return null;
    }
  }

  Future<String> GetApiVersion() async {
    var response = await _dio.get("/ApiVersion");
    return response.data;
  }

  Future<void> deleteUser(String id) async {
    try {
      var token = await _dataService.TryGetItem("token");
      if (await _dataService.TryGetItem("token") != null) {
        var response = await _dio.post("/DeleteUserByID",
            options:
                Options(headers: {"id": id, "Authorization": "Bearer $token"}));
        print(response);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<User>?> GetUsersAsync() async {
    try {
      var token = await _dataService.TryGetItem("token");
      if (await _dataService.TryGetItem("token") != null) {
        var response = await _dio.get("/GetUsers",
            options: Options(headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token"
            }));
        List<User> users = new List.empty(growable: true);
        if (response != null) {
          for (var user in response.data) {
            users.add(User(user["Username"], user["Password"], user["Email"],
                user["AuthLevel"], user["_id"]));
          }
          return users;
        }
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }
}
