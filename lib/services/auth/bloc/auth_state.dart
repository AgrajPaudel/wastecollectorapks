import 'package:flutter/cupertino.dart';
import 'package:wastecollector/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  //adding loading scrrens to all our states.
  final bool isLoading;
  final String? text;
  const AuthState({
    required this.isLoading,
    this.text = 'Please wait a moment',
  }); //constructor for abstract class, for extended class to call constructor, this is needed.
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedin extends AuthState {
  //for loggedin users.
  final AuthUser user;
  const AuthStateLoggedin({required this.user, required bool isLoading})
      : super(isLoading: isLoading); //initializing final variable
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  //equatable is for mutations(fn overloading kind of).
  final Exception? exception;
  const AuthStateLoggedOut({
    //for incorrect credentials login attempt, for wrong data, exception+isloading, for correct data:isloading+not_exception.
    required bool isLoading,
    required bool client,
    required this.exception,
    String? text,
  }) : super(isLoading: isLoading, text: text);

  @override
  // returns list of properties.
  List<Object?> get props => [exception, isLoading];
}

//hauler side from here on

class AuthstateHaulerside extends AuthState with EquatableMixin {
  //equatable is for mutations(fn overloading kind of).
  final Exception? exception;
  const AuthstateHaulerside({
    //for incorrect credentials login attempt, for wrong data, exception+isloading, for correct data:isloading+not_exception.
    required bool isLoading,
    required bool client,
    required this.exception,
    String? text,
  }) : super(isLoading: isLoading, text: text);

  @override
  // returns list of properties.
  List<Object?> get props => [exception, isLoading];
}

class AuthStateHaulerLogin extends AuthState {
  const AuthStateHaulerLogin({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateHaulerLoggedin extends AuthState {
  //for loggedin haulers.
  final AuthUser user;
  const AuthStateHaulerLoggedin({required this.user, required bool isLoading})
      : super(isLoading: isLoading); //initializing final variable
}

class AuthStateHaulertoClientSwitch extends AuthState {
  const AuthStateHaulertoClientSwitch({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateClienttoHaulerSwitch extends AuthState {
  const AuthStateClienttoHaulerSwitch({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateHaulercollect extends AuthState {
  const AuthStateHaulercollect({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateHaulercollection extends AuthState {
  const AuthStateHaulercollection({required bool isloading})
      : super(isLoading: isloading);
}

class Authstatechooser extends AuthState {
  const Authstatechooser({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateScheduledCollection extends AuthState {
  const AuthStateScheduledCollection({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateUnScheduledCollection extends AuthState {
  const AuthStateUnScheduledCollection({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateUnscheduledCollectionList extends AuthState {
  const AuthStateUnscheduledCollectionList({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateInsideUnscheduledCollection extends AuthState {
  const AuthStateInsideUnscheduledCollection({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateInsideCompensatoryCollection extends AuthState {
  const AuthStateInsideCompensatoryCollection({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateCompensatorychooser extends AuthState {
  const AuthStateCompensatorychooser({required bool isloading})
      : super(isLoading: isloading);
}

class AuthStateLoginpage extends AuthState {
  const AuthStateLoginpage({required bool isloading})
      : super(isLoading: isloading);
}
