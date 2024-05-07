# function_test.py

def factorial(n):
    if n == 0:
        return 1
    return n * factorial(n-1)

if __name__ == "__main__":
    num = int(input("Enter a number: "))
    print("Factorial of", num, "is", factorial(num))
