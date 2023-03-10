// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_ios/google_sign_in_ios.dart';
import 'package:google_sign_in_ios/src/utils.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

const Map<String, String> kUserData = <String, String>{
  'email': 'john.doe@gmail.com',
  'id': '8162538176523816253123',
  'photoUrl': 'https://lh5.googleusercontent.com/photo.jpg',
  'displayName': 'John Doe',
  'idToken': '123',
  'serverAuthCode': '789',
};

const Map<dynamic, dynamic> kTokenData = <String, dynamic>{
  'idToken': '123',
  'accessToken': '456',
  'serverAuthCode': '789',
};

const Map<String, dynamic> kDefaultResponses = <String, dynamic>{
  'init': null,
  'signInSilently': kUserData,
  'signIn': kUserData,
  'signOut': null,
  'disconnect': null,
  'isSignedIn': true,
  'getTokens': kTokenData,
  'requestScopes': true,
};

final GoogleSignInUserData? kUser = getUserDataFromMap(kUserData);
final GoogleSignInTokenData kToken =
    getTokenDataFromMap(kTokenData as Map<String, dynamic>);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final GoogleSignInIOS googleSignIn = GoogleSignInIOS();
  final MethodChannel channel = googleSignIn.channel;

  late List<MethodCall> log;
  late Map<String, dynamic>
      responses; // Some tests mutate some kDefaultResponses

  setUp(() {
    responses = Map<String, dynamic>.from(kDefaultResponses);
    log = <MethodCall>[];
    channel.setMockMethodCallHandler((MethodCall methodCall) {
      log.add(methodCall);
      final dynamic response = responses[methodCall.method];
      if (response != null && response is Exception) {
        return Future<dynamic>.error('$response');
      }
      return Future<dynamic>.value(response);
    });
  });

  test('registered instance', () {
    GoogleSignInIOS.registerWith();
    expect(GoogleSignInPlatform.instance, isA<GoogleSignInIOS>());
  });

  test('init throws for SignInOptions.games', () async {
    expect(
        () => googleSignIn.init(
            hostedDomain: 'example.com',
            signInOption: SignInOption.games,
            clientId: 'fakeClientId'),
        throwsA(isInstanceOf<PlatformException>().having(
            (PlatformException e) => e.code, 'code', 'unsupported-options')));
  });

  test('signInSilently transforms platform data to GoogleSignInUserData',
      () async {
    final dynamic response = await googleSignIn.signInSilently();
    expect(response, kUser);
  });
  test('signInSilently Exceptions -> throws', () async {
    responses['signInSilently'] = Exception('Not a user');
    expect(googleSignIn.signInSilently(),
        throwsA(isInstanceOf<PlatformException>()));
  });

  test('signIn transforms platform data to GoogleSignInUserData', () async {
    final dynamic response = await googleSignIn.signIn();
    expect(response, kUser);
  });
  test('signIn Exceptions -> throws', () async {
    responses['signIn'] = Exception('Not a user');
    expect(googleSignIn.signIn(), throwsA(isInstanceOf<PlatformException>()));
  });

  test('getTokens transforms platform data to GoogleSignInTokenData', () async {
    final dynamic response = await googleSignIn.getTokens(
        email: 'example@example.com', shouldRecoverAuth: false);
    expect(response, kToken);
    expect(
        log[0],
        isMethodCall('getTokens', arguments: <String, dynamic>{
          'email': 'example@example.com',
          'shouldRecoverAuth': false,
        }));
  });

  test('clearAuthCache is a no-op', () async {
    await googleSignIn.clearAuthCache(token: 'abc');
    expect(log.isEmpty, true);
  });

  test('Other functions pass through arguments to the channel', () async {
    final Map<Function, Matcher> tests = <Function, Matcher>{
      () {
        googleSignIn.init(
            hostedDomain: 'example.com',
            scopes: <String>['two', 'scopes'],
            clientId: 'fakeClientId');
      }: isMethodCall('init', arguments: <String, dynamic>{
        'hostedDomain': 'example.com',
        'scopes': <String>['two', 'scopes'],
        'clientId': 'fakeClientId',
        'serverClientId': null,
      }),
      () {
        googleSignIn.initWithParams(const SignInInitParameters(
            hostedDomain: 'example.com',
            scopes: <String>['two', 'scopes'],
            clientId: 'fakeClientId',
            serverClientId: 'fakeServerClientId'));
      }: isMethodCall('init', arguments: <String, dynamic>{
        'hostedDomain': 'example.com',
        'scopes': <String>['two', 'scopes'],
        'clientId': 'fakeClientId',
        'serverClientId': 'fakeServerClientId',
      }),
      () {
        googleSignIn.getTokens(
            email: 'example@example.com', shouldRecoverAuth: false);
      }: isMethodCall('getTokens', arguments: <String, dynamic>{
        'email': 'example@example.com',
        'shouldRecoverAuth': false,
      }),
      () {
        googleSignIn.requestScopes(<String>['newScope', 'anotherScope']);
      }: isMethodCall('requestScopes', arguments: <String, dynamic>{
        'scopes': <String>['newScope', 'anotherScope'],
      }),
      googleSignIn.signOut: isMethodCall('signOut', arguments: null),
      googleSignIn.disconnect: isMethodCall('disconnect', arguments: null),
      googleSignIn.isSignedIn: isMethodCall('isSignedIn', arguments: null),
    };

    for (final Function f in tests.keys) {
      f();
    }

    expect(log, tests.values);
  });
}
