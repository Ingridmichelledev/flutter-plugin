// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseDynamicLinks', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      FirebaseDynamicLinks.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        final Map<dynamic, dynamic> returnUrl = <dynamic, dynamic>{
          'url': 'google.com',
          'warnings': <dynamic>['This is only a test link'],
        };
        switch (methodCall.method) {
          case 'DynamicLinkParameters#buildUrl':
            return 'google.com';
          case 'DynamicLinkParameters#buildShortLink':
            return returnUrl;
          case 'DynamicLinkParameters#shortenUrl':
            return returnUrl;
          default:
            return null;
        }
      });
      log.clear();
    });

    group('$DynamicLinkParameters', () {
      test('shortenUrl', () async {
        final Uri url = Uri.parse('google.com');
        final DynamicLinkParametersOptions options =
            new DynamicLinkParametersOptions(
                shortDynamicLinkPathLength:
                    ShortDynamicLinkPathLength.unguessable);

        await DynamicLinkParameters.shortenUrl(url, options);

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#shortenUrl',
            arguments: <String, dynamic>{
              'url': url.toString(),
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.unguessable.index,
              },
            },
          ),
        ]);
      });

      test('$AndroidParameters', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          androidParameters: new AndroidParameters(
            fallbackUrl: Uri.parse('test-url'),
            minimumVersion: 1,
            packageName: 'test-package',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': <String, dynamic>{
                'fallbackUrl': 'test-url',
                'minimumVersion': 1,
                'packageName': 'test-package',
              },
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': <String, dynamic>{
                'fallbackUrl': 'test-url',
                'minimumVersion': 1,
                'packageName': 'test-package',
              },
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$DynamicLinkParametersOptions', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          dynamicLinkParametersOptions: new DynamicLinkParametersOptions(
              shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.short.index,
              },
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.short.index,
              },
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$ShortDynamicLinkPathLength', () {
        expect(ShortDynamicLinkPathLength.unguessable.index, 0);
        expect(ShortDynamicLinkPathLength.short.index, 1);
      });

      test('$GoogleAnalyticsParameters', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          googleAnalyticsParameters: new GoogleAnalyticsParameters(
            campaign: 'where',
            content: 'is',
            medium: 'my',
            source: 'cat',
            term: 'friend',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': <String, dynamic>{
                'campaign': 'where',
                'content': 'is',
                'medium': 'my',
                'source': 'cat',
                'term': 'friend',
              },
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': <String, dynamic>{
                'campaign': 'where',
                'content': 'is',
                'medium': 'my',
                'source': 'cat',
                'term': 'friend',
              },
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$IosParameters', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          iosParameters: IosParameters(
            appStoreId: 'is',
            bundleId: 'this',
            customScheme: 'the',
            fallbackUrl: Uri.parse('place'),
            ipadBundleId: 'to',
            ipadFallbackUrl: Uri.parse('find'),
            minimumVersion: 'potatoes',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': <String, dynamic>{
                'appStoreId': 'is',
                'bundleId': 'this',
                'customScheme': 'the',
                'fallbackUrl': 'place',
                'ipadBundleId': 'to',
                'ipadFallbackUrl': 'find',
                'minimumVersion': 'potatoes',
              },
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': <String, dynamic>{
                'appStoreId': 'is',
                'bundleId': 'this',
                'customScheme': 'the',
                'fallbackUrl': 'place',
                'ipadBundleId': 'to',
                'ipadFallbackUrl': 'find',
                'minimumVersion': 'potatoes',
              },
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$ItunesConnectAnalyticsParameters', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          itunesConnectAnalyticsParameters:
              new ItunesConnectAnalyticsParameters(
            affiliateToken: 'hello',
            campaignToken: 'mister',
            providerToken: 'rose',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': <String, dynamic>{
                'affiliateToken': 'hello',
                'campaignToken': 'mister',
                'providerToken': 'rose',
              },
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': <String, dynamic>{
                'affiliateToken': 'hello',
                'campaignToken': 'mister',
                'providerToken': 'rose',
              },
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$NavigationInfoParameters', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          navigationInfoParameters:
              new NavigationInfoParameters(forcedRedirectEnabled: true),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': <String, dynamic>{
                'forcedRedirectEnabled': true,
              },
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': <String, dynamic>{
                'forcedRedirectEnabled': true,
              },
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$SocialMetaTagParameters', () async {
        final DynamicLinkParameters components = new DynamicLinkParameters(
          domain: 'test-domain',
          link: Uri.parse('test-link.com'),
          socialMetaTagParameters: SocialMetaTagParameters(
            description: 'describe',
            imageUrl: Uri.parse('thisimage'),
            title: 'bro',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': <String, dynamic>{
                'description': 'describe',
                'imageUrl': 'thisimage',
                'title': 'bro',
              },
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'domain': 'test-domain',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': <String, dynamic>{
                'description': 'describe',
                'imageUrl': 'thisimage',
                'title': 'bro',
              },
            },
          ),
        ]);
      });
    });
  });
}
