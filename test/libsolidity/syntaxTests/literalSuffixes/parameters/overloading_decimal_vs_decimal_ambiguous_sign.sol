function iuSuffix(uint8, uint) pure suffix returns (uint) {}
function iuSuffix(int8, uint) pure suffix returns (uint) {}

contract C {
    uint a = 1.27 iuSuffix;
}
// ----
// TypeError 8792: (153-161): Overloaded functions cannot be used as literal suffixes.
