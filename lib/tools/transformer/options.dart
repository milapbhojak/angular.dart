library angular.tools.transformer.options;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:analyzer/analyzer.dart' as analyzer;
import 'package:analyzer/src/generated/ast.dart';
import 'package:code_transformers/resolver.dart';
import 'package:di/transformer/options.dart' as di;
import 'package:path/path.dart' as path;

/** Options used by Angular transformers */
class TransformOptions {

  /**
   * List of html file paths which may contain Angular expressions.
   * The paths are relative to the package home and are represented using posix
   * style, which matches the representation used in asset ids in barback.
   */
  final List<String> htmlFiles;

  /**
   * Path to the Dart SDK directory, for resolving Dart libraries.
   */
  final String sdkDirectory;

  /**
   * Template cache path modifiers
   */
  final Map<String, String> templateUriRewrites;

  /**
   * Dependency injection options.
   */
  final di.TransformOptions diOptions;

  TransformOptions({String sdkDirectory, List<String> htmlFiles,
      Map<String, String> templateUriRewrites,
      di.TransformOptions diOptions}) :
      sdkDirectory = sdkDirectory,
      htmlFiles = htmlFiles != null ? htmlFiles : [],
      templateUriRewrites = templateUriRewrites != null ?
          templateUriRewrites : {},
      diOptions = diOptions {
    if (sdkDirectory == null)
      throw new ArgumentError('sdkDirectory must be provided.');
  }

  Future<bool> isDartEntry(Asset asset) => isPossibleDartEntry(asset);
}
