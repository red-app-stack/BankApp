import 'package:bank_app/views/shared/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/accounts_controller.dart';

class AnimatedCardDropdown extends StatelessWidget {
  final List<AccountModel> accounts;
  final AccountModel? selectedAccount;
  final bool isExpanded;
  final Function(AccountModel) onAccountSelected;
  final VoidCallback onToggle;

  const AnimatedCardDropdown({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.isExpanded,
    required this.onAccountSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            splashFactory: InkRipple.splashFactory,
            splashColor: theme.colorScheme.primary.withOpacity(0.08),
            highlightColor: theme.colorScheme.primary.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Откуда',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            child: AnimatedCrossFade(
              firstChild: selectedAccount != null
                  ? _AccountItem(
                      account: selectedAccount!,
                      theme: theme,
                      isSelected: true,
                      onTap: onToggle,
                    )
                  : const SizedBox.shrink(),
              secondChild: Column(
                children: accounts
                    .map((account) => _AccountItem(
                          account: account,
                          theme: theme,
                          isSelected: account == selectedAccount,
                          onTap: () => onAccountSelected(account),
                        ))
                    .toList(),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final AccountModel account;
  final ThemeData theme;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AccountItem({
    required this.account,
    required this.theme,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                splashColor: theme.colorScheme.primary.withOpacity(0.08),
                highlightColor: theme.colorScheme.primary.withOpacity(0.04),
                child: Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 16,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Row(children: [
                      _buildCardIcon(theme),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatAccountType(account.accountType),
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            censorCardNumber(account.accountNumber),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )),
                      Text(
                        formatCurrency(
                            account.balance, account.currency, 'ru_RU'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ])))));
  }

  Widget _buildCardIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/icons/creditcard.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
