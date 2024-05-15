import 'dart:convert';
import 'package:flutter/services.dart';

class JsonFileReader {
  // JSON 파일을 읽고, 그 내용을 Map<String, dynamic> 형태로 반환
  Future<Map<String, dynamic>> readJsonFile(String jsonFile) async {
    try {
      // JSON 파일 읽기
      final String jsonString =
          await rootBundle.loadString('lib/json/$jsonFile');
          
      // 읽은 문자열을 JSON으로 변환
      return jsonDecode(jsonString);
    } catch (e) {
      // 오류 메시지를 출력
      print('error: $e');
      return {'error': '데이터를 불러오는 도중 오류가 발생했습니다.'};
    }
  }
}

