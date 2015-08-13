library dart_dev.src.tasks.format.cli;

import 'dart:async';

import 'package:args/args.dart';

import 'package:dart_dev/util.dart' show hasImmediateDependency, reporter;

import 'package:dart_dev/src/tasks/format/api.dart';
import 'package:dart_dev/src/tasks/format/config.dart';
import 'package:dart_dev/src/tasks/cli.dart';
import 'package:dart_dev/src/tasks/config.dart';

class FormatCli extends TaskCli {
  final ArgParser argParser = new ArgParser()
    ..addFlag('check',
        defaultsTo: defaultCheck,
        negatable: false,
        help:
            'Dry-run; checks if formatter needs to be run and sets exit code accordingly.');

  final String command = 'format';

  Future<CliResult> run(ArgResults parsedArgs) async {
    try {
      if (!hasImmediateDependency('dart_style')) return new CliResult.fail(
          'Package "dart_style" must be an immediate dependency in order to run its executables.');
    } catch (e) {
      // It's possible that this check may throw if the pubspec.yaml
      // could not be found or if the yaml could not be parsed.
      // We silence this error and let the task continue in case it
      // was a false negative. If it was accurate, then the task will
      // fail anyway and the error will be available in the output.
    }

    bool check = TaskCli.valueOf('check', parsedArgs, config.format.check);
    List<String> directories = config.format.directories;

    FormatTask task = format(check: check, directories: directories);
    reporter.logGroup(task.formatterCommand,
        outputStream: task.formatterOutput);
    await task.done;

    if (task.isDryRun) {
      if (task.successful) return new CliResult.success(
          'You\'re Dart code is good to go!');
      if (task.affectedFiles.isEmpty) return new CliResult.fail(
          'The Dart formatter needs to be run.');
      return new CliResult.fail(
          'The Dart formatter needs to be run. The following files require changes:\n    ' +
              task.affectedFiles.join('\n    '));
    } else {
      if (!task.successful) return new CliResult.fail('Dart formatter failed.');
      if (task.affectedFiles.isEmpty) return new CliResult.success(
          'Success! All files are already formatted correctly.');
      return new CliResult.success(
          'Success! The following files were formatted:\n    ' +
              task.affectedFiles.join('\n    '));
    }
  }
}
