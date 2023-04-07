library L {
    function suffix(uint8) internal pure returns (uint8) {}
    function suffix(uint16) internal pure returns (bytes16) {}
}

contract C {
    using L for uint8;

    function f(uint8 x) public {
        1 x.suffix;
    }
}
// ----
// TypeError 6327: (218-226): Overloaded functions cannot be used as literal suffixes.
