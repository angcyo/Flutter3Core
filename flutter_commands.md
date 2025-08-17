# `flutter` 命令行

https://docs.flutter.dev/reference/flutter-cli

## `create` 创建项目


- [dart create](https://dart.dev/tools/dart-create)

```shell
-t, --template=<type>     Specify the type of project to create.

          [app]           (default) Generate a Flutter application.
          [module]        Generate a project to add a Flutter module to an existing Android or iOS application.
          [package]       Generate a shareable Flutter project containing modular Dart code.
          [plugin]        Generate a shareable Flutter project containing an API in Dart code with a platform-specific implementation through method channels for
                          Android, iOS, Linux, macOS, Windows, web, or any combination of these.
          [plugin_ffi]    Generate a shareable Flutter project containing an API in Dart code with a platform-specific implementation through dart:ffi for Android, iOS,
                          Linux, macOS, Windows, or any combination of these.
          [skeleton]      Formerly generated a list view / detail view Flutter application that followed some community best practices. For up to date resources, see
                          https://flutter.github.io/samples, https://docs.flutter.dev/codelabs, and community resources such as https://flutter-builder.app/.
```
- 
- `flutter create <project-name> -t app` : 创建一个应用
- `flutter create <project-name> -t package` : 创建一个包

## `pub`

```shell
Available subcommands:
  add         Add a dependency to pubspec.yaml.
  cache       Work with the Pub system cache.
  deps        Print package dependencies.
  downgrade   Downgrade packages in a Flutter project.
  get         Get the current package's dependencies.
  global      Work with Pub global packages.
  login       Log into pub.dev.
  logout      Log out of pub.dev.
  outdated    Analyze dependencies to find which ones can be upgraded.
  pub         Pass the remaining arguments to Dart's "pub" tool.
  publish     Publish the current package to pub.dartlang.org.
  remove      Removes a dependency from the current package.
  run         Run an executable from a package.
  test        Run the "test" package.
  token       Manage authentication tokens for hosted pub repositories.
  upgrade     Upgrade the current package's dependencies to latest versions.
  uploader    Manage uploaders for a package on pub.dev.
  version     Print Pub version.
```

- `flutter pub deps > .output/deps.txt` : 打印所有依赖