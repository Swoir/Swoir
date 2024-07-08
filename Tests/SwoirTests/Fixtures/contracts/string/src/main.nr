fn main(a: str<5>, b: str<5>, c: [str<5>; 10]) {
    assert(a != b);
    assert(c[0] == a);
    assert(c[1] == b);
    assert(c[2] == a);
    assert(c[3] == b);
    assert(c[4] == a);
    assert(c[5] == b);
    assert(c[6] == a);
    assert(c[7] == b);
    assert(c[8] == a);
    assert(c[9] == b);
}

#[test]
fn test_main() {
    main(
        "hello",
        "world",
        [
        "hello",
        "world",
        "hello",
        "world",
        "hello",
        "world",
        "hello",
        "world",
        "hello",
        "world"
    ]
    );
}
