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
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:shelf/shelf.dart';

class Helper {
  /// The Google Cloud project ID. Replace with service account `project_id`
  static const projectId = 'mnote-c7379';

  /// This is the path to the default Cloud Firestore database for the project
  static const database = 'projects/$projectId/databases/(default)';

  /// Documents path on Cloud Firestore
  static const doc = '$database/documents';

  /// Generates random character strings. [length] determines how many
  /// characters are generated
  static String randomChars(int length) {
    final random = Random.secure();
    const acceptable =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return String.fromCharCodes(Iterable.generate(length,
        (v) => acceptable.codeUnitAt(random.nextInt(acceptable.length))));
  }

  /// Retrieves a list of documents from Cloud Firestore. The [api] is
  /// [FirestoreApi] from the [googleapis](https://pub.dev/packages/googleapis)
  /// package and [id] is the collection ID(e.g `users`) to retrieve from.
  static Future<ListDocumentsResponse> getDocs(
      FirestoreApi api, String id) async {
    return api.projects.databases.documents.list(Helper.doc, id);
  }

  /// Saves a document with fields [fields] to [path] on Cloud Firestore
  /// using the [googleapis](https://pub.dev/packages/googleapis) package
  static Future<void> push(FirestoreApi api,
      {required String path, required Map<String, Value> fields}) async {
    try {
      // Commit the document to the path on Cloud Firestore
      await api.projects.databases.documents.commit(
          CommitRequest(
            writes: [
              Write(
                  update: Document(name: Helper.doc + '/$path', fields: fields))
            ],
          ),
          Helper.database);
    } on Exception {
      rethrow;
    }
  }

  /// A helper function that returns a `500 Internal Server Error` JSON
  /// error response. Takes an optional [message] argument to return.
  static Response error({String? message}) {
    return Response.internalServerError(
        body: jsonEncode({'message': (message ?? 'There was an error')}));
  }

  /// Hashes a plaintext [password] in [rounds] rounds using the
  /// [crypto](https://pub.dev/packages/crypto) package.
  static String hash(String password, {int rounds: 200}) {
    var bytes = <int>[];
    // A salt to append to the hash
    final salt = 'You might want to add your own salt to the hash :]'.codeUnits;
    for (var i = 0; i < rounds; i++) {
      // Convert the password and the salt into a SHA256 hash as bytes
      bytes = sha256.convert([...bytes, ...password.codeUnits, ...salt]).bytes;
    }
    // Turn these bytes into a hexadecimal string
    return Digest(bytes).toString();
  }
}
