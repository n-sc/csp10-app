import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';

class UserRepository {
  final API _apiClient;
  List<User>? _users;

  UserRepository({API? apiClient}) : _apiClient = apiClient ?? API();

  Future<List<User>> get users async {
    return _users ??= await getUsers();
  }

  Future<List<User>> getUsers() async {
    var response = await _apiClient.getProtected('/users');
    List<User> users = [];
    switch (response) {
      case ContentListAPIResponse _:
        for (var element in response.data) {
          users.add(User.fromJson(element as Map<String, dynamic>));
        }
        return users;
      default:
        throw ErrorAPIResponse('Error in getUsers()');
    }
  }
}
