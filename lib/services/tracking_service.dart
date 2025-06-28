import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:webview_flutter/webview_flutter.dart';

import '../models/tracking_result.dart';

class EvropochtaTrackingService {
  static const String _baseUrl = "https://evropochta.by/?number=";
  static const String _tableSelector = ".tracking-table";
  static const String _errorSelector = ".tracking-error";
  static const String _combinedSelector = "$_tableSelector, $_errorSelector";

  late final WebViewController controller;

  // Completer будет создаваться заново для каждого запроса
  Completer<TrackingResult>? _completer;

  // ИСПРАВЛЕНИЕ: Вся настройка контроллера происходит здесь, ОДИН РАЗ.
  EvropochtaTrackingService() {
    controller = WebViewController();

    const String jsToExecute = """
      const selector = '$_combinedSelector';
      const maxTries = 150; 
      let tries = 0;
      const interval = setInterval(() => {
        const element = document.querySelector(selector);
        if (element) {
          clearInterval(interval);
          const result = {
            type: element.className.includes('tracking-table') ? 'table' : 'error',
            html: element.innerHTML
          };
          FlutterBridge.postMessage(JSON.stringify(result));
        } else if (++tries > maxTries) {
          clearInterval(interval);
          const captcha = document.querySelector('#captcha');
          const errorMsg = captcha ? 'Обнаружена капча' : 'Элемент не найден после ' + maxTries + ' попыток';
          FlutterBridge.postMessage(JSON.stringify({type: 'error', html: errorMsg}));
        }
      }, 100);
    """;

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          if (_completer == null || _completer!.isCompleted) return;
          
          debugPrint("--- [DEBUG] Получено сообщение от JS: ${message.message} ---");

          try {
            final jsonResult = jsonDecode(message.message) as Map<String, dynamic>;
            final type = jsonResult['type'] as String;
            final html = jsonResult['html'] as String;

            if (type == 'table') {
              final events = _parseTrackingTable(html);
              _completer!.complete(TrackingSuccess(events));
            } else {
              final doc = html_parser.parse(html);
              final errorText = doc.body?.text.trim() ?? 'Неизвестная ошибка из JS';
              _completer!.complete(TrackingFailure(errorText));
            }
          } catch (e) {
            _completer!.complete(TrackingFailure("Ошибка парсинга ответа от WebView: $e"));
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint("[DEBUG] Загрузка страницы началась: $url");
          },
          onPageFinished: (String url) {
            debugPrint("[DEBUG] Загрузка страницы ЗАВЕРШЕНА. Внедряем JS.");
            controller.runJavaScript(jsToExecute);
          },
          onWebResourceError: (WebResourceError error) {
            if (_completer == null || _completer!.isCompleted) return;
            debugPrint("--- [DEBUG] КРИТИЧЕСКАЯ ОШИБКА WebResourceError ---");
            debugPrint("Код ошибки: ${error.errorCode}");
            debugPrint("Описание: ${error.description}");
            debugPrint("URL: ${error.url}");
            debugPrint("------------------------------------------");
            _completer!.complete(TrackingFailure(
              "Ошибка загрузки ресурса: ${error.description} (код: ${error.errorCode})"
            ));
          },
        ),
      );
  }

  // ИСПРАВЛЕНИЕ: Этот метод теперь только загружает URL и ждет ответа
  Future<TrackingResult> getTrackingData(String trackNumber,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final url = '$_baseUrl$trackNumber';
    _completer = Completer<TrackingResult>();

    debugPrint("--- [DEBUG] Начинаем отслеживание. URL: $url ---");
    
    try {
      await controller.loadRequest(Uri.parse(url));
      return await _completer!.future.timeout(timeout);
    } on TimeoutException {
      debugPrint("[DEBUG] КРИТИЧЕСКАЯ ОШИБКА: Превышен общий таймаут операции.");
      return TrackingFailure("Превышено время ожидания ответа от сайта.");
    } catch (e) {
      debugPrint("[DEBUG] КРИТИЧЕСКАЯ ОШИБКА в блоке try-catch: $e");
      return TrackingFailure("Непредвиденная ошибка: ${e.toString()}");
    }
  }

  List<TrackingEvent> _parseTrackingTable(String html) {
    final document = html_parser.parse(html);
    final items = document.querySelectorAll('.tracking-table-item');
    final List<TrackingEvent> events = [];

    for (dom.Element item in items) {
      final date = item.querySelector('.date')?.text.trim() ?? '';
      final time = item.querySelector('.time')?.text.trim() ?? '';
      final comment = item.querySelector('.comment')?.text.trim() ?? '';
      events.add(TrackingEvent(date: date, time: time, comment: comment));
    }
    return events;
  }
}