"""
function_test.py

A script to calculate the factorial of a non-negative integer.
"""
def factorial(n):
    """
    Calculate the factorial of a non-negative integer n.
    
    Args:
        n (int): A non-negative integer.
        
    Returns:
        int: The factorial of n.
    """
    if n == 0:
        return 1
    return n * factorial(n-1)

if __name__ == "__main__":
    num = int(input("Enter a number: "))
    print("Factorial of", num, "is", factorial(num))
