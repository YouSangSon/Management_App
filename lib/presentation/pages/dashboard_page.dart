import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:erp/presentation/widgets/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:erp/presentation/pages/hr_management_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isSidebarCollapsed = false;
  String _currentSection = 'Dashboard';
  String _currentSubsection = 'Overview';

  @override
  void initState() {
    super.initState();
    // 로그인 상태 확인
    _checkAuthStatus();
  }

  // 로그인 상태 확인 및 로그아웃 처리
  void _checkAuthStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // 인증되지 않은 사용자는 로그인 페이지로 리디렉션
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/sign');
      });
    } else {
      AppLogger().logInfo('User logged in: ${user.email}');
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _navigateTo(String section, {String? subsection}) {
    setState(() {
      _currentSection = section;
      _currentSubsection = subsection ?? section;
    });

    AppLogger().logInfo('Navigated to: $section > ${subsection ?? "Overview"}');
  }

  void _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/sign');
      }
    } catch (e) {
      AppLogger().logError(e, context: 'Logout error');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          Sidebar(
            isCollapsed: _isSidebarCollapsed,
            onToggle: _toggleSidebar,
            currentSection: _currentSection,
            currentSubsection: _currentSubsection,
            onNavigate: _navigateTo,
            onLogout: _handleLogout,
            isKorean: isKorean,
          ),

          // 메인 콘텐츠 영역
          Expanded(
            child: Column(
              children: [
                // 헤더 영역 (경로 표시 및 검색)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 메뉴 아이콘 (모바일용)
                      MediaQuery.of(context).size.width < 1000
                          ? IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: _toggleSidebar,
                              tooltip: _isSidebarCollapsed
                                  ? (isKorean ? '메뉴 펼치기' : 'Expand Menu')
                                  : (isKorean ? '메뉴 접기' : 'Collapse Menu'),
                            )
                          : const SizedBox.shrink(),

                      Icon(_getIconForSection(_currentSection)),
                      const SizedBox(width: 8),
                      Text(_currentSection),
                      const Icon(Icons.chevron_right),
                      Text(_currentSubsection),
                      const Spacer(),
                      // 검색 및 툴바 아이콘
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // 메인 콘텐츠
                Expanded(
                  child: _currentSection == 'Dashboard'
                      ? _buildDashboardContent(isKorean)
                      : _buildModuleContent(isKorean),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 선택된 섹션에 따라 아이콘 반환
  IconData _getIconForSection(String section) {
    switch (section) {
      case 'Dashboard':
        return Icons.dashboard;
      case 'HR Management':
        return Icons.people;
      case 'Finance':
        return Icons.attach_money;
      case 'Accounting':
        return Icons.account_balance;
      case 'Inventory':
        return Icons.inventory;
      case 'Data Analytics':
        return Icons.analytics;
      case 'Sales Analytics':
        return Icons.bar_chart;
      case 'Reports':
        return Icons.description;
      case 'Settings':
        return Icons.settings;
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Help':
        return Icons.help_outline;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildDashboardContent(bool isKorean) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isKorean ? '대시보드 > 개요' : 'Dashboard > Overview',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKorean
                ? '회사 현황 및 주요 지표를 확인하세요'
                : 'Check company status and key metrics',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // 주요 지표 (KPI) 카드
          Row(
            children: [
              _buildKpiCard(
                title: isKorean ? '직원 수' : 'Employees',
                value: '128',
                change: '+3.2%',
                icon: Icons.people,
                color: Colors.blue,
                isPositive: true,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                title: isKorean ? '월간 매출' : 'Monthly Revenue',
                value: '₩123.4M',
                change: '+5.8%',
                icon: Icons.attach_money,
                color: Colors.green,
                isPositive: true,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                title: isKorean ? '재고 가치' : 'Inventory Value',
                value: '₩89.7M',
                change: '-2.1%',
                icon: Icons.inventory,
                color: Colors.orange,
                isPositive: false,
              ),
            ].expand((widget) => [Expanded(child: widget)]).toList(),
          ),

          const SizedBox(height: 24),

          // 대시보드 콘텐츠 영역
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCard(
                  title: isKorean ? '인사 관리' : 'HR Management',
                  icon: Icons.people,
                  color: Colors.blue,
                  description: isKorean
                      ? '직원 정보, 급여 관리 및 근태 관리'
                      : 'Employee info, payroll and attendance',
                ),
                _buildCard(
                  title: isKorean ? '재무 관리' : 'Finance',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  description: isKorean
                      ? '예산 계획, 자금 관리 및 투자 관리'
                      : 'Budget planning, fund & investment management',
                ),
                _buildCard(
                  title: isKorean ? '회계 관리' : 'Accounting',
                  icon: Icons.account_balance,
                  color: Colors.purple,
                  description: isKorean
                      ? '총계정원장, 매입/매출, 세금 관리'
                      : 'General ledger, AP/AR, tax management',
                ),
                _buildCard(
                  title: isKorean ? '재고/물류' : 'Inventory',
                  icon: Icons.inventory_2,
                  color: Colors.orange,
                  description: isKorean
                      ? '재고 현황, 입출고 관리, 조달 관리'
                      : 'Stock status, movement & procurement',
                ),
                _buildCard(
                  title: isKorean ? '매출 분석' : 'Sales Analytics',
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                  description: isKorean
                      ? '매출 추이, 상품별 분석, 고객 분석'
                      : 'Sales trends, product & customer analysis',
                ),
                _buildCard(
                  title: isKorean ? '보고서' : 'Reports',
                  icon: Icons.description,
                  color: Colors.indigo,
                  description: isKorean
                      ? '재무제표, 손익계산서, 월간 보고서'
                      : 'Financial statements, P&L, monthly reports',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleContent(bool isKorean) {
    // HR Management 모듈인 경우
    if (_currentSection == 'HR Management' || _currentSection == '인사 관리') {
      return HRManagementPage(
        subsection: _currentSubsection,
      );
    }

    // 다른 모듈들(개발 중 메시지 표시)
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_currentSection > $_currentSubsection',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKorean ? '이 모듈은 개발 중입니다' : 'This module is under development',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // 개발 중 메시지
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  isKorean ? '기능 개발 중' : 'Feature Under Development',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isKorean
                      ? '요청하신 $_currentSection > $_currentSubsection 모듈은 현재 개발 중입니다.\n빠른 시일 내에 제공해 드리겠습니다.'
                      : 'The $_currentSection > $_currentSubsection module you requested is currently under development.\nWe will provide it to you soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    String? description,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _navigateTo(title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    radius: 20,
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                    color: Colors.grey,
                    tooltip: '더 보기',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '전월 대비',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
