contract C {
    uint a = 1000 suffix;

    function suffix(uint) public pure returns (uint) {}
    function suffix(address) public pure returns (uint) {}
}
// ----
// TypeError 8792: (31-37): Overloaded functions cannot be used as literal suffixes.
