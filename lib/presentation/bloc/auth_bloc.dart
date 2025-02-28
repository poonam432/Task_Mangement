import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/infrastructure/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.login(event.email, event.password);
        emit(AuthSuccess(token.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString())); // Shows actual API error
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.register(event.email, event.password);
        emit(AuthSuccess(token.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
