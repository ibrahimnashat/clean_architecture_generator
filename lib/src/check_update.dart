import 'dart:io';

class CheckUpdate {
  static String fileContent({
    required String content,
    required String path,
    List<String> methods = const [],
  }) {
    String lastContent = File(path).readAsStringSync();
    String oldContent = cropContent(lastContent);
    final constructor = extractClassImportsCode(content, lastContent);
    content = cropContent(content);

    final diff = StringBuffer();
    for (var method in methods) {
      if (!oldContent.contains(method)) {
        final methodImpl = extractMethodCode(content, method);
        diff.writeln(methodImpl.code);
      }
    }

    final index = lastContent.lastIndexOf("}");
    final indexOfConstructor = lastContent.indexOf(");") + 2;

    lastContent = lastContent.substring(indexOfConstructor, index);
    final result = StringBuffer();
    result.writeln(constructor.code);
    result.writeln(lastContent);
    result.writeln(diff);
    result.writeln("}");

    return result.toString();
  }

  static String cropContent(String content) {
    final firstIndex = content.indexOf("{");
    final lastIndex = content.lastIndexOf("}");
    return content.substring(firstIndex, lastIndex);
  }

  static Method extractMethodCode(String content, String methodName) {
    final buffer = StringBuffer();
    var insideMethod = false;
    var isAbstract = false;
    int count = 0, i = 0;
    final lines = content.split('\n');
    for (var line in lines) {
      if (line.contains(methodName) && line.contains('<')) {
        if (!insideMethod) {
          int range = i < 3 ? i : i - 3;
          for (int from = range; from <= i; from++) {
            final prevLine = lines[from];
            if (prevLine.contains("@") || prevLine.contains("final")) {
              buffer.writeln(prevLine);
            }
          }
        }
        insideMethod = true;
      }
      if (insideMethod) {
        if (line.contains('{')) count += countOfChar('{', line);
        if (line.contains('}')) count -= countOfChar('}', line);

        buffer.writeln(line);

        isAbstract = line.contains(methodName) &&
            line.contains(');') &&
            !line.contains('return') &&
            !line.contains('Services') &&
            !line.contains('DataSource');

        if (count == 0 || isAbstract) {
          insideMethod = false;
          break;
        }
      }
      i++;
    }

    final code = buffer.toString();

    return Method(
      code: code,
      isAbstract: isAbstract,
    );
  }

  static Method extractClassImportsCode(String content, String lastContent) {
    final bufferImports = StringBuffer();
    final oldBufferImports = StringBuffer();
    final lines = content.split('\n');
    final oldLines = lastContent.split('\n');
    for (var line in lines) {
      bufferImports.writeln(line);
      if (line.contains(');')) {
        break;
      }
    }

    for (var line in oldLines) {
      if (line.contains('class')) {
        break;
      } else if (!lines.contains(line.replaceAll('\n', '')) &&
          line.contains('import')) {
        oldBufferImports.writeln(line);
      }
    }

    oldBufferImports.writeln(bufferImports.toString());
    final code = oldBufferImports.toString();

    return Method(
      code: code,
      isAbstract: content.contains('abstract'),
    );
  }

  static int countOfChar(String char, String line) {
    int count = 0;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == char) count++;
    }
    return count;
  }
}

class Method {
  final String code;
  final bool isAbstract;

  Method({
    required this.code,
    required this.isAbstract,
  });
}
