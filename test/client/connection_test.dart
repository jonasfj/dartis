// Copyright (c) 2018, Juan Mellado. All rights reserved. Use of this source
// is governed by a MIT-style license that can be found in the LICENSE file.

import 'dart:async' show Completer;

import 'package:test/test.dart';

import 'package:dartis/dartis.dart';

void main() {
  group('Connection', () {
    test('test connectivity with a PING command', () async {
      final connection = await Connection.connect('redis://localhost:6379');

      final completer = Completer<void>();

      // Handler.
      void onData(List<int> data) async {
        // PONG
        expect(data, equals([RespToken.string, 80, 79, 78, 71, 13, 10]));

        // Disconnect and complete the test.
        await connection.disconnect();
        completer.complete();
      }

      // Set the handler and send some raw data.
      connection
        ..listen(onData, null)
        ..send([
          RespToken.array, 49, 13, 10, // *1
          RespToken.bulk, 52, 13, 10, 80, 73, 78, 71, 13, 10 // $4 PING
        ]);

      await completer.future.timeout(Duration(seconds: 5),
          onTimeout: () => throw StateError('Timeout'));
    });
  });

  group('RedisUri', () {
    group('parse', () {
      test('some connection strings', () {
        expect(() => RedisUri.parse(''), throwsFormatException);
        expect(() => RedisUri.parse('test'), throwsFormatException);
        expect(() => RedisUri.parse('redis://'), throwsFormatException);
        expect(() => RedisUri.parse('redis://host'), throwsFormatException);
        expect(() => RedisUri.parse('redis://host:'), throwsFormatException);
        expect(() => RedisUri.parse('redis://host:abc'), throwsFormatException);
        expect(() => RedisUri.parse('redis://:123'), throwsFormatException);
        expect(() => RedisUri.parse('host:123'), throwsFormatException);

        final uri = RedisUri.parse('redis://localhost:6379');
        expect(uri.host, equals('localhost'));
        expect(uri.port, equals(6379));
      });
    });
  });
}
