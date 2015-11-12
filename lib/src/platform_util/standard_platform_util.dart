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

library dart_dev.src.platform_util.standard_platform_util;

import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yamlicious/yamlicious.dart';

import 'package:dart_dev/src/platform_util/platform_util.dart';

class StandardPlatformUtil implements PlatformUtil {
  bool hasImmediateDependency(String packageName) {
    Map pubspec = _readPubspec();
    List deps = [];
    if (pubspec.containsKey('dependencies')) {
      deps.addAll((pubspec['dependencies'] as Map).keys);
    }
    if (pubspec.containsKey('dev_dependencies')) {
      deps.addAll((pubspec['dev_dependencies'] as Map).keys);
    }
    return deps.contains(packageName);
  }

  Future<bool> isExecutableInstalled(String executable) async {
    ProcessResult result = await Process.run('which', [executable]);
    return result.exitCode == 0;
  }

  void linkDependency(String packageName, {Directory linkTarget}) {
    Map pubspec = _readPubspec();
    var deps;
    if (pubspec.containsKey('dependencies')) {
      deps = pubspec['dependencies'] as Map;
    }
    if (pubspec.containsKey('dev_dependencies')) {
      deps = pubspec['dev_dependencies'] as Map;
    }

    if (deps.containsKey(packageName)) {
      // TODO: Cache the previous dependency spec somewhere.
      deps[packageName] = {'path': linkTarget.absolute.toString()};
      // TODO: Write the YAML file back out to pubspec.yaml.
      _writePubspec(pubspec);
    }
  }

  Map _readPubspec() {
    File pubspecFile = new File('pubspec.yaml');
    return loadYaml(pubspecFile.readAsStringSync());
  }

  void _writePubspec(Map pubspec) {
    File pubspecFile = new File('pubspec.yaml');
    pubspecFile.writeAsStringSync(toYamlString(pubspec), flush: true);
  }
}
