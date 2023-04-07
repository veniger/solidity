function uSuffix(uint8, uint) pure suffix returns (uint) {}
function uSuffix(uint16, uint) pure suffix returns (uint) {}

contract C {
    uint a = 1.27 uSuffix;
}
// ----
// TypeError 8792: (153-160): Overloaded functions cannot be used as literal suffixes.
