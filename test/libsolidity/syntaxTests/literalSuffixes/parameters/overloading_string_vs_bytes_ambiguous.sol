function suffix(string memory) pure suffix returns (uint) {}
function suffix(bytes memory) pure suffix returns (uint) {}

contract C {
    uint a = "abcd" suffix;
}
// ----
// TypeError 8792: (155-161): Overloaded functions cannot be used as literal suffixes.
