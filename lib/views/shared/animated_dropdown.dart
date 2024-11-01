import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../other/transfer_screen.dart';

class AnimatedCardDropdown extends StatelessWidget {
  final List<CardModel> cards;
  final CardModel? selectedCard;
  final bool isExpanded;
  final Function(CardModel) onCardSelected;
  final VoidCallback onToggle;

  const AnimatedCardDropdown({
    super.key,
    required this.cards,
    required this.selectedCard,
    required this.isExpanded,
    required this.onCardSelected,
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
          // Header
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

          // Dropdown Content
          ClipRRect(
            child: AnimatedCrossFade(
              firstChild: selectedCard != null
                  ? _CardItem(
                      card: selectedCard!,
                      theme: theme,
                      isSelected: true,
                      onTap: onToggle, // Changed to use onToggle when collapsed
                    )
                  : const SizedBox.shrink(),
              secondChild: Column(
                children: cards
                    .map((card) => _CardItem(
                          card: card,
                          theme: theme,
                          isSelected: card == selectedCard,
                          onTap: () => onCardSelected(card),
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

class _CardItem extends StatelessWidget {
  final CardModel card;
  final ThemeData theme;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CardItem({
    required this.card,
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
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
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
            child: Row(
              children: [
                _buildCardIcon(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.cardNumber,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (card.altBalances.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: card.altBalances
                              .map(
                                (balance) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    balance,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  card.balance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        card.icon,
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
