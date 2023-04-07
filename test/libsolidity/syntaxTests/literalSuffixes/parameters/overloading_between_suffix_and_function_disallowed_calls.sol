function s(uint) pure suffix returns (uint) {}
function s(string memory) pure returns (string memory) {}

contract C {
    function run() public pure {
        1 s;    // OK
        s(1);   // OK
        "a" s;  // not allowed
        s("a"); // OK
    }
}
// ----
// TypeError 8792: (162-163): Overloaded functions cannot be used as literal suffixes.
