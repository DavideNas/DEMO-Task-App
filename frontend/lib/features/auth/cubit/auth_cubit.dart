import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      //final userModel =
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      // emit(AuthLoggedIn(userModel));
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      emit(AuthLoggedIn(userModel));
    } catch (e, stackTrace) {
      print("ERRORE CATTURATO: $e");
      await Sentry.captureException(e, stackTrace: stackTrace);
      emit(AuthError(e.toString()));
    }
  }
}
