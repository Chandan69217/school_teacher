class Teacher {

  static int teacherId = 0;
  static int organisationId = 0;
  static String teacherName = '';
  static String teacherGender = '';
  static String teacherEmailId = '';
  static String teacherMobileNumber = '';
  static String teacherJoiningDate = '';
  static String teacherType = '';
  static String teacherDepartment = '';
  static String teacherDesignation = '';
  static String teacherImage = '';

  Teacher({
    required int teacherId,
    required int organisationId,
    required String teacherName,
    required String teacherGender,
    required String teacherEmailId,
    required String teacherMobileNumber,
    required String teacherJoiningDate,
    required String teacherType,
    required String teacherDepartment,
    required String teacherDesignation,
    required String teacherImage,
  }) {

    Teacher.teacherId = teacherId;
    Teacher.organisationId = organisationId;
    Teacher.teacherName = teacherName;
    Teacher.teacherGender = teacherGender;
    Teacher.teacherEmailId = teacherEmailId;
    Teacher.teacherMobileNumber = teacherMobileNumber;
    Teacher.teacherJoiningDate = teacherJoiningDate;
    Teacher.teacherType = teacherType;
    Teacher.teacherDepartment = teacherDepartment;
    Teacher.teacherDesignation = teacherDesignation;
    Teacher.teacherImage = teacherImage;
  }

  static Teacher fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: json['teacherId'] ?? 0,
      organisationId: json['organisationId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      teacherGender: json['teacherGender'] ?? '',
      teacherEmailId: json['teacherEmailId'] ?? '',
      teacherMobileNumber: json['teacherMobileNumber'] ?? '',
      teacherJoiningDate: json['teacherJoiningDate'] ?? '',
      teacherType: json['teacherType'] ?? '',
      teacherDepartment: json['teacherDepartment'] ?? '',
      teacherDesignation: json['teacherDesignation'] ?? '',
      teacherImage: json['teacherImage'] ?? '',
    );
  }

  static Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'organisationId': organisationId,
      'teacherName': teacherName,
      'teacherGender': teacherGender,
      'teacherEmailId': teacherEmailId,
      'teacherMobileNumber': teacherMobileNumber,
      'teacherJoiningDate': teacherJoiningDate,
      'teacherType': teacherType,
      'teacherDepartment': teacherDepartment,
      'teacherDesignation': teacherDesignation,
      'teacherImage': teacherImage,
    };
  }
}
