[TOC]

# Parameter Learning

## Gradient Descent

**Gradient descent** can be used to find the minimum of functions, including our *cost function*.

General plan

1. Start with some $\theta_0,\theta_1$
2. Keep changing $\theta_0,\theta_1$ to reduce $J(\theta_0,\theta_1)$ until we hopefully end up at a minimum

It will not necessary find the lowest value, it can lead to a local minimum.

Generally, repeat the following until convergence:
$$
\theta_j := \theta_j-\alpha\frac{\partial}{\partial\theta_j}J(\theta_0,\theta_1)\text{ (for j = 0 and j = 1)}
$$
$:=$ is assignment. $=$ is declaring the two are the same.

To be strictly correct, we want to update all $\theta_j$ simultaneously. If we executed the above twice, for `j=0` and `j=1`, the computations of $\theta_1$ will be using the new value of $\theta_0$. So technically, this is how we would perform gradient descent:
$$
\begin{align*}
temp0 &:= \theta_0-\alpha\frac{\partial}{\partial\theta_0}J(\theta_0,\theta_1)\\
temp1 &:= \theta_1-\alpha\frac{\partial}{\partial\theta_1}J(\theta_0,\theta_1)\\
\theta_0 &:= temp0\\
\theta_1 &:= temp1\\
\end{align*}
$$
Intuitively, let's break down the update:
$$
\begin{align*}
\theta_j &&& \text{The parameter being updated}\\
\frac{\partial}{\partial\theta_j}J(\theta_0,\theta_1) &&& \text{The slope of the cost function. The rate at which the cost function increases as we increase }\theta_j\\
-\alpha &&& \text{The negative moves in the opposite direction of the slope. }\alpha\text{ dictates the size of the step }\theta_j\text{ will change.}\\
\end{align*}
$$

- If $\alpha$ is too large, the function may fail to converge. It may take a huge step and pass the minimum. It can diverge, or just go back and forth two places.
- If $\alpha$ is too small, the gradient descent can be slow.

As we approach a local minimum, gradient descent will **automatically take smaller steps.** Why? The derivative gets smaller and smaller as we get closer and closer. This means the total change in $\theta_j$ gets smaller as well.

## Gradient Descent For Linear Regression

Let's apply gradient descent to our cost function for linear regression.
$$
\begin{align*}
\frac{\partial}{\partial\theta_j}J(\theta_0,\theta_1) &= \frac{\partial}{\partial\theta_j}\frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
 &= \frac{\partial}{\partial\theta_j}\frac{1}{2m}\sum^m_{i=1}(\theta_0+\theta_1x^{(i)} - y^{(i)})^2\\
\end{align*}
$$
We need to evaluate this partial derivative for $j=0$ and $j=1$:
$$
\begin{align*}
\frac{\partial}{\partial\theta_0}J(\theta_0,\theta_1) &= \frac{\partial}{\partial\theta_0}\frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
&= \frac{1}{2m}\sum^m_{i=1}\left(\frac{\partial}{\partial\theta_0}(h_\theta(x^{(i)}) - y^{(i)})^2\right)\\
&= \frac{1}{2m}\sum^m_{i=1}\left(2\times(h_\theta(x^{(i)}) - y^{(i)})\times\frac{\partial}{\partial\theta_0}\left(h_\theta(x^{(i)}) - y^{(i)}\right)\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\left(\frac{\partial}{\partial\theta_0}h_\theta(x^{(i)}) - \frac{\partial}{\partial\theta_0}y^{(i)}\right)\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\left(\frac{\partial}{\partial\theta_0}h_\theta(x^{(i)}) - 0\right)\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\frac{\partial}{\partial\theta_0}h_\theta(x^{(i)})\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\frac{\partial}{\partial\theta_0}(\theta_0+\theta_1x^{(i)})\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times1\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left(h_\theta(x^{(i)}) - y^{(i)}\right)\\
\end{align*}
$$

$$
\begin{align*}
\frac{\partial}{\partial\theta_1}J(\theta_0,\theta_1) &= \frac{\partial}{\partial\theta_1}\frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
&= \frac{1}{2m}\sum^m_{i=1}\left(\frac{\partial}{\partial\theta_1}(h_\theta(x^{(i)}) - y^{(i)})^2\right)\\
&= \frac{1}{2m}\sum^m_{i=1}\left(2\times(h_\theta(x^{(i)}) - y^{(i)})\times\frac{\partial}{\partial\theta_1}\left(h_\theta(x^{(i)}) - y^{(i)}\right)\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\left(\frac{\partial}{\partial\theta_1}h_\theta(x^{(i)}) - \frac{\partial}{\partial\theta_1}y^{(i)}\right)\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\left(\frac{\partial}{\partial\theta_1}h_\theta(x^{(i)}) - 0\right)\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\frac{\partial}{\partial\theta_1}h_\theta(x^{(i)})\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times\frac{\partial}{\partial\theta_1}(\theta_0+\theta_1x^{(i)})\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times(0+x^{(i)})\right)\\
&= \frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times x^{(i)}\right)\\
\end{align*}
$$

With these derivatives figured out we can replace it in our gradient descent update:
$$
\begin{align*}
\theta_0 &:= \theta_0-\alpha\frac{1}{m}\sum^m_{i=1}\left(h_\theta(x^{(i)}) - y^{(i)}\right)\\
\theta_1 &:= \theta_1-\alpha\frac{1}{m}\sum^m_{i=1}\left((h_\theta(x^{(i)}) - y^{(i)})\times x^{(i)}\right)\\
\end{align*}
$$
**"Batch" Gradient Descent** - "batch" refers to gradient descent using all the training examples. Some other gradient descents may not look at the entire training set.

There is another solution that doesn't need the repetitive approach of gradient descent and rather calculates the minimum straight out, it is called **normal equations method**. Gradient descent scales better with large data sets.