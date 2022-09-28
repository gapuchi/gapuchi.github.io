[TOC]

# 9 Solving the Problem of Overfitting

## The Problem of Overfitting

`TODO - Include graphs`

**Overfitting** - if we have too many features, the hypothesis may fit the training set very well ($J(\theta) \approx 0$), but fails to generalize to new examples.

A sample may roughly follow a quadratic relation, but if we throw enough multi-polynomials at it, we could get a wild graph that goes through exactly every training example.

### Addressing Overfitting

We could try to plot the data and eyeball it? We can't do this when there are a lot of features, it's almost impossible to visualize/graph.

The options:

1. Reduce the number of features
   1. Manually select which features to keep
   2. Use a model selection algorithm (to choose the features for us)
2. Regularization
   - Reduce the value of parameters ($\theta_j$)
   - Works well when we have a lot features (each of which contribute to a bit to predicting $y$)

## Cost Function

> **Intuition** - a higher polynomial may overfit. What if we penalize higher values of $\theta_j$?

Example of a penalty:
$$
\min_\theta \frac1{2m}\left[ \sum_{i=0}^m (h_\theta(x^{(i)}) - y^{(i)})^2 + 1000 \times \theta_3^2 + 1000 \times \theta_4^2\right]
$$
This forces $\theta_3$ and $\theta_4$ to be smaller. This will result in a simpler hypothesis, and less prone to overfitting. We arbritarily chose the two thetas above to penalize, but it is hard to pick which ones to penalize for every case, so, to generalize, we add a penalty for all of them.

**Cost Function (Linear Regression) (Regularized)**
$$
J(\theta) = \frac1{2m}\left[ \sum_{i=0}^m (h_\theta(x^{(i)}) - y^{(i)})^2 + \lambda \sum_{j=1}^m \theta_j^2 \right]
$$

- $\lambda$ - **regularization parameter**
- $\lambda \sum_{j=1}^m \theta_j^2$ - **regularization term**
- We are not penalizing $\theta_0$ by convention. (Note the $j=1$ on the $\sum$ in the regularization term)

**What if we choose a really large $\lambda$?** Theta will go to $0$, $h_\theta(x) = \theta_0$. "Underfitting"

## Regularized Linear Regression

So with regularization, we are trying to solve:
$$
J(\theta) = \frac1{2m}\left[ \sum_{i=0}^m (h_\theta(x^{(i)}) - y^{(i)})^2 + \lambda \sum_{j=1}^m \theta_j^2 \right] \Bigg| \min_\theta J(\theta)
$$

### Gradient Descent

[Previous Gradient Descent](#gradient-descent-for-multiple-variables)

With regularization, our new gradient descent looks like:
$$
\begin{align*} & \text{Repeat}\ \lbrace \newline & \ \ \ \ \theta_0 := \theta_0 - \alpha\ \frac{1}{m}\ \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)})x_0^{(i)} \newline & \ \ \ \ \theta_j := \theta_j - \alpha\ \left[ \left( \frac{1}{m}\ \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)})x_j^{(i)} \right) + \frac{\lambda}{m}\theta_j \right] &\ \ \ \ \ \ \ \ \ \ j \in \lbrace 1,2...n\rbrace\newline & \rbrace \end{align*}
$$
The second term can be rewritten:
$$
\theta_j := \theta_j \left(1 - \alpha \frac{\lambda}{m} \right) - \alpha\ \frac{1}{m}\ \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)})x_j^{(i)}
$$

| Term                                                         | Effect                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| $1 - \alpha \frac {\lambda}{m}$                              | Can be evaluated to a value a little less than one. This effectively shrinks $\theta_j$ each iteration |
| $\alpha\ \frac{1}{m}\ \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)})x_j^{(i)}$ | Performs the gradient descent                                |

### Normal Equation

Previously, given:
$$
X = \begin{bmatrix}
(x^{(1)})^\intercal \\
\vdots \\
(x^{(m)})^\intercal \\
\end{bmatrix}
\quad
y= \begin{bmatrix}
y^1\\
\vdots\\
y^m
\end{bmatrix}\\
$$
we can calculate:
$$
\theta= (X^\intercal X)^{-1}X^\intercal y
$$
Let's take our new $J(\theta)$, calculate $\frac{\partial}{\partial \theta_j} J(\theta) = 0$:

`TODO - Solve this`

This will give us:
$$
\begin{align*}& \theta = \left( X^TX + \lambda \cdot L \right)^{-1} X^Ty \newline& \text{where}\ \ L = \begin{bmatrix} 0 & & & & \newline & 1 & & & \newline & & 1 & & \newline & & & \ddots & \newline & & & & 1 \newline\end{bmatrix}\end{align*}
$$

#### Non-Invertibility

If $m < n$, then $X^\intercal X$ is non-invertible. If $m=n$, then $X^\intercal X$ may be non-invertible. However, with regularization, if $\lambda > 0$, it can be proved that $\left( X^TX + \lambda \cdot L \right)$ is not non-invertible. Another benefit of regularization.

## Regularized Logistic Regression

Similarly, we can do the same regularization with logistic regression.

**Cost Function (Logisitc Regression) (Regularized)**

$$
J(\theta) = - \left[ \frac1m \sum_{i=0}^m y^{(i)}log(h_\theta(x^{(i)})) + (1-y^{(i)})log(1-h_\theta(x^{(i)}) \right] + \frac{\lambda}{2m} \sum_{j=1}^m \theta_j^2
$$

**Gradient Descent**

$$
\begin{align*} & \text{Repeat}\ \lbrace \newline & \ \ \ \ \theta_0 := \theta_0 - \alpha\ \frac{1}{m}\ \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)})x_0^{(i)} \newline & \ \ \ \ \theta_j := \theta_j - \alpha\ \left[ \left( \frac{1}{m}\ \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)})x_j^{(i)} \right) + \frac{\lambda}{m}\theta_j \right] &\ \ \ \ \ \ \ \ \ \ j \in \lbrace 1,2...n\rbrace\newline & \rbrace \end{align*}
$$
