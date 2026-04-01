abstract class Constants {
  static const bool useFakeSession = bool.fromEnvironment("USE_FAKE_SESSION");
  static const String apiURL = String.fromEnvironment("API_URL");
  static const String keycloakURL = String.fromEnvironment("KEYCLOAK_URL");
}
