contract C {
    function f() pure public {
        1 revert;
    }
}
// ----
// TypeError 8792: (54-60): Overloaded functions cannot be used as literal suffixes.
