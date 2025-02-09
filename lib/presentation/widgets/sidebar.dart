import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sidebar extends ConsumerWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final String currentSection;
  final String currentSubsection;
  final Function(String, {String? subsection}) onNavigate;
  final VoidCallback onLogout;
  final bool isKorean;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.currentSection,
    required this.currentSubsection,
    required this.onNavigate,
    required this.onLogout,
    required this.isKorean,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final companyName = isKorean ? '그린테크 주식회사' : 'GreenTech Inc';
    final enterpriseText = isKorean ? 'ERP 시스템' : 'ERP System';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isCollapsed ? 70 : 240,
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // 로고 및 기업명
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.blue.shade800,
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.white),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          enterpriseText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // 접기/펼치기 버튼
                IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: onToggle,
                  tooltip: isCollapsed
                      ? (isKorean ? '메뉴 펼치기' : 'Expand Menu')
                      : (isKorean ? '메뉴 접기' : 'Collapse Menu'),
                ),
              ],
            ),
          ),

          // 메뉴 항목
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // 대시보드
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: isKorean ? '대시보드' : 'Dashboard',
                    isSelected: currentSection == 'Dashboard',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Dashboard'),
                  ),

                  // 주요 모듈 섹션
                  _buildSectionHeader(
                      isKorean ? '주요 모듈' : 'Core Modules', isCollapsed),

                  // 인사관리
                  _buildExpandableMenuItem(
                    icon: Icons.people,
                    title: isKorean ? '인사 관리' : 'HR Management',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'HR Management',
                    onTap: () => onNavigate('HR Management'),
                  ),

                  // 인사 관리 하위 메뉴들 (별도 메뉴 아이템으로 표시)
                  _buildSubMenuItem(
                    icon: Icons.people_outline,
                    title: isKorean ? '직원 목록' : 'Employees',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'HR Management' &&
                        currentSubsection == '직원 목록',
                    onTap: () =>
                        onNavigate('HR Management', subsection: '직원 목록'),
                    indent: true,
                  ),

                  _buildSubMenuItem(
                    icon: Icons.payments_outlined,
                    title: isKorean ? '급여 관리' : 'Payroll',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'HR Management' &&
                        currentSubsection == '급여 관리',
                    onTap: () =>
                        onNavigate('HR Management', subsection: '급여 관리'),
                    indent: true,
                  ),

                  _buildSubMenuItem(
                    icon: Icons.event_available_outlined,
                    title: isKorean ? '근태 관리' : 'Attendance',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'HR Management' &&
                        currentSubsection == '근태 관리',
                    onTap: () =>
                        onNavigate('HR Management', subsection: '근태 관리'),
                    indent: true,
                  ),

                  // 재무관리
                  _buildExpandableMenuItem(
                    icon: Icons.attach_money,
                    title: isKorean ? '재무 관리' : 'Finance',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'Finance',
                    onTap: () => onNavigate('Finance'),
                    submenuItems: [
                      isKorean ? '예산 계획' : 'Budget Planning',
                      isKorean ? '자금 관리' : 'Fund Management',
                      isKorean ? '투자 관리' : 'Investments',
                    ],
                    onSubmenuTap: (submenu) =>
                        onNavigate('Finance', subsection: submenu),
                  ),

                  // 회계관리
                  _buildExpandableMenuItem(
                    icon: Icons.account_balance,
                    title: isKorean ? '회계 관리' : 'Accounting',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'Accounting',
                    onTap: () => onNavigate('Accounting'),
                    submenuItems: [
                      isKorean ? '총계정원장' : 'General Ledger',
                      isKorean ? '매입/매출' : 'AP/AR',
                      isKorean ? '세금 관리' : 'Tax Management',
                    ],
                    onSubmenuTap: (submenu) =>
                        onNavigate('Accounting', subsection: submenu),
                  ),

                  // 재고/물류
                  _buildExpandableMenuItem(
                    icon: Icons.inventory,
                    title: isKorean ? '재고/물류' : 'Inventory/Logistics',
                    isCollapsed: isCollapsed,
                    isSelected: currentSection == 'Inventory',
                    onTap: () => onNavigate('Inventory'),
                    submenuItems: [
                      isKorean ? '재고 현황' : 'Stock Status',
                      isKorean ? '입/출고 관리' : 'Stock Movements',
                      isKorean ? '조달 관리' : 'Procurement',
                    ],
                    onSubmenuTap: (submenu) =>
                        onNavigate('Inventory', subsection: submenu),
                  ),

                  const Divider(color: Colors.grey, height: 32),

                  // 분석 섹션
                  _buildSectionHeader(
                      isKorean ? '분석 및 보고서' : 'Analytics & Reports',
                      isCollapsed),

                  _buildMenuItem(
                    icon: Icons.analytics,
                    title: isKorean ? '데이터 분석' : 'Data Analytics',
                    isSelected: currentSection == 'Data Analytics',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Data Analytics'),
                  ),

                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    title: isKorean ? '매출 분석' : 'Sales Analytics',
                    isSelected: currentSection == 'Sales Analytics',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Sales Analytics'),
                  ),

                  _buildMenuItem(
                    icon: Icons.description,
                    title: isKorean ? '보고서' : 'Reports',
                    isSelected: currentSection == 'Reports',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Reports'),
                  ),

                  const Divider(color: Colors.grey, height: 32),

                  // 설정 섹션
                  _buildSectionHeader(isKorean ? '시스템' : 'System', isCollapsed),

                  _buildMenuItem(
                    icon: Icons.settings,
                    title: isKorean ? '설정' : 'Settings',
                    isSelected: currentSection == 'Settings',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Settings'),
                  ),

                  _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    title: isKorean ? '관리자' : 'Admin',
                    isSelected: currentSection == 'Admin',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Admin'),
                  ),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: isKorean ? '도움말' : 'Help',
                    isSelected: currentSection == 'Help',
                    isCollapsed: isCollapsed,
                    onTap: () => onNavigate('Help'),
                  ),
                ],
              ),
            ),
          ),

          // 사용자 정보
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isCollapsed ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isCollapsed ? 14 : 18,
                  backgroundColor: Colors.blue,
                  child: Text(
                    (user?.email ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email?.split('@')[0] ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.logout, color: Colors.white, size: 18),
                    onPressed: onLogout,
                    tooltip: isKorean ? '로그아웃' : 'Logout',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isCollapsed) {
    if (isCollapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: Colors.grey, height: 1),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isCollapsed,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment:
              isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required bool isCollapsed,
    required bool isSelected,
    required VoidCallback onTap,
    List<String>? submenuItems,
    Function(String)? onSubmenuTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 40,
            color:
                isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16),
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),

        // 서브메뉴 표시
        if (!isCollapsed && isSelected && submenuItems != null)
          ...submenuItems
              .map((submenu) => InkWell(
                    onTap: () => onSubmenuTap?.call(submenu),
                    child: Container(
                      height: 36,
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(left: 52, right: 16),
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          submenu,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required bool isCollapsed,
    required bool isSelected,
    required VoidCallback onTap,
    bool indent = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : (indent ? 32 : 16)),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment:
              isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: indent ? 14 : 15,
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
