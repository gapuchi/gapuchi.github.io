---
layout: post
title: Sort and Search
---

# Sorting

## Bubble Sort

|Runtime Average|Runtime Worst|Memory|
|---|---|---|
|O( n^2^ )|O( n^2^ )|O(1)|

Start at the beginning of array and swap if needed. Keep doing this until there are no more swaps.

## Selection Sort

|Runtime Average|Runtime Worst|Memory|
|---|---|---|
|O( n^2^ )|O( n^2^ )|O(1)|

Sweep and find the smallest and swap with first position. Repeat.

## Merge Sort

|Runtime Average|Runtime Worst|Memory|
|---|---|---|
|O(n log(n))|O(n log(n))|O(n)|

Divide arrays into halves (repeatedly) and then join.


### Psuedo Code

```java
def mergesort
  mergesort(left)
  mergesort(right)
  merge(left, right)

def merge
  copy array to helper
  iterate through left and right, copying the smaller element back into array
  copy the remaining left (you don't need to copy the remaining right because they're already there)

```

## Quick Sort

|Runtime Average|Runtime Worst|Memory|
|---|---|---|
|O(n log(n))|O(n^2^)|O(log n)|

Pick a random element and parition the array. Then sort both sides.

### Psuedo Code

```java
def quicksort
  partition (put elements on both sides)
  quicksort left
  quicksort right

def partition
  choose pivot
  find element on left that should be on right
  find element on right that should be on left
  swap
  return center index

```

## Radix Sort

|Runtime Average|Runtime Worst|Memory|
|---|---|---|
|O(kn)|O(kn)|O(n log n)|

Not applicable all the time. Example, sorting integers. Takes advantage that a digit is one of 10 options. k is the number of iterations.

So if we're sorting numbers, first sort on units, tens, and then hundreds.

# Searching

## Binary Search

... You know it.
