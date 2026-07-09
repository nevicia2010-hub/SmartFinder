public enum SelectionDragPreservationPolicy {
    public static func shouldPreserveSelection(
        clickedItemIsSelected: Bool,
        selectedItemCount: Int,
        usesSelectionModifier: Bool
    ) -> Bool {
        clickedItemIsSelected && selectedItemCount > 1 && !usesSelectionModifier
    }
}
