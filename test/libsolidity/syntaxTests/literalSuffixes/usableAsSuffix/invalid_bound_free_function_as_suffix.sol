function suffix(uint x, uint y) pure returns (uint) { return x + y; }

contract C {
    using {suffix} for uint;

    uint a = 42;
    uint b = 1000 a.suffix;
}
// ----
// TypeError 4438: (149-157): The literal suffix must be either a subdenomination or a file-level suffix function.
