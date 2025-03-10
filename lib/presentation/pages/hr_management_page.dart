import 'dart:ui';

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
  String _employmentFilter = '전체';
  String? _photoUrl;
  bool _isTableView =
      true; // Changed from false to true to make table view the default
  bool _isDarkMode = false; // Default to light mode
  bool _showPayrollSection =
      false; // Whether to show the dedicated payroll section

  // Dummy data for departments and employment types
  final List<String> _departments = ['전체', '개발팀', '영업팀', '인사팀', '재무팀', '마케팅팀'];
  final List<String> _employmentTypes = ['전체', '정규직', '계약직', '일용직'];

  // Add filter map for table headers
  Map<String, List<String>> _columnFilters = {
    'name': [], // Filtered names
    'department': [], // Filtered departments
    'position': [], // Filtered positions
    'employmentType': [], // Filtered employment types
  };

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
    if (_showPayrollSection) {
      return _buildPayrollSection();
    } else if (widget.subsection == '직원 목록') {
      return _buildEmployeeListTab();
    } else if (widget.subsection == '급여 관리') {
      return _buildPayrollTab();
    } else if (widget.subsection == '인사기록카드') {
      return _buildEmployeeRecordFormTab();
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
          child: Column(
            children: [
              Row(
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

                  // Employment Type filter
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: '고용 형태',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      value: _employmentFilter,
                      items: _employmentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _employmentFilter = value!;
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // Payroll button and theme toggle
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Payroll button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPayrollSection = true;
                        });
                      },
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('급여 관리'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),

                    // Skills view button (for certificates and language skills)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show skills section when implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('자격증 및 어학능력 관리 기능이 곧 추가될 예정입니다.')),
                        );
                      },
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('자격증/어학능력 관리'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),

                    // Theme toggle
                    IconButton(
                      icon: Icon(
                          _isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      tooltip: _isDarkMode ? '라이트 모드로 전환' : '다크 모드로 전환',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Employee list as Excel-like table
        Expanded(
          child: _buildTableView(),
        ),
      ],
    );
  }

  // Add this new method for the payroll section
  Widget _buildPayrollSection() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('급여 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showPayrollSection = false;
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('조회 월: '),
                DropdownButton<String>(
                  value: '2023년 12월',
                  items: ['2023년 12월', '2023년 11월', '2023년 10월']
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),

          // Simple payroll list
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Sample data
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Text('홍'),
                    ),
                    title: Text('홍길동 - EMP00${index + 1}'),
                    subtitle: Text(index % 3 == 0
                        ? '정규직'
                        : index % 3 == 1
                            ? '계약직'
                            : '일용직'),
                    trailing: Text('₩${3000000 + (index * 100000)}'),
                    onTap: () {
                      // Show payroll detail
                      _showPayrollDetail(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Simple payroll detail dialog
  void _showPayrollDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('급여 상세 정보'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('홍길동 (EMP001)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('2023년 12월 급여'),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('기본급'),
                    Text('₩3,000,000'),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('수당'),
                    Text('₩500,000'),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('공제'),
                    Text('₩450,000'),
                  ],
                ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('총지급액', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₩3,050,000',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // Improved table view with comprehensive employee information that looks like Excel
  Widget _buildTableView() {
    // Get filtered employees
    final List<Map<String, dynamic>> filteredEmployees =
        _getFilteredEmployees();

    if (filteredEmployees.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.'),
      );
    }

    // Get unique values for filters
    Set<String> nameSet = {};
    Set<String> departmentSet = {};
    Set<String> positionSet = {};
    Set<String> employmentTypeSet = {};

    for (var employee in filteredEmployees) {
      nameSet.add(employee['name']);
      departmentSet.add(employee['department']);
      positionSet.add(employee['position']);
      employmentTypeSet.add(employee['employmentType']);
    }

    // Excel-like styling
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: _isDarkMode ? Colors.white : Colors.black87,
    );

    final cellStyle = TextStyle(
      fontSize: 12,
      color: _isDarkMode ? Colors.white : Colors.black87,
    );

    final headerBackgroundColor =
        _isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50;
    final gridLineColor =
        _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final alternateRowColor =
        _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;

    // Calculate total width
    final totalWidth = 120.0 +
        100.0 +
        100.0 +
        100.0 +
        100.0 +
        120.0 +
        150.0 +
        120.0 +
        180.0 +
        180.0 +
        180.0 +
        100.0 +
        100.0;

    // Build the Excel-like table with LayoutBuilder
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary count and export button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 ${filteredEmployees.length}명의 직원',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add Excel export functionality here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Excel로 내보내기 기능이 곧 추가될 예정입니다.')),
                    );
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Excel로 내보내기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Main spreadsheet - Wrap in Expanded to prevent overflow
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Header row with horizontal scrolling
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: totalWidth,
                        color: headerBackgroundColor,
                        child: Row(
                          children: [
                            _buildExcelColumnHeader(
                                '이름',
                                nameSet.toList(),
                                'name',
                                Icons.person,
                                120,
                                headerStyle,
                                gridLineColor),
                            _buildFixedExcelHeader(
                                '사번', 100, headerStyle, gridLineColor),
                            _buildExcelColumnHeader(
                                '부서',
                                departmentSet.toList(),
                                'department',
                                Icons.business,
                                100,
                                headerStyle,
                                gridLineColor),
                            _buildExcelColumnHeader(
                                '직위',
                                positionSet.toList(),
                                'position',
                                Icons.work,
                                100,
                                headerStyle,
                                gridLineColor),
                            _buildExcelColumnHeader(
                                '고용형태',
                                employmentTypeSet.toList(),
                                'employmentType',
                                Icons.badge,
                                100,
                                headerStyle,
                                gridLineColor),
                            _buildFixedExcelHeader(
                                '입사일', 120, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '이메일', 150, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '전화번호', 120, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '주소', 180, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '최종학력', 180, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '경력', 180, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '급여(총액)', 100, headerStyle, gridLineColor),
                            _buildFixedExcelHeader(
                                '작업', 100, headerStyle, gridLineColor),
                          ],
                        ),
                      ),
                    ),

                    // Data rows with synchronized scrolling
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: totalWidth,
                          child: ListView.builder(
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              final String highestEducation =
                                  _getHighestEducation(employee);
                              final String careerInfo = employee
                                          .containsKey('career') &&
                                      (employee['career'] as List).isNotEmpty
                                  ? '${(employee['career'] as List).map((career) => '${career['company']} ${career['position']}').join('\n')}'
                                  : '정보 없음';
                              final String payrollTotal = employee
                                      .containsKey('payroll')
                                  ? '₩${NumberFormat('#,###').format(employee['payroll']['totalPayment'])}'
                                  : '₩3,500,000';
                              final String hireDate = DateFormat('yyyy-MM-dd')
                                  .format(employee['hireDate']);
                              final rowColor = index % 2 == 0
                                  ? (_isDarkMode ? Colors.black : Colors.white)
                                  : alternateRowColor;

                              return InkWell(
                                onTap: () {
                                  _showEmployeeDetailDialog(context, employee);
                                },
                                child: Container(
                                  color: rowColor,
                                  child: Row(
                                    children: [
                                      // 이름 cell
                                      _buildExcelCell(
                                        Text(
                                          employee['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        120,
                                        gridLineColor,
                                      ),

                                      // 사번 cell
                                      _buildExcelCell(
                                        Text(
                                          employee['id'],
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        100,
                                        gridLineColor,
                                      ),

                                      // 부서 cell
                                      _buildExcelCell(
                                        Text(
                                          employee['department'],
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        100,
                                        gridLineColor,
                                      ),

                                      // 직위 cell
                                      _buildExcelCell(
                                        Text(
                                          employee['position'],
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        100,
                                        gridLineColor,
                                      ),

                                      // 고용형태 cell
                                      _buildExcelCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getEmploymentTypeColor(
                                                employee['employmentType']),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            employee['employmentType'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  _getEmploymentTypeTextColor(
                                                      employee[
                                                          'employmentType']),
                                            ),
                                          ),
                                        ),
                                        100,
                                        gridLineColor,
                                      ),

                                      // 입사일 cell
                                      _buildExcelCell(
                                        Text(
                                          hireDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        120,
                                        gridLineColor,
                                      ),

                                      // 이메일 cell
                                      _buildExcelCell(
                                        Text(
                                          employee['email'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        150,
                                        gridLineColor,
                                      ),

                                      // 전화번호 cell
                                      _buildExcelCell(
                                        Text(
                                          employee['phone'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        120,
                                        gridLineColor,
                                      ),

                                      // 주소 cell
                                      _buildExcelCell(
                                        Text(
                                          employee.containsKey('address')
                                              ? employee['address'].toString()
                                              : '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        180,
                                        gridLineColor,
                                      ),

                                      // 최종학력 cell
                                      _buildExcelCell(
                                        Text(
                                          highestEducation,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        180,
                                        gridLineColor,
                                      ),

                                      // 경력 cell
                                      _buildExcelCell(
                                        Text(
                                          careerInfo,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        180,
                                        gridLineColor,
                                      ),

                                      // 급여 정보 cell (총액만)
                                      _buildExcelCell(
                                        Text(
                                          payrollTotal,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _isDarkMode
                                                ? Colors.green.shade300
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                        100,
                                        gridLineColor,
                                      ),

                                      // 작업 cell
                                      _buildExcelCell(
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Edit button - make more compact
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  _showEditEmployeeDialog(
                                                      context, employee);
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 16,
                                                    color: _isDarkMode
                                                        ? Colors.blue.shade300
                                                        : Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Delete button - make more compact
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  _showDeleteConfirmDialog(
                                                      context, employee);
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: 16,
                                                    color: _isDarkMode
                                                        ? Colors.red.shade300
                                                        : Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        100,
                                        gridLineColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get highest education
  String _getHighestEducation(Map<String, dynamic> employee) {
    if (!employee.containsKey('education') ||
        (employee['education'] as List).isEmpty) {
      return '정보 없음';
    }

    // Education degrees in order of precedence (highest first)
    final List<String> degreeOrder = ['박사', '석사', '학사', '전문학사', '고졸'];

    // Sort education entries by degree level
    final educationList =
        List<Map<String, dynamic>>.from(employee['education']);

    // Try to find the highest degree
    for (String degree in degreeOrder) {
      for (var edu in educationList) {
        if (edu['degree'].toString().contains(degree)) {
          return '${edu['school']} ${edu['major']} ${edu['degree']}';
        }
      }
    }

    // If no match found, return the first education entry
    final firstEdu = educationList.first;
    return '${firstEdu['school']} ${firstEdu['major']} ${firstEdu['degree']}';
  }

  // Helper method to build Excel-like fixed header cell
  Widget _buildFixedExcelHeader(
      String title, double width, TextStyle style, Color borderColor) {
    return Container(
      width: width,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
      ),
      child: Text(
        title,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to build Excel-like cell with filterable header
  Widget _buildExcelColumnHeader(
    String title,
    List<String> options,
    String filterKey,
    IconData icon,
    double width,
    TextStyle style,
    Color borderColor,
  ) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
      ),
      child: PopupMenuButton<String>(
        tooltip: '$title 필터',
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: style,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.filter_list,
              size: 16,
              color: _columnFilters[filterKey]!.isNotEmpty
                  ? Colors.blue
                  : (_isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        onSelected: (String value) {
          setState(() {
            if (_columnFilters[filterKey]!.contains(value)) {
              _columnFilters[filterKey]!.remove(value);
            } else {
              _columnFilters[filterKey]!.add(value);
            }
          });
        },
        itemBuilder: (BuildContext context) => [
          // Clear filter option
          PopupMenuItem<String>(
            value: 'CLEAR_ALL',
            onTap: () {
              setState(() {
                _columnFilters[filterKey] = [];
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.clear_all,
                  size: 16,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  '필터 지우기',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          const PopupMenuDivider(),
          // Filter options
          ...options.map((String option) {
            final bool isSelected = _columnFilters[filterKey]!.contains(option);
            return PopupMenuItem<String>(
              value: option,
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color: isSelected
                        ? Colors.blue
                        : (_isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Helper method to build Excel-like data cell
  Widget _buildExcelCell(Widget content, double width, Color borderColor) {
    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: content,
      ),
    );
  }

  // Updated to apply column filters
  List<Map<String, dynamic>> _getFilteredEmployees() {
    // Comprehensive employee data with all required information fields
    final List<Map<String, dynamic>> allEmployees = [
      {
        'id': 'EMP001',
        'name': '홍길동',
        'position': '사원',
        'department': '개발팀',
        'employmentType': '정규직',
        'email': 'hong@example.com',
        'phone': '010-1234-5678',
        'hireDate': DateTime(2022, 3, 15),
        'address': '서울시 강남구 테헤란로 123',
        'bankInfo': {'bankName': '국민은행', 'accountNumber': '123-456-789012'},
        'education': [
          {
            'period': '2016.03-2020.02',
            'school': '서울대학교',
            'major': '컴퓨터공학',
            'degree': '학사',
            'gpa': '4.0/4.5'
          },
          {
            'period': '2020.03-2022.02',
            'school': '카이스트',
            'major': '인공지능',
            'degree': '석사',
            'gpa': '4.2/4.5'
          },
        ],
        'career': [
          {
            'company': 'ABC 기술',
            'period': '2022.03-2022.12',
            'position': '연구원',
            'responsibilities': '알고리즘 개발',
            'salary': '3600만원'
          },
        ],
        'certificates': [
          {
            'name': '정보처리기사',
            'level': '1급',
            'date': '2021-05-15',
            'expiry': '2031-05-14',
            'org': '한국산업인력공단',
            'verified': true
          },
          {
            'name': 'SQLD',
            'level': '개발자',
            'date': '2020-11-20',
            'expiry': '2030-11-19',
            'org': '한국데이터베이스진흥원',
            'verified': false
          },
        ],
        'languages': [
          {
            'name': 'TOEIC',
            'score': '950',
            'date': '2021-06-05',
            'expiry': '2023-06-04',
            'org': 'ETS',
            'verified': true
          },
        ],
        'payroll': {
          'basicSalary': 3000000,
          'allowance': 500000,
          'deduction': 450000,
          'totalPayment': 3050000,
        },
      },
      {
        'id': 'EMP002',
        'name': '김철수',
        'position': '대리',
        'department': '영업팀',
        'employmentType': '계약직',
        'email': 'kim@example.com',
        'phone': '010-2345-6789',
        'hireDate': DateTime(2021, 5, 20),
        'address': '경기도 성남시 분당구 판교로 456',
        'bankInfo': {'bankName': '신한은행', 'accountNumber': '987-654-321098'},
        'education': [
          {
            'period': '2014.03-2018.02',
            'school': '고려대학교',
            'major': '경영학',
            'degree': '학사',
            'gpa': '3.8/4.5'
          },
        ],
        'career': [
          {
            'company': 'XYZ 컨설팅',
            'period': '2018.03-2021.04',
            'position': '컨설턴트',
            'responsibilities': '영업 전략 수립',
            'salary': '4200만원'
          },
        ],
        'certificates': [
          {
            'name': '경영지도사',
            'level': '마케팅',
            'date': '2019-07-22',
            'expiry': '2029-07-21',
            'org': '한국산업인력공단',
            'verified': true
          },
        ],
        'languages': [
          {
            'name': 'TOEIC',
            'score': '900',
            'date': '2020-03-15',
            'expiry': '2022-03-14',
            'org': 'ETS',
            'verified': true
          },
          {
            'name': '중국어',
            'score': 'HSK 5급',
            'date': '2019-11-10',
            'expiry': '2022-11-09',
            'org': '중국국가한반',
            'verified': false
          },
        ],
        'payroll': {
          'basicSalary': 3500000,
          'allowance': 600000,
          'deduction': 520000,
          'totalPayment': 3580000,
        },
      },
      {
        'id': 'EMP003',
        'name': '이영희',
        'position': '과장',
        'department': '인사팀',
        'employmentType': '일용직',
        'email': 'lee@example.com',
        'phone': '010-3456-7890',
        'hireDate': DateTime(2019, 11, 10),
        'address': '서울시 서초구 강남대로 789',
        'bankInfo': {'bankName': '우리은행', 'accountNumber': '111-222-333444'},
        'education': [
          {
            'period': '2010.03-2014.02',
            'school': '연세대학교',
            'major': '인사관리',
            'degree': '학사',
            'gpa': '4.2/4.5'
          },
          {
            'period': '2014.03-2016.02',
            'school': '연세대학교',
            'major': 'HR경영',
            'degree': '석사',
            'gpa': '4.3/4.5'
          },
        ],
        'career': [
          {
            'company': 'HR솔루션',
            'period': '2016.03-2019.10',
            'position': '인사담당자',
            'responsibilities': '채용 및 교육',
            'salary': '4800만원'
          },
        ],
        'certificates': [
          {
            'name': '공인노무사',
            'level': '',
            'date': '2018-04-10',
            'expiry': '',
            'org': '고용노동부',
            'verified': true
          },
        ],
        'languages': [
          {
            'name': 'TOEIC',
            'score': '880',
            'date': '2019-01-20',
            'expiry': '2021-01-19',
            'org': 'ETS',
            'verified': false
          },
        ],
        'payroll': {
          'basicSalary': 4500000,
          'allowance': 800000,
          'deduction': 650000,
          'totalPayment': 4650000,
        },
      },
    ];

    // Apply filters
    return allEmployees.where((employee) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          employee['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['id'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply dropdown filters
      final matchesDepartment = _departmentFilter == '전체' ||
          employee['department'] == _departmentFilter;

      final matchesEmployment = _employmentFilter == '전체' ||
          employee['employmentType'] == _employmentFilter;

      // Apply column filters from the Excel-like filter functionality
      final matchesNameFilter = _columnFilters['name']!.isEmpty ||
          _columnFilters['name']!.contains(employee['name']);

      final matchesDepartmentFilter = _columnFilters['department']!.isEmpty ||
          _columnFilters['department']!.contains(employee['department']);

      final matchesPositionFilter = _columnFilters['position']!.isEmpty ||
          _columnFilters['position']!.contains(employee['position']);

      final matchesEmploymentTypeFilter =
          _columnFilters['employmentType']!.isEmpty ||
              _columnFilters['employmentType']!
                  .contains(employee['employmentType']);

      // All conditions must be true for an employee to be included
      return matchesSearch &&
          matchesDepartment &&
          matchesEmployment &&
          matchesNameFilter &&
          matchesDepartmentFilter &&
          matchesPositionFilter &&
          matchesEmploymentTypeFilter;
    }).toList();
  }

  // Helper methods for theme colors
  Color _getEmploymentTypeColor(String employmentType) {
    if (_isDarkMode) {
      switch (employmentType) {
        case '정규직':
          return Colors.green.shade800;
        case '계약직':
          return Colors.orange.shade800;
        case '일용직':
          return Colors.purple.shade800;
        default:
          return Colors.grey.shade800;
      }
    } else {
      switch (employmentType) {
        case '정규직':
          return Colors.green.shade100;
        case '계약직':
          return Colors.orange.shade100;
        case '일용직':
          return Colors.purple.shade100;
        default:
          return Colors.grey.shade100;
      }
    }
  }

  Color _getEmploymentTypeTextColor(String employmentType) {
    if (_isDarkMode) {
      return Colors.white;
    } else {
      switch (employmentType) {
        case '정규직':
          return Colors.green.shade800;
        case '계약직':
          return Colors.orange.shade800;
        case '일용직':
          return Colors.purple.shade800;
        default:
          return Colors.grey.shade800;
      }
    }
  }

  // Add this method to show employee details dialog
  void _showEmployeeDetailDialog(
      BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
          child: Container(
            width: 800,
            height: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header with employee card appearance
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color:
                      _isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Employee photo/avatar
                        CircleAvatar(
                          backgroundColor: _isDarkMode
                              ? Colors.blue.shade800
                              : Colors.blue.shade100,
                          radius: 40,
                          child: Text(
                            employee['name'][0],
                            style: TextStyle(
                              fontSize: 30,
                              color: _isDarkMode
                                  ? Colors.white
                                  : Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Employee basic information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${employee['name']} (${employee['id']})',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildInfoChip(
                                    Icons.business,
                                    employee['department'],
                                    _isDarkMode
                                        ? Colors.blue.shade700
                                        : Colors.blue.shade100,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.work,
                                    employee['position'],
                                    _isDarkMode
                                        ? Colors.purple.shade700
                                        : Colors.purple.shade100,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.badge,
                                    employee['employmentType'],
                                    _getEmploymentTypeColor(
                                        employee['employmentType']),
                                    textColor: _getEmploymentTypeTextColor(
                                        employee['employmentType']),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: _isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '입사일: ${DateFormat('yyyy년 MM월 dd일').format(employee['hireDate'])}',
                                    style: TextStyle(
                                      color: _isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Close button
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact information card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildContactItem(
                          Icons.email,
                          '이메일',
                          employee['email'],
                          _isDarkMode
                              ? Colors.amber.shade700
                              : Colors.amber.shade100,
                        ),
                        _buildContactItem(
                          Icons.phone,
                          '전화번호',
                          employee['phone'],
                          _isDarkMode
                              ? Colors.green.shade700
                              : Colors.green.shade100,
                        ),
                        if (employee.containsKey('address'))
                          _buildContactItem(
                            Icons.location_on,
                            '주소',
                            employee['address'],
                            _isDarkMode
                                ? Colors.red.shade700
                                : Colors.red.shade100,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Employee detail tabs
                Expanded(
                  child: _buildEmployeeDetailTabs(employee),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build info chip
  Widget _buildInfoChip(IconData icon, String label, Color color,
      {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor ?? (_isDarkMode ? Colors.white : Colors.black87),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? (_isDarkMode ? Colors.white : Colors.black87),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build contact items
  Widget _buildContactItem(
      IconData icon, String label, String value, Color iconBgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: iconBgColor,
              child: Icon(
                icon,
                size: 16,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Text(
            value,
            style: TextStyle(
              color: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  // Add this method to your _HRManagementPageState class
  Widget _buildEmployeeRecordFormTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인사기록카드'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '인사기록카드',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Basic employee form with placeholder
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('인사기록 양식이 여기에 표시됩니다.'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 급여 관리 탭
  Widget _buildPayrollTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('급여 관리'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('조회 월: '),
                DropdownButton<String>(
                  value: '2023년 12월',
                  items: ['2023년 12월', '2023년 11월', '2023년 10월']
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (_) {},
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('급여 명세서 생성'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text('급여 관리 화면입니다.'),
            ),
          ),
        ],
      ),
    );
  }

  // 직원 추가 다이얼로그
  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('직원 추가'),
          content: const Text('직원 추가 양식이 여기에 표시됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
          content: const Text('직원 정보 수정 양식이 여기에 표시됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
          content:
              Text('${employee['name']}(${employee['id']}) 직원을 정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 직원 상세 정보 탭
  Widget _buildEmployeeDetailTabs(Map<String, dynamic> employee) {
    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            tabs: [
              Tab(text: '기본 정보'),
              Tab(text: '학력/경력'),
              Tab(text: '자격증'),
              Tab(text: '어학능력'),
              Tab(text: '급여 정보'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                // 기본 정보 탭
                _buildBasicInfoTab(employee),
                // 학력/경력 탭
                Center(child: Text('학력/경력 정보')),
                // 자격증 탭
                Center(child: Text('자격증 정보')),
                // 어학능력 탭
                Center(child: Text('어학능력 정보')),
                // 급여 정보 탭
                Center(child: Text('급여 정보')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 기본 정보 탭
  Widget _buildBasicInfoTab(Map<String, dynamic> employee) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진 영역
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.photo_camera, size: 16),
                      label:
                          const Text('사진 변경', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // 기본 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('성명', employee['name']),
                    _buildInfoRow('사번', employee['id']),
                    _buildInfoRow('부서', employee['department']),
                    _buildInfoRow('직위', employee['position']),
                    _buildInfoRow('고용형태', employee['employmentType']),
                    _buildInfoRow(
                      '입사일',
                      DateFormat('yyyy-MM-dd').format(employee['hireDate']),
                    ),
                    _buildInfoRow('이메일', employee['email']),
                    _buildInfoRow('전화번호', employee['phone']),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
