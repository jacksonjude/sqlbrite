import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlbrite/src/query_stream.dart';
import 'package:sqlbrite/src/type_defs.dart';

Stream<Query> _queryStream(int numberOfRows) {
  return Stream<Query>.value(
    () => Future.value(
      List.filled(
        numberOfRows,
        <String, dynamic>{},
      ),
    ),
  );
}

void main() {
  group('Query Stream', () {
    group('mapToOneOrDefault', () {
      test('works', () async {
        // emits default value
        final defaultValue = {'default': 42};
        final stream0 = _queryStream(0).mapToOneOrDefault(
          (row) => row,
          defaultValue: defaultValue,
        );
        await expectLater(
          stream0,
          emits(defaultValue),
        );

        // emit mapped value
        final stream1 = _queryStream(1).mapToOneOrDefault((row) => row);
        await expectLater(
          stream1,
          emits(<String, dynamic>{}),
        );

        // emit error when query returned more than 1 row
        final stream2 = _queryStream(2).mapToOneOrDefault((row) => row);
        await expectLater(
          stream2,
          emitsError(isInstanceOf<StateError>()),
        );
      });

      test('shouldThrowA', () {
        expect(
          () => _queryStream(0).mapToOneOrDefault(null),
          throwsArgumentError,
        );
      });

      test('shouldThrowB', () async {
        final stream =
            Stream<Query>.error(Exception()).mapToOneOrDefault((_) => true);
        await expectLater(
          stream,
          emitsError(isA<Exception>()),
        );
      });

      test('shouldThrowC', () async {
        var i = 0;

        final stream = Rx.concat([
          _queryStream(1),
          _queryStream(1),
          _queryStream(1),
        ]).mapToOneOrDefault((row) {
          if (i++ == 1) {
            throw Exception();
          } else {
            return row;
          }
        });
        await expectLater(
          stream,
          emitsInOrder([
            isMap,
            emitsError(isException),
            isMap,
          ]),
        );
      });

      test('asBroadcastStream', () async {
        final stream =
            _queryStream(1).mapToOneOrDefault((row) => row).asBroadcastStream();

        // listen twice on same stream
        stream.listen(null);
        stream.listen(null);

        // code should reach here
        await expectLater(true, true);
      });

      test('pause.resume', () async {
        StreamSubscription subscription;

        subscription = _queryStream(1)
            .delay(const Duration(milliseconds: 500))
            .mapToOneOrDefault((i) => i)
            .listen(
          expectAsync1(
            (data) {
              expect(data, isMap);
              subscription.cancel();
            },
          ),
        );

        subscription.pause();
        subscription.resume();
      });
    });

    group('mapToOne', () {
      test('works', () async {
        // nothing is emitted
        final stream0 = _queryStream(0).mapToOne((row) => row);
        await expectLater(
          stream0,
          emitsDone,
        );

        // emit mapped value
        final stream1 = _queryStream(1).mapToOne((row) => row);
        await expectLater(
          stream1,
          emits(<String, dynamic>{}),
        );

        // emit error when query returned more than 1 row
        final stream2 = _queryStream(2).mapToOne((row) => row);
        await expectLater(
          stream2,
          emitsError(isInstanceOf<StateError>()),
        );
      });

      test('shouldThrowA', () {
        expect(
          () => _queryStream(0).mapToOne(null),
          throwsArgumentError,
        );
      });

      test('shouldThrowB', () async {
        final stream = Stream<Query>.error(Exception()).mapToOne((_) => true);
        await expectLater(
          stream,
          emitsError(isA<Exception>()),
        );
      });

      test('shouldThrowC', () async {
        var i = 0;

        final stream = Rx.concat([
          _queryStream(1),
          _queryStream(1),
          _queryStream(1),
        ]).mapToOne((row) {
          if (i++ == 1) {
            throw Exception();
          } else {
            return row;
          }
        });
        await expectLater(
          stream,
          emitsInOrder([
            isMap,
            emitsError(isException),
            isMap,
          ]),
        );
      });

      test('asBroadcastStream', () async {
        final stream =
            _queryStream(1).mapToOne((row) => row).asBroadcastStream();

        // listen twice on same stream
        stream.listen(null);
        stream.listen(null);

        // code should reach here
        await expectLater(true, true);
      });

      test('pause.resume', () async {
        StreamSubscription subscription;

        subscription = _queryStream(1)
            .delay(const Duration(milliseconds: 500))
            .mapToOne((i) => i)
            .listen(
          expectAsync1(
            (data) {
              expect(data, isMap);
              subscription.cancel();
            },
          ),
        );

        subscription.pause();
        subscription.resume();
      });
    });

    group('mapToList', () {
      test('works', () async {
        // emit empty list
        final stream0 = _queryStream(0).mapToList((row) => row);
        await expectLater(
          stream0,
          emits([]),
        );

        // emit list that contains single mapped value
        final stream1 = _queryStream(1).mapToList((row) => row);
        await expectLater(
          stream1,
          emits([<String, dynamic>{}]),
        );

        // emit list that contains 2 mapped values
        final stream2 = _queryStream(2).mapToList((row) => row);
        await expectLater(
          stream2,
          emits([
            <String, dynamic>{},
            <String, dynamic>{},
          ]),
        );
      });

      test('shouldThrowA', () {
        expect(
          () => _queryStream(0).mapToList(null),
          throwsArgumentError,
        );
      });

      test('shouldThrowB', () async {
        final stream = Stream<Query>.error(Exception()).mapToList((_) => true);
        await expectLater(
          stream,
          emitsError(isA<Exception>()),
        );
      });

      test('shouldThrowC', () async {
        var i = 0;

        final stream = Rx.concat([
          _queryStream(1),
          _queryStream(1),
          _queryStream(1),
        ]).mapToList((row) {
          if (i++ == 1) {
            throw Exception();
          } else {
            return row;
          }
        });
        await expectLater(
          stream,
          emitsInOrder([
            [<String, dynamic>{}],
            emitsError(isException),
            [<String, dynamic>{}],
          ]),
        );
      });

      test('asBroadcastStream', () async {
        final stream =
            _queryStream(1).mapToList((row) => row).asBroadcastStream();

        // listen twice on same stream
        stream.listen(null);
        stream.listen(null);

        // code should reach here
        await expectLater(true, true);
      });

      test('pause.resume', () async {
        StreamSubscription subscription;

        subscription = _queryStream(1)
            .delay(const Duration(milliseconds: 500))
            .mapToList((i) => i)
            .listen(
          expectAsync1(
            (data) {
              expect(data, isList);
              subscription.cancel();
            },
          ),
        );

        subscription.pause();
        subscription.resume();
      });
    });
  });
}
