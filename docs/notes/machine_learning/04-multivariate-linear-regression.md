[TOC]

# 4 Multivariate Linear Regression

## Multiple Features

In original linear regression example our hypothesis was in the form of $h_\theta(x) = \theta_0+\theta_1x$. There was a single variable - $x$. What if we had multiple variables (or features)?
$$
\begin{align*}
m &= \text{number of examples}\\
n &= \text{number of features}\\
x^{(i)} &= \text{input (features) of }i^{th}\text{ training example}\\
x^{(i)}_j &= \text{value of feature }j\text{ in }i^{th}\text{ training example}\\
\end{align*}
$$
Example - Predicting price of a house

| size | # of bedrooms | # of floors | age  | price |
| ---- | ------------- | ----------- | ---- | ----- |
| 2104 | 5             | 1           | 45   | 460   |
| 1416 | 3             | 2           | 40   | 232   |
| 1534 | 3             | 2           | 30   | 315   |
| 852  | 2             | 1           | 36   | 178   |
| ...  | ...           | ...         | ...  | ...   |

$$
\begin{align*}
m &= 47\\
n &= 4\\
x^{(2)} &=
\begin{bmatrix}
1416\\
3\\
2\\
40\\
\end{bmatrix}\\
x^{(2)}_3 &= 2
\end{align*}
$$

What would our new hypothesis look like? We can't use a single $x$. It need to be
$$
h_\theta(x)=\theta_0+\theta_1x_1+\theta_2x_2+\theta_3x_3+\theta_4x_4
$$
In general, our hypothesis is now in the form
$$
h_\theta(x)=\theta_0+\theta_1x_1+\theta_2x_2+\dots+\theta_nx_n
$$
To make notation a bit easier, let's have $x_0=1$ (or $x_0^{(i)}=1$):
$$
x = \begin{bmatrix}
x_0\\
x_1\\
x_2\\
\vdots\\
x_n
\end{bmatrix} \in\R^{n+1}\qquad
\theta = \begin{bmatrix}
\theta_0\\
\theta_1\\
\theta_2\\
\vdots\\
\theta_n
\end{bmatrix} \in\R^{n+1}\\
$$

$$
\begin{align*}
h_\theta(x)&=\theta_0x_0+\theta_1x_1+\theta_2x_2+\dots+\theta_nx_n\\
&=\begin{bmatrix}
\theta_0 \theta_1\dots\theta_n
\end{bmatrix}\begin{bmatrix}
x_0\\
x_1\\
\vdots\\
x_n\\
\end{bmatrix}\\
&=\theta^\intercal x
\end{align*}
$$



This is **multivariate linear regression**.

## Gradient Descent for Multiple Variables

Let's review the notation:
$$
\begin{align*}
\text{Hypothesis} && h_\theta(x)=\theta^\intercal x=\theta_0x_0+\theta_1x+\dots+\theta_nx_n\\
\text{Parameteres} && \theta_0,\theta_1,\ldots,\theta_n = \theta \in \R^{n+1}\\
\text{Cost Function} && J(\theta_0,\theta_1,\ldots,\theta_n) = J(\theta) = \frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
\text{Goal} && \min_{\theta} J(\theta)\end{align*}
$$
Gradient descent would then be repeating the following
$$
\theta_j := \theta_j-\alpha\frac{\partial}{\partial\theta_j}J(\theta)\text{ (simultaneously for }j = 0\ldots n\text{)}
$$
Previously for $n=1$:
$$
\begin{align*}
\theta_0 &:= \theta_0-\alpha\frac{1}{m}\sum^m_{i=1}\left(h_\theta(x^{(i)}) - y^{(i)}\right)\\
\theta_1 &:= \theta_1-\alpha\frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times x^{(i)}\right)\\
\end{align*}
$$
Now for $n\geq1$:
$$
\theta_j := \theta_j-\alpha\frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times x^{(i)}_j\right)\\
$$
Since we have $x_0^{(i)}=1$,  the above statement is true for all values of $j := 0\ldots n$ (again, this is for linear regression)

## Gradient Descent in Practice

### Feature Scaling

> **Idea** - Make sure features are on a similar scale

Example - house pricing

* $x_1=$ size (0-2000)
* $x_2=$ number of bedrooms (1-5)

Because the range of one is much higher, the contour gets really stretched in a direction. (And gradient descent would reach the optimal for one feature way before the other.) This may result in one feature oscillating while gradient descent is working on the other feature.

Instead if you **feature scale** - or divide by the range:

* $x_1=$ size/2000
* $x_2=$ number of bedrooms/5

you'll have both features between 0 and 1.

> Get every feature into **approximately** a $-1 \leq x_i \leq 1$ range.
>
> It doesn't have to be exactly 1 - it could be plus minus 3 or something. As long as it is not plus minus 100, or plus minus 0.000001

### Mean Normalization

Another tactic is to perform **mean normalization**, replacing $x_j$ with $x_j - \mu_j$ to make features have approximately zero mean (except for $x_0=1$):
$$
\begin{align*}
x_1 &= \frac{size-1000}{2000}\\
x_2 &= \frac{\# bedrooms-2}{5}\\
\vdots\\
x_j &= \frac{x_j-\mu_j}{s_j}\\
\end{align*}
$$
$\mu_j$ is the average of all the values for feature j and $s_i$ is the range of values or $s_i$ is the standard deviation.

### Learning Rate

How to choose $\alpha$?

Before we answer this, how do we know gradient descent is working? Track $J(\theta)$ in relation to the number of iterations.

* $J(\theta)$ should decrease after every iteration.
* If the graph is looking flat, it most likely converged
* We can automatically declare convergence if $J(\theta)$ decreases by less than $\epsilon$ in one iteration. (e.g. $\epsilon=10^{-3}$ - the value of this varies)
* If $J(\theta)$ is increasing, it mean it is not working, choose a smaller $\alpha$.
* If $J(\theta)$ is oscillating, it mean it is not working, choose a smaller $\alpha$.
* Choosing a too small $\alpha$ make cause convergence to take forever though.

## Features and Polynomial Regression

Example - house pricing
$$
h_\theta=\theta_0 + \theta_1 \times frontage + \theta_2 \times depth
$$
you can create your own feature (e.g. I want to create a feature for area (frontage x depth)):
$$
h_\theta=\theta_0 + \theta_1 \times area
$$
Similar we can also not be limited to linear regression, we can do quadratic, or other polynomial regression:
$$
h_\theta=\theta_0 + \theta_1 x + \theta_2 x^2 + \theta_3 x^3
$$
This can be redefined to be a linear regression problem:
$$
\begin{align*}
h_\theta &= \theta_0 + \theta_1 size + \theta_2 size^2 + \theta_3 size^3\\
&= \theta_0 + \theta_1 x_1 + \theta_2 x_2 + \theta_3 x_3\\
x_1 &= size\\
x_2 &= size^2\\
x_3 &= size^3\\
\end{align*}
$$
Each power is a new feature. One feature is the square of the area. Another is the cube of the area.

> Feature scaling becomes super important here!