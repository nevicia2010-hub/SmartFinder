public enum OpenWithMenuPolicy {
    public static func canShowOpenWith(selectedItemCount: Int, selectedItemIsDirectory: Bool) -> Bool {
        selectedItemCount == 1 && !selectedItemIsDirectory
    }
}
