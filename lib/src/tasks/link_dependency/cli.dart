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

library dart_dev.src.tasks.link_dependency.cli;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_dev/util.dart' show hasImmediateDependency, reporter;
import 'package:path/path.dart' as path;

import 'package:dart_dev/src/tasks/cli.dart';
import 'package:dart_dev/src/tasks/link_dependency/api.dart';

class LinkDependencyCli extends TaskCli {
  ArgParser argParser = new ArgParser()
    ..addFlag('open',
        defaultsTo: true, help: 'Opens the docs site after being generated.');

  final String command = 'link';

  Future<CliResult> run(ArgResults parsedArgs) async {
    String packageName = parsedArgs.rest[0];
    Directory linkTarget = new Directory(parsedArgs.rest[1]);

    LinkDependencyResult result;
    try {
      LinkDependencyTask task = await LinkDependencyTask.start(packageName, linkTarget);
      reporter.logGroup(task.pubCommand,
          outputStream: task.output, errorStream: task.errorOutput);
      result = await task.done;
    } on LinkDependencyFailure catch (e) {
      return new CliResult.fail('$e');
    } catch (e, stackTrace) {
      return new CliResult.fail('$e\n$stackTrace');
    }
    return new CliResult.success(
        'Dependency linked: ${packageName}');
  }
}
