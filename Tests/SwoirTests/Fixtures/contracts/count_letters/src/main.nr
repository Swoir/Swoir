fn main(words: [u8; 13], letter: pub u8, count: Field) {
    let mut counter = 0;
    for word_letter in words {
        if word_letter == letter {
            counter += 1;
        }
    }
    assert(counter == count);
}

#[test]
fn test_main() {
    // Hello, world!
    let words: [u8; 13] = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21];
    // l
    let letter = 0x6c;
    // l occurs 3 times
    let count = 3;

    main(words, letter, count);
}
