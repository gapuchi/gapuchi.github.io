---
layout: post
title: Trees and Graphs
---

* Complete - Levels are filled. (Bottom is filled left to right)
* Full - Nodes have either 0 or 2 leaves
* Perfect - Complete and Full

# Binary Tree Traversal

* In Order - left, current, right
* Pre Order - current, left, right
* Post Order - left, right, current

# Binary Heaps

* Complete Binary Tree

## Insert

* Insert and the next available space (left to right)
* Compare with parent. Swap unitl its fine  

## Remove min

* Take the last element and put it on top. Swap down (swap with the lower of the two)

# Graphs

TBD

* Adjacency List
* Adjacency Matrix

# Graph Search

BFS - If we want to find the shortest path
DFS - If we want to search the whole thing

## DFS

### Recursive

* Call search on each child

### Iterative

* Stack

## BFS

* Can **not** be recursive. Use a queue.
