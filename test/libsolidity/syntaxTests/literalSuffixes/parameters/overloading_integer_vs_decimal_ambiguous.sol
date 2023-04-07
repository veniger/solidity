function suffix(uint) pure suffix returns (int) {}
function suffix(uint, uint) pure suffix returns (int) {}

contract C {
    function f() public pure {
        int a = 1 suffix;
    }
}
// ----
// TypeError 8792: (171-177): Overloaded functions cannot be used as literal suffixes.
