---
layout: post
title: Implementations
---

```java
class Node {
  int val;

  Node left;
  Node right;

  constructor
}
```

# BFS

## Iterative

```java
int val = 3;

LinkedList<Node> queue = new LinkedList<Node>();

queue.add(root);


while(queue.isNotEmpty()) {
  Node x = queue.pop();
  if (x == val) {
    return x;
  }

  queue.add(x.left);
  queue.add(x.right);
}
```

# DFS

## Iterative

```java
int val = 3;

Stack<Node> stack = new Stack<Node>();

queue.push(root);


while(queue.isNotEmpty()) {
  Node x = queue.pop();
  if (x == val) {
    return x;
  }

  queue.push(x.left);
  queue.push(x.right);
}
```

## Recursive

```java
int val = 3;

Stack<Node> stack = new Stack<Node>();

queue.push(root);


while(queue.isNotEmpty()) {
  Node x = queue.pop();
  if (x == val) {
    return x;
  }

  queue.push(x.left);
  queue.push(x.right);
}

private Node search(Node node) {
  if (node.x == val) {
    return x;
  } 
}
```