---
layout: post
title: Recursion and Dynamic Programming
---

# Approaches

## Bottom-Up Approach

Solve for a simple case (such as a list with one element) and work your way up.

## Top-Down Approach

How can we divide the problem for case N into subproblems

## Half and Half Approach

Solve data by splitting into half.

# Recursive vs Iterative

Recursive can be very space inefficient. It is better to implement a recursive algorithm iteratively. **All** recursive algorithms can be implemented iteratively.

**How to do this?**

```java
int fib(int i) {
  if (i == 0) return 0;
  if (i == 1) return 1;
  return fib(i - 1) + fib(i - 2);
}
```

```java
int fib(int i) {

  if (i == 0) return 0;
  if (i == 1) return 1;

  int acc = 0;

  while (true) {

  }
}
```

# Dynamic Programming and Memoization

Essentially is a recursive program where subproblems are repeated, so we cache these problems.

Memoization is top-down dynamic programming. Others refer DP as bottom up.

## Fibonacci Numbers

### Recursive

```java
int fib(int i) {
  if (i == 0) return 0;
  if (i == 1) return 1;
  return fib(i - 1) + fib(i - 2);
}
```

Runtime? O( 2^n^ ). Every `n` makes two calls. 

## Memoization

```java
int fib(int i) {
  return fib(i, new int[i + 1])
}

if fib(int i, int[] memo) {
  if (i == 0 || i == 1) return i;

  if (memo[i] == 0) {
    memo[i] = fib(i - 1, memo) + fib(i - 2, memo);
  }

  return memo[i];
}
```

Runtime? O( n ). Every `n` is calculated once

## Bottoms Up DP

```java
if fib(int i) {
  if (i == 0 || i == 1) return i;

  int[] memo = new int[n];
  memo[0] = 0;
  memo[1] = 1;

  for(int j = 2; j < n; j++) {
    memo[j] = memo[j - 1] + memo[j - 2];
  }

  return memo[n - 1] + memo[n - 2];
}
```

Can this be done with recursion? No. Because recursion is about breaking a problem down. This is building it up.
