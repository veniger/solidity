function iuSuffix(uint8) pure suffix returns (int) {}
function iuSuffix(int8) pure suffix returns (int) {}

contract C {
    int a = 127 iuSuffix;
}
// ----
// TypeError 8792: (137-145): Overloaded functions cannot be used as literal suffixes.
