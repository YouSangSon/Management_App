import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:intl/intl.dart';

class HRManagementPage extends ConsumerStatefulWidget {
  final String subsection;

  const HRManagementPage({
    Key? key,
    this.subsection = '직원 목록',
  }) : super(key: key);

  @override
  ConsumerState<HRManagementPage> createState() => _HRManagementPageState();
}

class _HRManagementPageState extends ConsumerState<HRManagementPage> {
  String _searchQuery = '';
  String _departmentFilter = '전체';

  // Dummy data for departments
  final List<String> _departments = ['전체', '개발팀', '영업팀', '인사팀', '재무팀', '마케팅팀'];

  @override
  void initState() {
    super.initState();
    AppLogger().logInfo(
        'HR Management Page initialized with subsection: ${widget.subsection}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 subsection에 따라 적절한 화면 표시
    if (widget.subsection == '직원 목록') {
      return _buildEmployeeListTab();
    } else if (widget.subsection == '급여 관리') {
      return _buildPayrollTab();
    } else if (widget.subsection == '근태 관리') {
      return _buildAttendanceTab();
    } else {
      // 기본값으로 직원 목록 표시
      return _buildEmployeeListTab();
    }
  }

  // 직원 목록 탭
  Widget _buildEmployeeListTab() {
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Search field
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '이름 또는 사번으로 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Department filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: '부서',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _departmentFilter,
                  items: _departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _departmentFilter = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Add employee button
              ElevatedButton.icon(
                onPressed: () {
                  // Show add employee dialog
                  _showAddEmployeeDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('직원 추가'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Employee list
        Expanded(
          child: _buildEmployeeList(),
        ),
      ],
    );
  }

  // 직원 목록 위젯
  Widget _buildEmployeeList() {
    // Dummy employee data
    final List<Map<String, dynamic>> allEmployees = [
      {
        'id': 'EMP001',
        'name': '홍길동',
        'position': '사원',
        'department': '개발팀',
        'email': 'hong@example.com',
        'phone': '010-1234-5678',
        'hireDate': DateTime(2022, 3, 15),
      },
      {
        'id': 'EMP002',
        'name': '김철수',
        'position': '대리',
        'department': '영업팀',
        'email': 'kim@example.com',
        'phone': '010-2345-6789',
        'hireDate': DateTime(2021, 5, 20),
      },
      {
        'id': 'EMP003',
        'name': '이영희',
        'position': '과장',
        'department': '인사팀',
        'email': 'lee@example.com',
        'phone': '010-3456-7890',
        'hireDate': DateTime(2019, 11, 10),
      },
      {
        'id': 'EMP004',
        'name': '박민준',
        'position': '차장',
        'department': '재무팀',
        'email': 'park@example.com',
        'phone': '010-4567-8901',
        'hireDate': DateTime(2018, 7, 5),
      },
      {
        'id': 'EMP005',
        'name': '최지은',
        'position': '사원',
        'department': '마케팅팀',
        'email': 'choi@example.com',
        'phone': '010-5678-9012',
        'hireDate': DateTime(2022, 1, 17),
      },
      {
        'id': 'EMP006',
        'name': '정수민',
        'position': '사원',
        'department': '개발팀',
        'email': 'jung@example.com',
        'phone': '010-6789-0123',
        'hireDate': DateTime(2022, 8, 22),
      },
      {
        'id': 'EMP007',
        'name': '강현우',
        'position': '대리',
        'department': '인사팀',
        'email': 'kang@example.com',
        'phone': '010-7890-1234',
        'hireDate': DateTime(2020, 4, 1),
      },
      {
        'id': 'EMP008',
        'name': '윤서연',
        'position': '과장',
        'department': '영업팀',
        'email': 'yoon@example.com',
        'phone': '010-8901-2345',
        'hireDate': DateTime(2019, 2, 14),
      },
    ];

    // Apply filters
    final List<Map<String, dynamic>> filteredEmployees =
        allEmployees.where((employee) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          employee['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['id'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply department filter
      final matchesDepartment = _departmentFilter == '전체' ||
          employee['department'] == _departmentFilter;

      return matchesSearch && matchesDepartment;
    }).toList();

    if (filteredEmployees.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.'),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columnSpacing: 20,
          dataRowHeight: 60,
          columns: const [
            DataColumn(label: Text('사번')),
            DataColumn(label: Text('이름')),
            DataColumn(label: Text('직급')),
            DataColumn(label: Text('부서')),
            DataColumn(label: Text('이메일')),
            DataColumn(label: Text('입사일')),
            DataColumn(label: Text('관리')),
          ],
          rows: filteredEmployees.map((employee) {
            return DataRow(
              cells: [
                DataCell(Text(employee['id'])),
                DataCell(Text(employee['name'])),
                DataCell(Text(employee['position'])),
                DataCell(Text(employee['department'])),
                DataCell(Text(employee['email'])),
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(employee['hireDate']))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Edit employee action
                          _showEditEmployeeDialog(context, employee);
                        },
                        tooltip: '수정',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Delete employee action
                          _showDeleteConfirmDialog(context, employee);
                        },
                        tooltip: '삭제',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 급여 관리 탭
  Widget _buildPayrollTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 선택 헤더
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                '급여 관리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: '2023년 12월',
                items: [
                  '2023년 12월',
                  '2023년 11월',
                  '2023년 10월',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('급여 명세서 생성'),
              ),
            ],
          ),
        ),

        // 급여 통계 카드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildPayrollStatCard('전체 지급액', '₩98,560,000', Colors.blue),
              const SizedBox(width: 16),
              _buildPayrollStatCard('평균 급여', '₩4,115,000', Colors.green),
              const SizedBox(width: 16),
              _buildPayrollStatCard('세금 합계', '₩12,348,000', Colors.orange),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 급여 명세서 목록
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('사번')),
                  DataColumn(label: Text('이름')),
                  DataColumn(label: Text('부서')),
                  DataColumn(label: Text('기본급')),
                  DataColumn(label: Text('수당')),
                  DataColumn(label: Text('공제액')),
                  DataColumn(label: Text('차인지급액')),
                  DataColumn(label: Text('상태')),
                  DataColumn(label: Text('관리')),
                ],
                rows: [
                  _buildPayrollRow('EMP001', '홍길동', '개발팀', '3,500,000',
                      '500,000', '400,000', '3,600,000', '지급완료'),
                  _buildPayrollRow('EMP002', '김철수', '영업팀', '4,000,000',
                      '800,000', '480,000', '4,320,000', '지급완료'),
                  _buildPayrollRow('EMP003', '이영희', '인사팀', '4,500,000',
                      '600,000', '510,000', '4,590,000', '지급완료'),
                  _buildPayrollRow('EMP004', '박민준', '재무팀', '5,000,000',
                      '1,000,000', '600,000', '5,400,000', '지급완료'),
                  _buildPayrollRow('EMP005', '최지은', '마케팅팀', '3,500,000',
                      '400,000', '390,000', '3,510,000', '지급완료'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 급여 통계 카드 위젯
  Widget _buildPayrollStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 급여 행 생성 함수
  DataRow _buildPayrollRow(String id, String name, String dept, String basePay,
      String allowance, String deduction, String netPay, String status) {
    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(dept)),
        DataCell(Text('₩$basePay')),
        DataCell(Text('₩$allowance')),
        DataCell(Text('₩$deduction')),
        DataCell(Text('₩$netPay',
            style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: Colors.green[800]),
          ),
        )),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {},
                tooltip: '상세보기',
              ),
              IconButton(
                icon: const Icon(Icons.print, color: Colors.grey),
                onPressed: () {},
                tooltip: '인쇄',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 근태 관리 탭
  Widget _buildAttendanceTab() {
    final currentDate = DateTime.now();
    final formatter = DateFormat('yyyy년 MM월');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 선택 헤더
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                '근태 관리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                formatter.format(currentDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {},
                tooltip: '달력 보기',
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('근태 기록 추가'),
              ),
            ],
          ),
        ),

        // 근태 통계 카드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildAttendanceStatCard('정상 출근', '128', Colors.green),
              const SizedBox(width: 16),
              _buildAttendanceStatCard('지각', '3', Colors.orange),
              const SizedBox(width: 16),
              _buildAttendanceStatCard('결근', '1', Colors.red),
              const SizedBox(width: 16),
              _buildAttendanceStatCard('휴가', '5', Colors.blue),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 근태 기록 목록
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('날짜')),
                  DataColumn(label: Text('사번')),
                  DataColumn(label: Text('이름')),
                  DataColumn(label: Text('출근 시간')),
                  DataColumn(label: Text('퇴근 시간')),
                  DataColumn(label: Text('근무 시간')),
                  DataColumn(label: Text('상태')),
                  DataColumn(label: Text('비고')),
                ],
                rows: [
                  _buildAttendanceRow('2023-12-01', 'EMP001', '홍길동', '09:00',
                      '18:05', '8시간 5분', '정상', ''),
                  _buildAttendanceRow('2023-12-01', 'EMP002', '김철수', '08:55',
                      '18:00', '8시간 5분', '정상', ''),
                  _buildAttendanceRow('2023-12-01', 'EMP003', '이영희', '09:12',
                      '18:30', '8시간 18분', '지각', '교통체증'),
                  _buildAttendanceRow('2023-12-01', 'EMP004', '박민준', '09:00',
                      '19:45', '10시간 45분', '정상', '연장근무'),
                  _buildAttendanceRow('2023-12-01', 'EMP005', '최지은', '-', '-',
                      '-', '휴가', '연차휴가'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 근태 통계 카드 위젯
  Widget _buildAttendanceStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '명',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 근태 행 생성 함수
  DataRow _buildAttendanceRow(
      String date,
      String id,
      String name,
      String checkIn,
      String checkOut,
      String workHours,
      String status,
      String note) {
    Color statusColor;
    switch (status) {
      case '정상':
        statusColor = Colors.green;
        break;
      case '지각':
        statusColor = Colors.orange;
        break;
      case '결근':
        statusColor = Colors.red;
        break;
      case '휴가':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(checkIn)),
        DataCell(Text(checkOut)),
        DataCell(Text(workHours)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor),
          ),
        )),
        DataCell(Text(note)),
      ],
    );
  }

  // 직원 추가 다이얼로그
  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('직원 추가'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '사번',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '부서',
                      border: OutlineInputBorder(),
                    ),
                    value: _departments[1], // 첫 번째 실제 부서 (전체 제외)
                    items: _departments.sublist(1).map((department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '직급',
                      border: OutlineInputBorder(),
                    ),
                    value: '사원',
                    items: ['사원', '대리', '과장', '차장', '부장'].map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InputDatePickerFormField(
                    fieldLabelText: '입사일',
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save new employee
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('직원이 추가되었습니다.')),
                );
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 직원 수정 다이얼로그
  void _showEditEmployeeDialog(
      BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${employee['name']} 정보 수정'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: employee['name'],
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: employee['id'],
                    decoration: const InputDecoration(
                      labelText: '사번',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false, // 사번은 수정 불가
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '부서',
                      border: OutlineInputBorder(),
                    ),
                    value: employee['department'],
                    items: _departments.sublist(1).map((department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '직급',
                      border: OutlineInputBorder(),
                    ),
                    value: employee['position'],
                    items: ['사원', '대리', '과장', '차장', '부장'].map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: employee['email'],
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: employee['phone'],
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save employee changes
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('직원 정보가 수정되었습니다.')),
                );
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 직원 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(
      BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('직원 삭제'),
          content: Text(
              '${employee['name']}(${employee['id']}) 직원을 정말 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // Delete employee
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('직원이 삭제되었습니다.')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
