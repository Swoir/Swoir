fn main(x: [Field; 2], y: pub [Field; 2]) {
    assert(x != y);
}

#[test]
fn test_main() {
    main([1, 2], [1, 3]);
}
