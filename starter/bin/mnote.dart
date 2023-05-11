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
import 'dart:io';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as server;

import 'package:mnote/routes/app_routes.dart';
import 'package:mnote/helpers/helper.dart';
import 'package:mnote/service_account_credentials.dart';

Future<void> main(List<String> arguments) async {
  final credentials = getCredentials();
  final client =
      await clientViaServiceAccount(credentials, [FirestoreApi.datastoreScope]);

  try {
    // 2
    final firestoreApi = FirestoreApi(client);
    // Creates a shelf_router Router object. A Router allows you to route HTTP
    // endpoints to handler functions.
    final app = Router();
    // 3
    app.mount('/v1', AppRoutes(firestoreApi).router);

    // Creates a handler with the router that adds logRequests()
    // middleware to log requests entering the application
    final handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(app);

    // Uses shelf to serve the application on port 8080 of any available address
    final mServer = await server.serve(handler, InternetAddress.anyIPv4, 8080);
    print('Server started at http://${mServer.address.host}:${mServer.port}');
  } on Exception {
    // 4
    Helper.error();
  }
}
