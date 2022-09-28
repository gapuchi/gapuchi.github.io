[TOC]

# 5 Computing Parameters Analytically

## Normal Equation

*Gradient descent* solved for $\theta$ iteratively, getting closer and closer. *Normal equation* will give us a method to solve for $\theta$ analytically.

We do this by taking the derivative and setting it to 0.

For $\theta \in \R^1$, this is pretty simple:
$$
J(\theta) = a\theta^2 + b\theta + c\\
\frac{\partial}{\partial \theta} J(\theta) = \dots = 0
$$
and then solve for $\theta$.

For our multivariate linear regression $\theta \in \R^{n+1}$:
$$
J(\theta_0, \theta_1, \ldots, \theta_n) = \frac{1}{2m} \sum^{m}_{i=1}(h_\theta(x^{(i)})-y^{(i)})^2\\
\frac{\partial}{\partial\theta_j} J(\theta) = \dots = 0 \text{ (for every }j\text{)}
$$
This calculus is rather involved so I am not going to work it out right now, but let's take a look at the end result with an example:

| <br />$x_0$ | Size (feet squared)<br />$x_1$ | # of bedrooms<br />$x_2$ | # of floors<br />$x_3$ | age of home<br />$x_4$ | price (\$1000)<br /> $y$ |
| ----------- | ------------------------------ | ------------------------ | ---------------------- | ---------------------- | ------------------------ |
| 1           | 2104                           | 5                        | 1                      | 45                     | 460                      |
| 1           | 1416                           | 3                        | 2                      | 40                     | 232                      |
| 1           | 1534                           | 3                        | 2                      | 30                     | 315                      |
| 1           | 852                            | 2                        | 1                      | 36                     | 178                      |

Take the features and output and put it into matrices:
$$
X=\begin{bmatrix}
1 & 2104 & 5 & 1 & 45\\
1 & 1416 & 3 & 2 & 40\\
1 & 1534 & 3 & 2 & 30\\
1 & 852 & 2 & 1 & 36\\
\end{bmatrix}
\qquad
\theta=\begin{bmatrix}
\theta_0\\
\theta_1\\
\theta_2\\
\theta_3\\
\theta_4\\
\end{bmatrix}
\qquad
y=\begin{bmatrix}
460\\
232\\
315\\
178\\
\end{bmatrix}
$$
$X$ is a $m \times n$ matrix and $y$ is a $m$ dimensional matrix. Given the above:
$$
\theta = (X^\intercal X)^{-1}X^\intercal y
$$

### General Definition

Let's say we have $m$ examples $(x^{(1)}, y^{(1)}), \ldots, (x^{(m)}, y^{(m)})$ and $n$ features.
$$
x^{(i)} = \begin{bmatrix}
x_0^{(i)}\\
x_1^{(i)}\\
\vdots\\
x_n^{(i)}\\
\end{bmatrix}
\in \R^{n+1}
\text{ training sample}
\qquad
X = \begin{bmatrix}
(x^{(1)})^\intercal\\
(x^{(2)})^\intercal\\
\vdots\\
(x^{(m)})^\intercal\\
\end{bmatrix}
\text{ (design matrix)}
$$
In $X$, each column is a feature, each row is a sample/input. We can find $\theta$:
$$
\theta = (X^\intercal X)^{-1}X^\intercal y
$$

>  TODO - derive the above.

In this approach, we do not need *feature scaling* or *mean normalization*.

When to choose gradient descent vs normal equation?

| Gradient Descent            | Normal Equation                              |
| --------------------------- | -------------------------------------------- |
| Need to choose $\alpha$     | No need to choose $\alpha$                   |
| Needs iterations            | No need to iterate                           |
| Scales well with large $n$. | Slow with large $n$.                         |
| $O(kn^2)$                   | $O(n^3)$ to calculate $(X^\intercal X)^{-1}$ |

As long as $n$ isn't too large, normal equation is a good method.

> TODO - derive the big O.

### Non-Invertibility

$$
\theta = (X^\intercal X)^{-1}X^\intercal y
$$

What if $X^\intercal X$ is non-invertible?

- Redundant features (linearly dependent)
- Too many features (e.g. $m \leq n$).
  - Delete features, or use regularization