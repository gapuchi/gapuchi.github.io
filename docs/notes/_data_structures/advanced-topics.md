---
layout: post
title: Advanced Topics
---

# Topological Sort

1. Identify all nodes with no incoming edges
1. Add to order
1. Remove all outgoing edges
1. Repeat

# Dijkstra's Algorithm

Finds shortest path from a to b

## Setup

1. Create `weight` datastructure. Stores for every node `x` the weight from `a` to `x`. Everything should be infinite except `a` which should be `0`.
1. Create `previous` datastructure. Stores for every node `x` the previous node that leads to the current weight. Should be null for everything
1. Create `remaining` priority queue. Prioritize on lowest weight. Should start with `a`.

## Algorithm

1. Take the lowest node (`y`) from `remaining` (first time it is `a`)
1. For every neighbor, check the current `weight` with `y`'s weight + the weight from `y` to neighbor. If y's path is better, update `weight` and `previous`.
1. Remove `y`.
1. Repeat.

Why a priority queue?

Because the shortest path has the opportunity for providing a quicker way to other paths. If `b` is `3` and `c` is `70`, it doesn't make sense to check `c` because `b` might have a shorter path to `c`. Then the check on `c` is useless because `c` wasn't the shortest.

By checking the shortest first, we guarantee when we get to node `x`, there are no other paths to `x` that would be shorter, because every other weight is higher.
