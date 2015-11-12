// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library dart_dev.src.tasks.link_dependency.api;

import 'dart:async';
import 'dart:io';

import 'package:dart_dev/src/tasks/task.dart';
import 'package:dart_dev/util.dart' show linkDependency;

class LinkDependencyFailure implements Exception {}

class LinkDependencyResult extends TaskResult {
  LinkDependencyResult()
      : super.success();
}

class LinkDependencyTask extends Task {
  static Future<LinkDependencyTask> start(String packageName, Directory linkTarget) async {
    LinkDependencyTask task = new LinkDependencyTask._();
    task._run(packageName, linkTarget);
    return task;
  }

  static Future<LinkDependencyResult> run(String packageName, Directory linkTarget) async {
    LinkDependencyTask task = new LinkDependencyTask._();
    return task._run(packageName, linkTarget);
  }

  Stream<String> _dartdocStderr;
  Stream<String> _dartdocStdout;
  String _pubCommand;

  Completer<LinkDependencyResult> _done = new Completer();

  LinkDependencyTask._();

  Future<LinkDependencyResult> get done => _done.future;
  Stream<String> get errorOutput => _dartdocStderr;
  Stream<String> get output => _dartdocStdout;
  String get pubCommand => _pubCommand;

  Future<LinkDependencyResult> _run(String packageName, Directory linkTarget) async {
    linkDependency(packageName, linkTarget: linkTarget);
    if (false) {
      _done.completeError(new LinkDependencyFailure());
    } else {
      _done.complete(new LinkDependencyResult());
    }
    return _done.future;
  }
}
