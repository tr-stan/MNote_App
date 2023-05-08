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

import 'dart:convert';

import 'package:googleapis/firestore/v1.dart';

import 'package:shelf/shelf.dart';

import 'helper.dart';

Middleware ensureResponsesHaveHeaders() {
  return createMiddleware(responseHandler: (response) {
    return response.change(headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'public, max-age=604800',
    });
  });
}

Middleware authenticate(FirestoreApi api) {
  return createMiddleware(requestHandler: (request) async {
    if (request.requestedUri.path == '/v1/' ||
        request.requestedUri.path == '/v1' ||
        request.requestedUri.path.contains('v1/users/login') ||
        request.requestedUri.path.contains('v1/users/register')) {
      return null;
    }

    var token = request.headers['Authorization'];

    if (token == null || token.trim().isEmpty) {
      return Response.forbidden(jsonEncode({'message': 'Unauthenticated'}));
    }
    if (token.contains('Bearer')) {
      token = token.substring(6).trim();
    }

    try {
      final docs = await Helper.getDocs(api, 'users');
      final tokenValid = (docs.documents ?? []).isNotEmpty &&
          docs.documents!.any(
              (e) => e.fields!.values.any((el) => el.stringValue == token));

      if (!tokenValid) {
        return Response.forbidden(
            jsonEncode({'message': 'Invalid API token: ${token}'}));
      }
      return null;
    } on Exception {
      return Helper.error();
    }
  });
}
