// TODO: Implement secure token storage using flutter_secure_storage
// Keys to store: access_token, refresh_token
// Methods: saveTokens(), getAccessToken(), getRefreshToken(), clearTokens()

class SecureStorage {
  // TODO: Inject FlutterSecureStorage instance

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    throw UnimplementedError();
  }

  Future<String?> getAccessToken() async {
    throw UnimplementedError();
  }

  Future<String?> getRefreshToken() async {
    throw UnimplementedError();
  }

  Future<void> clearTokens() async {
    throw UnimplementedError();
  }
}
