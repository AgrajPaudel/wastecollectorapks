import 'package:flutter/cupertino.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({required this.email});
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
//from here on its haulers

class AuthEventHaulerview extends AuthEvent {
  const AuthEventHaulerview();
}

class AuthEventHaulerLogin extends AuthEvent {
  const AuthEventHaulerLogin();
}

class AuthEventHaulerLoggedin extends AuthEvent {
  final String email;
  final String password;
  const AuthEventHaulerLoggedin(this.email, this.password);
}

class AuthEventClienttoHaulerSwitch extends AuthEvent {
  const AuthEventClienttoHaulerSwitch();
}

class AuthEventHaulertoClientSwitch extends AuthEvent {
  const AuthEventHaulertoClientSwitch();
}

class AuthEventHaulerBack extends AuthEvent {
  const AuthEventHaulerBack();
}

class AuthEventHaulerCollect extends AuthEvent {
  const AuthEventHaulerCollect();
}

class AuthEventHaulerCollection extends AuthEvent {
  const AuthEventHaulerCollection();
}

class Autheventchooser extends AuthEvent {
  const Autheventchooser();
}

class AuthEventScheduledCollection extends AuthEvent {
  const AuthEventScheduledCollection();
}

class AuthEventUnScheduledCollection extends AuthEvent {
  const AuthEventUnScheduledCollection();
}

class AuthEventUnscheduledCollectionList extends AuthEvent {
  const AuthEventUnscheduledCollectionList();
}

class AuthEventInsideUnscheduledCollection extends AuthEvent {
  const AuthEventInsideUnscheduledCollection();
}

class AuthEventInsideCompensatoryCollection extends AuthEvent {
  const AuthEventInsideCompensatoryCollection();
}

class AuthEventCompensatoryChooser extends AuthEvent {
  const AuthEventCompensatoryChooser();
}

class AuthEventLoginpage extends AuthEvent {
  const AuthEventLoginpage();
}
