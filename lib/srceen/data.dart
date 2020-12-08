import 'dart:convert';

import 'package:flutter/foundation.dart';

class Datapond {
  final String title;
  final List<Datapond> quizs;
  Datapond({
    this.title,
    this.quizs,
  });

  Datapond copyWith({
    String title,
    List<Datapond> quizs,
  }) {
    return Datapond(
      title: title ?? this.title,
      quizs: quizs ?? this.quizs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'quizs': quizs?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory Datapond.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Datapond(
      title: map['title'],
      quizs: List<Datapond>.from(map['quizs']?.map((x) => Datapond.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Datapond.fromJson(String source) => Datapond.fromMap(json.decode(source));

  @override
  String toString() => 'Datapond(title: $title, quizs: $quizs)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Datapond &&
      o.title == title &&
      listEquals(o.quizs, quizs);
  }

  @override
  int get hashCode => title.hashCode ^ quizs.hashCode;
}

class DatapondList {
  final String description;
  final bool isAnswer;

  DatapondList({
    this.description,
    this.isAnswer = false,
  });

  DatapondList copyWith({
    String description,
    bool isAnswer,
  }) {
    return DatapondList(
      description: description ?? this.description,
      isAnswer: isAnswer ?? this.isAnswer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'isAnswer': isAnswer,
    };
  }

  factory DatapondList.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return DatapondList(
      description: map['description'],
      isAnswer: map['isAnswer'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DatapondList.fromJson(String source) => DatapondList.fromMap(json.decode(source));

  @override
  String toString() => 'DatapondList(description: $description, isAnswer: $isAnswer)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is DatapondList &&
      o.description == description &&
      o.isAnswer == isAnswer;
  }

  @override
  int get hashCode => description.hashCode ^ isAnswer.hashCode;
}
