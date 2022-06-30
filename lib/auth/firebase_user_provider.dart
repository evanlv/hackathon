import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class Hackathon2022FirebaseUser {
  Hackathon2022FirebaseUser(this.user);
  User user;
  bool get loggedIn => user != null;
}

Hackathon2022FirebaseUser currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
Stream<Hackathon2022FirebaseUser> hackathon2022FirebaseUserStream() =>
    FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<Hackathon2022FirebaseUser>(
            (user) => currentUser = Hackathon2022FirebaseUser(user));
