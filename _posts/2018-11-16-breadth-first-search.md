---
layout: post
title:  "Functional Breadth First Search"
date:   2018-11-16
categories: [scala]
---

Wanting to expand my comment on [this reddit post](https://www.reddit.com/r/scala/comments/97zbb2/scala_for_algorithmic_graph_problems/e4c99jj/), I wanted to take a functional approach to classic algorithms. In this case, I wanted to create a breadth first.

We'll use `Node` to represent a node in the graph we're traversing.


```scala
case class Node(id: String, neighbors: Set[Node])
```

The general approach to BFS is to use a FIFO queue to visit neighbors, marking each node as visited. We can use `Seq` to implement a FIFO queue and `Set` to keep track of visited neighbors.

We can utilize recursive functions. Each iteration will need to know the target, the visited nodes, and the one that needs to be visited. It should return a Node, which will be our target, or `null` if not found.

```scala
def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = ???
```

First let's address the terminating conditions: when we find the node or if there no more nodes left to look. In each iteration we will be looking at the head of the `toVisit` queue.

```scala
def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = {
    if (toVisit.isEmpty) return null
    if (toVisit.head.id == targetId) return toVisit.head
    ...
}
```

Now let's address the recursive part. If we haven't found the node, we want to check the neighbors (that have not been visited) and remember this node we have already visited.

```scala
def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = {
    if (toVisit.isEmpty) return null
    if (toVisit.head.id == targetId) return toVisit.head

    val newVisitedNodes = visitedNodes + toVisit.head
    // &~ find the difference of the two sets
    val newToVisit = toVisit ++: (toVisit.head.neighbors &~ visitedNodes).toSeq 

    return find(targetId, newToVisit, newVisitedNodes)
}
```

[Don't use return in Scala](https://tpolecat.github.io/2014/05/09/return.html).

```scala
def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = {
    if (toVisit.isEmpty) null
    else if (toVisit.head.id == targetId) toVisit.head
    else {
        val newVisitedNodes = visitedNodes + toVisit.head
        // &~ find the difference of the two sets
        val newToVisit = toVisit ++: (toVisit.head.neighbors &~ visitedNodes).toSeq 

        find(targetId, newToVisit, newVisitedNodes)
    }
}
```

The if statement is conditional on the `toVisit` variable. Given this, I prefer utilizing `match`:

```scala
def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = 
    toVisit match {
        case Nil => null
        case head :: _ if head.id == targetId => head
        case head :: tail => {
            val newVisitedNodes = visitedNodes + toVisit.head
            // &~ find the difference of the two sets
            val newToVisit = toVisit ++: (toVisit.head.neighbors &~ visitedNodes).toSeq 

            find(targetId, newToVisit, newVisitedNodes)
        }
    }
```

Inlining some variables and removing some braces results in:

```scala
def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = 
    toVisit match {
        case Nil => null
        case head :: _ if head.id == targetId => head
        case head :: tail => find(targetId, tail ++: (head.neighbors &~ visitedNodes).toSeq, 
            visitedNodes + head)
    }
```

and add an entry method, giving us the final:

```scala
def find(targetId: String, startingNode: Node): Node = 
        find(targetId, Seq(startingNode), Set.empty)

def find(targetId: String, toVisit: Seq[Node], visitedNodes: Set[Node]): Node = 
    toVisit match {
        case Nil => null
        case head :: _ if head.id == targetId => head
        case head :: tail => find(targetId, tail ++: (head.neighbors &~ visitedNodes).toSeq, 
            visitedNodes + head)
    }
```