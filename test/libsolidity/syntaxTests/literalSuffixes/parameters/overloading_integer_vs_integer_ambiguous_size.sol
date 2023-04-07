function uSuffix(uint8) pure suffix returns (int) {}
function uSuffix(uint16) pure suffix returns (int) {}

contract C {
    int a = 127 uSuffix;
}
// ----
// TypeError 8792: (137-144): Overloaded functions cannot be used as literal suffixes.
