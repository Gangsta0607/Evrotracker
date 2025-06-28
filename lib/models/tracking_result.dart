// Модель для одного события в истории отслеживания
class TrackingEvent {
  final String date;
  final String time;
  final String comment;

  TrackingEvent({
    required this.date,
    required this.time,
    required this.comment,
  });

  // Фабричный конструктор для создания экземпляра из JSON
  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
    );
  }

  // Метод для преобразования экземпляра в JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'comment': comment,
    };
  }
}

// Абстрактный "запечатанный" класс для результата отслеживания.
// Он позволяет обрабатывать состояния успеха и ошибки типизированным способом.
abstract class TrackingResult {
  // ИСПРАВЛЕНИЕ: Добавлен пустой конструктор.
  // Это необходимо, так как мы определили другой фабричный конструктор,
  // что отменяет конструктор по умолчанию. Дочерние классы теперь могут
  // неявно вызывать этот конструктор.
  TrackingResult();

  // Абстрактный метод, который обязывает все дочерние классы
  // уметь преобразовываться в JSON.
  Map<String, dynamic> toJson();

  // Фабричный конструктор, который решает, какой конкретный тип результата
  // создать на основе поля 'type' в JSON.
  factory TrackingResult.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'success') {
      return TrackingSuccess.fromJson(json);
    }
    // По умолчанию считаем, что это ошибка
    return TrackingFailure.fromJson(json);
  }
}

// Класс для успешного результата отслеживания
class TrackingSuccess extends TrackingResult {
  final List<TrackingEvent> events;

  TrackingSuccess(this.events);

  // Фабричный конструктор для создания экземпляра из JSON
  factory TrackingSuccess.fromJson(Map<String, dynamic> json) {
    // Безопасно парсим список событий
    var eventsList = json['events'] as List? ?? [];
    List<TrackingEvent> events =
        eventsList.map((i) => TrackingEvent.fromJson(i)).toList();
    return TrackingSuccess(events);
  }

  // Метод для преобразования экземпляра в JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'success',
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}

// Класс для результата с ошибкой
class TrackingFailure extends TrackingResult {
  final String message;

  TrackingFailure(this.message);

  // Фабричный конструктор для создания экземпляра из JSON
  factory TrackingFailure.fromJson(Map<String, dynamic> json) {
    return TrackingFailure(json['message'] as String? ?? 'Неизвестная ошибка');
  }

  // Метод для преобразования экземпляра в JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'failure',
      'message': message,
    };
  }
}