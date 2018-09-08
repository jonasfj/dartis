// Copyright (c) 2018, Juan Mellado. All rights reserved. Use of this source
// is governed by a MIT-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:dartis/dartis.dart';

import '../util.dart' show uuid;

void main() {
  Client client;
  ClusterCommands<String> commands;

  // Some values for testing.
  const masterId = '<ID>';
  const slaveId = '<ID>';
  const replicaId = '<ID>';
  const meetIp = '<IP>';
  const meetPort = 0;

  setUp(() async {
    client = await Client.connect('redis://localhost:6379');
    commands = client.asCommands<String, String>();
  });

  tearDown(() async {
    await client.disconnect();
  });

  group('ClusterCommands', () {
    test('clusterAddslots', () async {
      await commands.clusterAddslots(slot: 1);
      await commands.clusterAddslots(slots: [2, 3]);
    });

    test('clusterCountFailureReports', () async {
      expect(await commands.clusterCountFailureReports(masterId),
          greaterThanOrEqualTo(0));
    });

    test('clusterCountkeysinslot', () async {
      expect(await commands.clusterCountkeysinslot(1), greaterThanOrEqualTo(0));
    });

    test('clusterDelslots', () async {
      await commands.clusterDelslots(slot: 1);
      await commands.clusterDelslots(slots: [2, 3]);
    });

    test('clusterFailover', () async {
      await commands.clusterFailover();
      await commands.clusterFailover(ClusterFailoverMode.force);
      await commands.clusterFailover(ClusterFailoverMode.takeover);
    });

    test('clusterForget', () async {
      await commands.clusterForget(slaveId);
    });

    test('clusterGetkeysinslot', () async {
      await commands.clusterGetkeysinslot(1, 10);
    });

    test('clusterInfo', () async {
      expect(await commands.clusterInfo(), isNotEmpty);
    });

    test('clusterKeyslot', () async {
      final key = uuid();
      expect(await commands.clusterKeyslot(key), greaterThanOrEqualTo(0));

      final slot1 = await commands.clusterKeyslot('${key}1{hash_tag}');
      final slot2 = await commands.clusterKeyslot('${key}2{hash_tag}');
      expect(slot1, equals(slot2));
    });

    test('clusterMeet', () async {
      await commands.clusterMeet(meetIp, meetPort);
    });

    test('clusterNodes', () async {
      expect(await commands.clusterNodes(), isNotEmpty);
    });

    test('clusterReplicate', () async {
      await commands.clusterReplicate(replicaId);
    });

    test('clusterReset', () async {
      await commands.clusterReset();
      await commands.clusterReset(ClusterResetMode.soft);
      await commands.clusterReset(ClusterResetMode.hard);
    });

    test('clusterSaveconfig', () async {
      await commands.clusterSaveconfig();
    });

    test('clusterSetConfigEpoch', () async {
      await commands.clusterSetConfigEpoch(0);
    });

    test('clusterSetslot', () async {
      await commands.clusterSetslot(1, ClusterSetslotCommand.importing,
          nodeId: masterId);
      await commands.clusterSetslot(1, ClusterSetslotCommand.migrating,
          nodeId: masterId);
      await commands.clusterSetslot(1, ClusterSetslotCommand.stable);
      await commands.clusterSetslot(1, ClusterSetslotCommand.node,
          nodeId: masterId);
    });

    test('clusterSlaves', () async {
      expect(await commands.clusterSlaves(masterId), isNotEmpty);
    });

    test('clusterSlots', () async {
      expect(await commands.clusterSlots(), isNotEmpty);
    });

    test('readonly', () async {
      await commands.readonly();
    });

    test('readwrite', () async {
      await commands.readwrite();
    });
  }, skip: 'Requires a Redis Cluster.');

  group('support', () {
    group('ClusterFailoverMode', () {
      test('toString', () {
        expect(ClusterFailoverMode.force.toString(),
            startsWith('ClusterFailoverMode:'));
      });
    });

    group('ClusterResetMode', () {
      test('toString', () {
        expect(
            ClusterResetMode.soft.toString(), startsWith('ClusterResetMode:'));
      });
    });

    group('ClusterSetslotCommand', () {
      test('toString', () {
        expect(ClusterSetslotCommand.node.toString(),
            startsWith('ClusterSetslotCommand:'));
      });
    });

    group('ClusterNode', () {
      test('toString', () {
        const value = ClusterNode(null, null);
        expect(value.toString(), startsWith('ClusterNode:'));
      });
    });

    group('ClusterSlotRange', () {
      test('toString', () {
        const value = ClusterSlotRange(null, null, null);
        expect(value.toString(), startsWith('ClusterSlotRange:'));
      });
    });
  });
}
