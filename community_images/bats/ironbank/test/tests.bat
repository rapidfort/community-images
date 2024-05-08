#!/usr/bin/env bats

@test "addition using Bash arithmetic" {
    result=$((2 + 2))
    [ "$result" -eq 4 ]
}

@test "addition using command substitution" {
    result=$(echo "$((2 + 2))")
    [ "$result" -eq 4 ]
}

@test "addition using awk" {
    result=$(echo "2 2" | awk '{print $1 + $2}')
    [ "$result" -eq 4 ]
}

@test "addition using Python" {
    result=$(python -c 'print(2 + 2)')
    [ "$result" -eq 4 ]
}

# Test File Operations
@test "Test file creation and deletion" {
    touch testfile.txt
    [ -f testfile.txt ]
    rm testfile.txt
    [ ! -f testfile.txt ]
}

# Test String Manipulation
@test "Test string concatenation" {
    str1="Hello"
    str2="World"
    result="$str1 $str2"
    [ "$result" == "Hello World" ]
}

# Test Control Structures
@test "Test if statement" {
    value=10
    if [ "$value" -eq 10 ]; then
        result="true"
    else
        result="false"
    fi
    [ "$result" == "true" ]
}

# Test Command Execution
@test "Test command output" {
    output=$(echo "Hello, Bats!")
    [ "$output" == "Hello, Bats!" ]
}

# Test Environment Variables
@test "Test environment variable" {
    export TEST_VAR="Bats Test"
    [ "$TEST_VAR" == "Bats Test" ]
    unset TEST_VAR
}

# Test Integration with External Command
@test "Test integration with date command" {
    date=$(date +%Y-%m-%d)
    [ "$date" == "$(date +%Y-%m-%d)" ]
}





