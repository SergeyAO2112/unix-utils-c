#!/bin/bash

S21_GREP="./s21_grep"
GNU_GREP="grep"

TMP1=$(mktemp)
TMP2=$(mktemp)

trap 'rm -f "$TMP1" "$TMP2"' EXIT

fail() {
    echo "FAIL: $1"
    return 1
}

pass() {
    echo "PASS: $1"
}

test_i() {
    $S21_GREP -i src test/1.txt > "$TMP1"
    $GNU_GREP -i src test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-i mismatch on test/1.txt"; return; }
    pass "-i"
}

test_v() {
    $S21_GREP -v src test/1.txt > "$TMP1"
    $GNU_GREP -v src test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-v mismatch on test/1.txt"; return; }
    pass "-v"
}

test_c() {
    $S21_GREP -c hhru test/3.txt > "$TMP1"
    $GNU_GREP -c hhru test/3.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-c mismatch on test/3.txt"; return; }
    pass "-c"
}

test_e() {
    $S21_GREP -e src test/1.txt > "$TMP1"
    $GNU_GREP -e src test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-e mismatch on test/1.txt"; return; }
    pass "-e"
}

test_multiple_e() {
    $S21_GREP -e src -e test -e hello test/1.txt > "$TMP1"
    $GNU_GREP -e src -e test -e hello test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "Multiple -e flags mismatch"; return; }
    pass "Multiple -e flags"
}

test_l() {
    $S21_GREP -l src test/* > "$TMP1"
    $GNU_GREP -l src test/* > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-l mismatch on test/*.txt"; return; }
    pass "-l"
}

test_n() {
    $S21_GREP -n src test/1.txt > "$TMP1"
    $GNU_GREP -n src test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-n mismatch"; return; }
    pass "-n"
}

test_combination() {
    $S21_GREP -i -n -v src test/1.txt > "$TMP1"
    $GNU_GREP -i -n -v src test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "Flag combination -i -n -v mismatch"; return; }
    pass "Flag combination -i -n -v"
}

test_c_l_combination() {
    $S21_GREP -c -l src test/1.txt test/2.txt > "$TMP1"
    $GNU_GREP -c -l src test/1.txt test/2.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-c -l combination mismatch"; return; }
    pass "-c -l combination"
}

test_multiple_files() {
    $S21_GREP src test/1.txt test/2.txt > "$TMP1"
    $GNU_GREP src test/1.txt test/2.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "Multiple files without flags mismatch"; return; }
    pass "Multiple files"
}

test_pattern_special_chars() {
    $S21_GREP "test.*src" test/1.txt > "$TMP1"
    $GNU_GREP "test.*src" test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "Pattern with special chars mismatch"; return; }
    pass "Pattern with special chars"
}

test_i_multiple_files() {
    $S21_GREP -i SRC test/1.txt test/2.txt > "$TMP1"
    $GNU_GREP -i SRC test/1.txt test/2.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "-i with multiple files mismatch"; return; }
    pass "-i with multiple files"
}

test_empty_pattern() {
    $S21_GREP -e "" test/1.txt > "$TMP1"
    $GNU_GREP -e "" test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || { fail "Empty pattern mismatch"; return; }
    pass "Empty pattern"
}

# Запуск всех тестов
echo "=== Запуск тестов s21_grep ==="
echo ""

test_i
test_v
test_c
test_e
test_l
test_n
test_combination
test_c_l_combination
test_multiple_files
test_pattern_special_chars
test_i_multiple_files
test_empty_pattern