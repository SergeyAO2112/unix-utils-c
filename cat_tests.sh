#!/bin/bash

S21_CAT="./s21_cat"
GNU_CAT="cat"

TMP1=$(mktemp)
TMP2=$(mktemp)

trap 'rm -f "$TMP1" "$TMP2"' EXIT

fail() {
    echo "FAIL: $1"
    exit 1
}

pass() {
    echo "PASS: $1"
}

test_n() {
    $S21_CAT -n test/1.txt > "$TMP1"
    $GNU_CAT -n test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-n mismatch on test/1.txt"
    pass "-n"
}

test_b() {
    $S21_CAT -b test/1.txt > "$TMP1"
    $GNU_CAT -b test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-b mismatch on test/1.txt"
    pass "-b"
}

test_s() {
    $S21_CAT -s test/3.txt > "$TMP1"
    $GNU_CAT -s test/3.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-s mismatch on test/3.txt"
    pass "-s"
}

test_e() {
    $S21_CAT -e test/1.txt > "$TMP1"
    $GNU_CAT -e test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-e mismatch on test/1.txt"
    pass "-e"
}

test_t() {
    $S21_CAT -t test/4.txt > "$TMP1"
    $GNU_CAT -t test/4.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-t mismatch on test/4.txt"
    pass "-t"
}

test_s_n() {
    $S21_CAT -s -n test/1.txt > "$TMP1"
    $GNU_CAT -s -n test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-s -n mismatch"
    pass "-s -n"
}

test_b_e_t() {
    $S21_CAT -b -e -t test/4.txt > "$TMP1"
    $GNU_CAT -b -e -t test/4.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-b -e -t mismatch"
    pass "-b -e -t"
}

test_multiple_files_n() {
    $S21_CAT -n test/1.txt test/2.txt test/3.txt > "$TMP1"
    $GNU_CAT -n test/1.txt test/2.txt test/3.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-n on multiple files mismatch"
    pass "-n (multiple files)"
}

test_number_nonblank() {
    $S21_CAT --number-nonblank test/3.txt > "$TMP1"
    $GNU_CAT --number-nonblank test/3.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "number_nonblank mismatch"
    pass "number_nonblank"
}

test_number() {
    $S21_CAT --number test/1.txt > "$TMP1"
    $GNU_CAT --number test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "--number mismatch on test/1.txt"
    pass "--number"
}

test_squeeze_blank() {
    $S21_CAT --squeeze-blank test/1.txt > "$TMP1"
    $GNU_CAT --squeeze-blank test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "--squeeze-blank mismatch on test/1.txt"
    pass "--squeeze-blank"
}

test_V_gnu() {
    $S21_CAT -T test/1.txt > "$TMP1"
    $GNU_CAT -T test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-E mismatch on test/1.txt"
    pass "-E"
}

test_E() {
    $S21_CAT -E test/1.txt > "$TMP1"
    $GNU_CAT -E test/1.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-E mismatch on test/1.txt"
    pass "-E"
}

test_T() {
    $S21_CAT -T test/4.txt > "$TMP1"
    $GNU_CAT -T test/4.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-T mismatch on test/4.txt"
    pass "-T"
}

test_e_full() {
    $S21_CAT -e test/4.txt > "$TMP1"
    $GNU_CAT -vE test/4.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-e should equal -vE"
    pass "-e == -vE"
}

test_t_full() {
    $S21_CAT -t test/4.txt > "$TMP1"
    $GNU_CAT -vT test/4.txt > "$TMP2"
    cmp -s "$TMP1" "$TMP2" || fail "-t should equal -vT"
    pass "-t == -vT"
}

test_n
test_b
test_s
test_e
test_t
test_s_n
test_b_e_t
test_multiple_files_n
test_number_nonblank
test_number
test_squeeze_blank
test_V_gnu
test_E
test_T
test_e_full
test_t_full