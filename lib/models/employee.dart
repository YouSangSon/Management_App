import 'package:uuid/uuid.dart';

enum EmploymentType { regular, contract, dailyWorker }

enum EmployeeStatus { active, inactive, on_leave }

enum EducationDegree { phd, masters, bachelors, associates, highSchool, other }

// 직원 모델
class Employee {
  final String id;
  final String employeeId;
  final String name;
  final String department;
  final String position;
  final EmploymentType employmentType;
  final String email;
  final String phone;
  final DateTime hireDate;
  final DateTime? resignationDate;
  final String? address;
  final String? photoUrl;
  final EmployeeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    String? id,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.position,
    required this.employmentType,
    required this.email,
    required this.phone,
    required this.hireDate,
    this.resignationDate,
    this.address,
    this.photoUrl,
    this.status = EmployeeStatus.active,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // 고용형태 한글 변환 헬퍼 메서드
  static String getEmploymentTypeKorean(EmploymentType type) {
    switch (type) {
      case EmploymentType.regular:
        return '정규직';
      case EmploymentType.contract:
        return '계약직';
      case EmploymentType.dailyWorker:
        return '일용직';
    }
  }

  // 고용형태 한글에서 영문으로 변환
  static EmploymentType getEmploymentTypeFromKorean(String koreanType) {
    switch (koreanType) {
      case '정규직':
        return EmploymentType.regular;
      case '계약직':
        return EmploymentType.contract;
      case '일용직':
        return EmploymentType.dailyWorker;
      default:
        return EmploymentType.regular;
    }
  }

  // 학위 한글 변환 헬퍼 메서드
  static String getDegreeKorean(EducationDegree degree) {
    switch (degree) {
      case EducationDegree.phd:
        return '박사';
      case EducationDegree.masters:
        return '석사';
      case EducationDegree.bachelors:
        return '학사';
      case EducationDegree.associates:
        return '전문학사';
      case EducationDegree.highSchool:
        return '고졸';
      case EducationDegree.other:
        return '기타';
    }
  }

  // 학위 한글에서 영문으로 변환
  static EducationDegree getDegreeFromKorean(String koreanDegree) {
    switch (koreanDegree) {
      case '박사':
        return EducationDegree.phd;
      case '석사':
        return EducationDegree.masters;
      case '학사':
        return EducationDegree.bachelors;
      case '전문학사':
        return EducationDegree.associates;
      case '고졸':
        return EducationDegree.highSchool;
      default:
        return EducationDegree.other;
    }
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeId: json['employee_id'],
      name: json['name'],
      department: json['department'],
      position: json['position'],
      employmentType: getEmploymentTypeFromKorean(json['employment_type']),
      email: json['email'],
      phone: json['phone'],
      hireDate: DateTime.parse(json['hire_date']),
      resignationDate: json['resignation_date'] != null
          ? DateTime.parse(json['resignation_date'])
          : null,
      address: json['address'],
      photoUrl: json['photo_url'],
      status: EmployeeStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => EmployeeStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'department': department,
      'position': position,
      'employment_type': getEmploymentTypeKorean(employmentType),
      'email': email,
      'phone': phone,
      'hire_date': hireDate.toIso8601String(),
      'resignation_date': resignationDate?.toIso8601String(),
      'address': address,
      'photo_url': photoUrl,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Employee copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? department,
    String? position,
    EmploymentType? employmentType,
    String? email,
    String? phone,
    DateTime? hireDate,
    DateTime? resignationDate,
    String? address,
    String? photoUrl,
    EmployeeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      department: department ?? this.department,
      position: position ?? this.position,
      employmentType: employmentType ?? this.employmentType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hireDate: hireDate ?? this.hireDate,
      resignationDate: resignationDate ?? this.resignationDate,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 학력 모델
class Education {
  final String id;
  final String employeeId;
  final String school;
  final String major;
  final EducationDegree degree;
  final DateTime startDate;
  final DateTime? endDate;
  final String? gpa;
  final bool isHighest;
  final DateTime createdAt;
  final DateTime updatedAt;

  Education({
    String? id,
    required this.employeeId,
    required this.school,
    required this.major,
    required this.degree,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.isHighest = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      employeeId: json['employee_id'],
      school: json['school'],
      major: json['major'],
      degree: Employee.getDegreeFromKorean(json['degree']),
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      gpa: json['gpa'],
      isHighest: json['is_highest'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'school': school,
      'major': major,
      'degree': Employee.getDegreeKorean(degree),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'gpa': gpa,
      'is_highest': isHighest,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 경력 모델
class Career {
  final String id;
  final String employeeId;
  final String company;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final String? responsibilities;
  final int? salary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Career({
    String? id,
    required this.employeeId,
    required this.company,
    required this.position,
    required this.startDate,
    this.endDate,
    this.responsibilities,
    this.salary,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'],
      employeeId: json['employee_id'],
      company: json['company'],
      position: json['position'],
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      responsibilities: json['responsibilities'],
      salary: json['salary'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'company': company,
      'position': position,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'responsibilities': responsibilities,
      'salary': salary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 자격증 모델
class Certificate {
  final String id;
  final String employeeId;
  final String name;
  final String? level;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String organization;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Certificate({
    String? id,
    required this.employeeId,
    required this.name,
    this.level,
    required this.issueDate,
    this.expiryDate,
    required this.organization,
    this.verified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      employeeId: json['employee_id'],
      name: json['name'],
      level: json['level'],
      issueDate: DateTime.parse(json['issue_date']),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      organization: json['organization'],
      verified: json['verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'level': level,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'organization': organization,
      'verified': verified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 어학능력 모델
class LanguageSkill {
  final String id;
  final String employeeId;
  final String testName;
  final String score;
  final DateTime testDate;
  final DateTime? expiryDate;
  final String organization;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  LanguageSkill({
    String? id,
    required this.employeeId,
    required this.testName,
    required this.score,
    required this.testDate,
    this.expiryDate,
    required this.organization,
    this.verified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory LanguageSkill.fromJson(Map<String, dynamic> json) {
    return LanguageSkill(
      id: json['id'],
      employeeId: json['employee_id'],
      testName: json['test_name'],
      score: json['score'],
      testDate: DateTime.parse(json['test_date']),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      organization: json['organization'],
      verified: json['verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'test_name': testName,
      'score': score,
      'test_date': testDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'organization': organization,
      'verified': verified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 급여 모델
class Payroll {
  final String id;
  final String employeeId;
  final DateTime paymentDate;
  final int paymentYear;
  final int paymentMonth;
  final int basicSalary;
  final int allowance;
  final int deduction;
  final int totalPayment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payroll({
    String? id,
    required this.employeeId,
    required this.paymentDate,
    required this.paymentYear,
    required this.paymentMonth,
    required this.basicSalary,
    this.allowance = 0,
    this.deduction = 0,
    int? totalPayment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        totalPayment = totalPayment ?? (basicSalary + allowance - deduction),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'],
      employeeId: json['employee_id'],
      paymentDate: DateTime.parse(json['payment_date']),
      paymentYear: json['payment_year'],
      paymentMonth: json['payment_month'],
      basicSalary: json['basic_salary'],
      allowance: json['allowance'] ?? 0,
      deduction: json['deduction'] ?? 0,
      totalPayment: json['total_payment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'payment_date': paymentDate.toIso8601String(),
      'payment_year': paymentYear,
      'payment_month': paymentMonth,
      'basic_salary': basicSalary,
      'allowance': allowance,
      'deduction': deduction,
      // totalPayment은 데이터베이스에서 자동 계산되므로 포함하지 않음
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 은행 계좌 모델
class BankAccount {
  final String id;
  final String employeeId;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    String? id,
    required this.employeeId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.isPrimary = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      employeeId: json['employee_id'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      accountHolder: json['account_holder'],
      isPrimary: json['is_primary'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder': accountHolder,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 부서 모델
class Department {
  final String id;
  final String name;
  final String? managerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    String? id,
    required this.name,
    this.managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      managerId: json['manager_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manager_id': managerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 직원 통합 정보 모델 (화면 표시용)
class EmployeeDetail {
  final Employee employee;
  final List<Education> educations;
  final List<Career> careers;
  final List<Certificate> certificates;
  final List<LanguageSkill> languageSkills;
  final List<Payroll> payrolls;
  final List<BankAccount> bankAccounts;
  final Department? department;

  EmployeeDetail({
    required this.employee,
    this.educations = const [],
    this.careers = const [],
    this.certificates = const [],
    this.languageSkills = const [],
    this.payrolls = const [],
    this.bankAccounts = const [],
    this.department,
  });

  Education? get highestEducation {
    if (educations.isEmpty) return null;
    try {
      return educations.firstWhere((edu) => edu.isHighest);
    } catch (_) {
      return educations.first;
    }
  }

  BankAccount? get primaryBankAccount {
    if (bankAccounts.isEmpty) return null;
    try {
      return bankAccounts.firstWhere((acc) => acc.isPrimary);
    } catch (_) {
      return bankAccounts.first;
    }
  }

  Payroll? get latestPayroll {
    if (payrolls.isEmpty) return null;
    return payrolls.reduce((curr, next) =>
        curr.paymentYear > next.paymentYear ||
                (curr.paymentYear == next.paymentYear &&
                    curr.paymentMonth > next.paymentMonth)
            ? curr
            : next);
  }
}
