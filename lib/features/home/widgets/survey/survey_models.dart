class SurveyQuestion {
  final String label;
  final List<String> options;

  SurveyQuestion({required this.label, required this.options});
}

/// Model untuk Survey Template (from backend)
class SurveyTemplate {
  final int id;
  final String nama;
  final String? deskripsi;
  final int versi;
  final bool isActive;
  final List<SurveyQuestionModel> questions;

  SurveyTemplate({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.versi,
    required this.isActive,
    required this.questions,
  });

  factory SurveyTemplate.fromJson(Map<String, dynamic> json) {
    return SurveyTemplate(
      id: json['id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String?,
      versi: json['versi'] as int,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => SurveyQuestionModel.fromJson(q))
              .toList() ??
          [],
    );
  }
}

/// Model untuk Survey Question (from backend)
class SurveyQuestionModel {
  final int id;
  final int surveyTemplateId;
  final String? kodeUnsur;
  final String pertanyaan;
  final String tipeJawaban; // 'pilihan_ganda', 'skala', 'text'
  final int urutan;
  final bool isRequired;
  final List<SurveyQuestionOption> options;

  SurveyQuestionModel({
    required this.id,
    required this.surveyTemplateId,
    this.kodeUnsur,
    required this.pertanyaan,
    required this.tipeJawaban,
    required this.urutan,
    required this.isRequired,
    required this.options,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionModel(
      id: json['id'] as int,
      surveyTemplateId: json['survey_template_id'] as int,
      kodeUnsur: json['kode_unsur'] as String?,
      pertanyaan: json['pertanyaan'] as String,
      tipeJawaban: json['tipe_jawaban'] as String,
      urutan: json['urutan'] as int,
      isRequired: json['is_required'] == 1 || json['is_required'] == true,
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => SurveyQuestionOption.fromJson(o))
              .toList() ??
          [],
    );
  }

  /// Check if this question has options (not text input)
  bool get hasOptions => options.isNotEmpty;

  /// Check if this is a text input question
  bool get isTextInput => tipeJawaban == 'text' || !hasOptions;
}

/// Model untuk Survey Question Option (from backend)
class SurveyQuestionOption {
  final int id;
  final int surveyQuestionId;
  final String jawabanText;
  final int? poin;
  final int urutan;

  SurveyQuestionOption({
    required this.id,
    required this.surveyQuestionId,
    required this.jawabanText,
    this.poin,
    required this.urutan,
  });

  factory SurveyQuestionOption.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionOption(
      id: json['id'] as int,
      surveyQuestionId: json['survey_question_id'] as int,
      jawabanText: json['jawaban_text'] as String,
      poin: json['poin'] as int?,
      urutan: json['urutan'] as int,
    );
  }
}

/// Model untuk Survey Response yang akan dikirim ke backend
class SurveyResponse {
  final int questionId;
  final int? optionId;
  final String? textAnswer;
  final int? poin;

  SurveyResponse({
    required this.questionId,
    this.optionId,
    this.textAnswer,
    this.poin,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      if (optionId != null) 'option_id': optionId,
      if (textAnswer != null) 'text_answer': textAnswer,
      if (poin != null) 'poin': poin,
    };
  }
}
