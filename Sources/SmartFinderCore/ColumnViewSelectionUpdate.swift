public enum ColumnViewSelectionUpdate {
    public static func replaceTrailingColumns<Column>(
        in columns: [Column],
        selectedColumnIndex: Int,
        selectedColumn: Column,
        nextColumn: Column
    ) -> [Column] {
        guard columns.indices.contains(selectedColumnIndex) else {
            return columns
        }
        return Array(columns.prefix(selectedColumnIndex)) + [selectedColumn, nextColumn]
    }
}
