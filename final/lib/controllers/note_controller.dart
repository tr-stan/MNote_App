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

import 'package:shelf/shelf.dart';

import 'package:googleapis/firestore/v1.dart';

import '../helpers/helper.dart';
import '../models/note.dart';

class NoteController {
  final FirestoreApi firestoreApi;
  NoteController(this.firestoreApi);

  Future<Response> destroy(String id) async {
    try {
      await firestoreApi.projects.databases.documents
          .delete('${Helper.doc}/notes/$id');
      return Response.ok(jsonEncode({'message': 'Delete successful'}));
    } on Exception {
      return Helper.error();
    }
  }

  Future<Response> index() async {
    try {
      final docList = await Helper.getDocs(firestoreApi, 'notes');
      final notes = docList.documents
          ?.map((e) =>
              e.fields?.map((key, value) => MapEntry(key, value.stringValue)))
          .toList();

      return Response.ok(jsonEncode(notes ?? <String>[]));
    } on Exception {
      return Helper.error();
    }
  }

  Future<Response> show(String id) async {
    try {
      final doc = await firestoreApi.projects.databases.documents
          .get('${Helper.doc}/notes/$id');
      final notes =
          doc.fields?.map((key, value) => MapEntry(key, value.stringValue));
      return Response.ok(jsonEncode(notes));
    } on Exception {
      return Helper.error();
    }
  }

  Future<Response> store(Request request) async {
    final req = await request.readAsString();
    final id = Helper.randomChars(15);
    final isEmpty = request.isEmpty || req.trim().isEmpty;

    if (isEmpty) {
      return Response.forbidden(jsonEncode({'message': 'Bad request'}));
    }

    final json = jsonDecode(req) as Map<String, dynamic>;
    final title = (json['title'] ?? '') as String;
    final description = (json['description'] ?? '') as String;

    if (title.isEmpty || description.isEmpty) {
      return Response.forbidden(
          jsonEncode({'message': 'All fields are required'}));
    }
    final note = Note(title: title, description: description, id: id);

    try {
      await Helper.push(firestoreApi,
          path: 'notes/$id',
          fields: note
              .toMap()
              .map((key, value) => MapEntry(key, Value(stringValue: value))));
      return Response.ok(note.toJson());
    } on Exception {
      return Helper.error();
    }
  }
}
