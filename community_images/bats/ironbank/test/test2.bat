#!/usr/bin/env bats

@test "@setup: Create temporary directory" {
    mkdir temp_dir
}

# Teardown function to clean up temporary directory
@test "@teardown: Remove temporary directory" {
    rm -rf temp_dir
}

# Grouping tests under a common label
@test "String Manipulation Tests" {
    
    # Test string concatenation
    @test "Test string concatenation" {
        str1="Hello"
        str2="World"
        result="$str1 $str2"
        [ "$result" == "Hello World" ]
    }
    
    # Test substring extraction
    @test "Test substring extraction" {
        str="Hello World"
        substring="${str:6}"
        [ "$substring" == "World" ]
    }
}

# Skipping a test based on condition
@test "Skipping Test Based on Condition" {
    skip "This test is skipped on purpose"
    result="This should not be executed"
    [ "$result" == "" ]
}

# Positive assertions: each of these should succeed
@test "basic return-code checking" {
  run true
  run -0 true
  run '!' false
  run -1 false
  run -3 exit 3
  run -5 exit 5
  run -111 exit 111
  run -255 exit 255
  run -127 /no/such/command
}


# Define upper and lower boundaries
MAX_VALUE=10
MIN_VALUE=0

# Test Case: Verify behavior at the upper boundary of input range
@test "Test upper boundary input" {
    run python /tmp/function_test.py <<EOF
${MAX_VALUE}
EOF
    echo "Output: ${output}"  # Add debug output
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Enter a number: Factorial of ${MAX_VALUE} is 3628800" ]]
    # Add additional assertions as needed
}

# Test Case: Verify behavior at the lower boundary of input range
@test "Test lower boundary input" {
    run python /tmp/function_test.py <<EOF
${MIN_VALUE}
EOF
    echo "Output: ${output}"  # Add debug output
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Enter a number: Factorial of ${MIN_VALUE} is 1" ]]
    # Add additional assertions as needed
}