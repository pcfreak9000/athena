#!/usr/bin/env python3
import sys
import math

def largest_divisor_not_exceeding(X, N):
    max_divisor = -1
    for i in range(1, int(math.isqrt(X)) + 1):
        if X % i == 0:
            # i is a divisor
            if i <= N:
                max_divisor = max(max_divisor, i)
            # X // i is also a divisor
            if (X // i) <= N:
                max_divisor = max(max_divisor, X // i)
    return max_divisor

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 largest_divisor.py <X> <N>")
        sys.exit(1)
    
    try:
        X = int(sys.argv[1])
        N = int(sys.argv[2])
    except ValueError:
        print("Error: both X and N must be integers.")
        sys.exit(1)

    if X <= 0 or N <= 0:
        print("Error: both X and N must be positive integers.")
        sys.exit(1)

    Y = largest_divisor_not_exceeding(X, N)
    if Y == -1:
        print("No divisor of X is less than or equal to N.")
        sys.exit(0)
    
    F = X // Y
    #print(f"Largest divisor ≤ {N}: {Y}")
    #print(f"Factor such that X = Y × F: {F}")
    #print(f"Verification: {Y} × {F} = {Y * F}")
    print(f"CPUs per node: {Y}")
    print(f"Nodes: {F}")

if __name__ == "__main__":
    main()
