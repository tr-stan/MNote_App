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

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import 'note_routes.dart';
import 'user_routes.dart';

/// Defines application's top-level routes
class AppRoutes {
  /// The FirestoreApi class from package:googleapis allows you
  /// to query and insert data into Cloud Firestore
  final FirestoreApi api;
  AppRoutes(this.api);

  Router get router {
    /// Creates a shelf_router Router. This allows you to route HTTP
    /// endpoints to handler functions.
    final router = Router();

    router.get('/', (Request request) {
      final aboutApp = {
        'name': 'MNote',
        'version': 'v1.0.0',
        'description': 'A minimal note management API to take and save notes'
      };
      return Response.ok(jsonEncode(aboutApp));
    });

    router.mount('/users', UserRoutes(api: api).router);
    router.mount('/notes', NoteRoutes(api: api).router);

    router.all(
      '/<ignore|.*>',
      (Request r) => Response.notFound(
        jsonEncode({'message': 'Route not defined'}),
      ),
    );
    return router;
  }
}
