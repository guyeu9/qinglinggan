import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/user_config.dart';

class UserState {
  final String userName;
  final String userEmail;

  const UserState({
    this.userName = '灵感用户',
    this.userEmail = 'user@lightidea.app',
  });

  UserState copyWith({
    String? userName,
    String? userEmail,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState()) {
    _loadUserConfig();
  }

  Future<void> _loadUserConfig() async {
    await UserConfig.initialize();
    final name = UserConfig.cachedUserName;
    final email = UserConfig.cachedUserEmail;
    
    if (name != null || email != null) {
      state = state.copyWith(
        userName: name ?? state.userName,
        userEmail: email ?? state.userEmail,
      );
    }
  }

  Future<void> setUserName(String name) async {
    await UserConfig.setUserName(name);
    state = state.copyWith(userName: name);
  }

  Future<void> setUserEmail(String email) async {
    await UserConfig.setUserEmail(email);
    state = state.copyWith(userEmail: email);
  }

  Future<void> refresh() async {
    await _loadUserConfig();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
