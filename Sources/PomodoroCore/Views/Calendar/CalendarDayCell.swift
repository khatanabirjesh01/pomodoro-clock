import SwiftUI

public struct CalendarDayCell: View {
    let dayItem: CalendarDayItem
    let isSelected: Bool
    let onTap: () -> Void
    
    public init(dayItem: CalendarDayItem, isSelected: Bool, onTap: @escaping () -> Void) {
        self.dayItem = dayItem
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    private var badgeColor: Color {
        if dayItem.focusCount >= 6 {
            return Color.red
        } else if dayItem.focusCount >= 4 {
            return Color.orange
        } else if dayItem.focusCount >= 1 {
            return Color.green
        } else {
            return Color.clear
        }
    }
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 4) {
                // Day number
                Text("\(dayItem.dayNumber)")
                    .font(.system(size: 13, weight: dayItem.isToday ? .bold : .regular))
                    .foregroundStyle(
                        dayItem.isToday
                            ? Color.red
                            : (dayItem.isCurrentMonth ? Color.primary : Color.secondary.opacity(0.4))
                    )
                
                // Session indicator / badge
                if dayItem.hasSessions {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(badgeColor)
                            .frame(width: 6, height: 6)
                        Text("\(dayItem.focusCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(badgeColor)
                    }
                } else {
                    Spacer().frame(height: 10)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.18)
                            : (dayItem.isToday ? Color.red.opacity(0.06) : Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected
                            ? Color.accentColor
                            : (dayItem.isToday ? Color.red.opacity(0.4) : Color.clear),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
