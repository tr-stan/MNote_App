// Copyright (c) 2022 Razeware LLC

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding, application
// development,  or information technology.  Permission for such use, copying,
// modification, merger, publication, distribution, sublicensing, creation of
// derivative works, or sale is expressly withheld.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import 'dart:async';
import 'dart:convert';

import 'package:googleapis/firestore/v1.dart';
import 'package:shelf/shelf.dart';
import 'package:collection/collection.dart';

import '../helpers/helper.dart';
import '../models/user.dart';

class UserController {
  final FirestoreApi firestoreApi;

  UserController(this.firestoreApi);

  Future<Response> login(Request request) async {
    final req = await request.readAsString();
    if (request.isEmpty || !validate(req)) {
      return Response.forbidden(jsonEncode({'message': 'Bad request'}));
    }

    final mJson = jsonDecode(req) as Map<String, dynamic>;
    final docs = await Helper.getDocs(firestoreApi, 'users');
    if ((docs.documents ?? []).isEmpty) {
      return Response.notFound(jsonEncode({'message': 'User not found'}));
    }

    final user = docs.documents!.firstWhereOrNull((e) =>
        e.fields?['email']?.stringValue == mJson['email'] &&
        e.fields?['password']?.stringValue ==
            Helper.hash(mJson['password'] as String));

    if (user == null) {
      return Response.forbidden(
          jsonEncode({'message': 'Invalid email and/or password'}));
    }

    return Response.ok(jsonEncode(
        {'apiKey': docs.documents!.first.fields?['apiKey']?.stringValue}));
  }

  Future<Response> register(Request request) async {
    final req = await request.readAsString();
    if (request.isEmpty || !validate(req)) {
      return Response.forbidden(jsonEncode({'message': 'Bad request'}));
    }

    final mJson = jsonDecode(req) as Map<String, dynamic>;
    final apiKey = Helper.randomChars(40);
    final id = Helper.randomChars(15);
    final user = User(
        id: id,
        email: (mJson['email'] ?? '') as String,
        password: Helper.hash(mJson['password'] as String),
        apiKey: apiKey);

    try {
      Helper.push(firestoreApi,
          path: 'users/$id',
          fields: user
              .toMap()
              .map((key, value) => MapEntry(key, Value(stringValue: value))));
      return Response.ok(user.toJson());
    } on Exception {
      return Helper.error();
    }
  }

  bool validate(String req) {
    final json = jsonDecode(req) as Map;

    return req.trim().isNotEmpty &&
        json['email'] != null &&
        (json['email'] as String).trim().isNotEmpty &&
        json['password'] != null &&
        (json['password'] as String).trim().isNotEmpty;
  }
}
