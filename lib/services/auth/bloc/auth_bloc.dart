import 'package:bloc/bloc.dart';
import 'package:wastecollector/services/auth/auth_provider.dart';

import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) async {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return; //user just goes to forgot password.
      }
      //user wants to send forgot password email.
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true, //displays overlay.
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null; //all good path.
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e; //not so good path.
      }

      //using values from above.
      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false, //displays overlay.
      ));
    });

    //function to send email verification.
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state); //not changing state of application, no change in view.
    });

    on<AuthEventRegister>((event, emit) async {
      //function to register user.
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        ); //creates new user.
        await provider.sendEmailVerification(); //sends email.
        emit(const AuthStateNeedsVerification(
            isloading:
                false)); //sends to verify email view,isloading=false as already loaded
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      //initialization
      //function to return current user
      await provider.initialize();
      final user = provider.currentUser; //finds current user
      print('initialize');
      if (user == null) {
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isloading: false));
      } else {
        emit(AuthStateLoggedin(
          user: user,
          isLoading: false,
        )); //not const
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      //for login
      emit(const AuthStateLoggedOut(
        isLoading: true,
        exception: null,
        text: 'Please wait',
      ));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(isLoading: false, exception: null));
          emit(const AuthStateNeedsVerification(isloading: false));
        } else {
          emit(const AuthStateLoggedOut(isLoading: false, exception: null));
          emit(AuthStateLoggedin(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        //to catch type exception.
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e));
      }
    });
  } //SUPER NEEDED FOR BLOC SUPERCLASS, authstateloading is initial state.
}
