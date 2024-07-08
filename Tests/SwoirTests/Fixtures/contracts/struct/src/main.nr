struct Factors {
    a: Field,
    b: Field,
}

fn main(factors: Factors, result: pub Field) {
    assert(factors.a * factors.b == result);
}

#[test]
fn test_main() {
    main(Factors { a: 2, b: 5 }, 10);
}
