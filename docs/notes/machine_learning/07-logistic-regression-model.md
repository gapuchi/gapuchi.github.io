[TOC]

# Logistic Regression Model

## Cost Function

Given:
$$
\begin{align*}
\text{training set} &= \{(x^{(1)}, y^{(1)}), (x^{(2)}, y^{(2)}), \ldots, (x^{(m)}, y^{(m)})\}\\
x &= \begin{bmatrix} x_0\\ x_1\\ \vdots \\ x_n \end{bmatrix} \in \R^{n+1}\\
x_0 &= 1\\
y &\in \{0,1\}\\
h_\theta(x) &= \frac{1}{1 + e^{-\theta^\intercal x}}
\end{align*}
$$
**How do we choose $\theta$?** Similar to linear regression, we have to minimize the cost function.

#### Linear Regression Cost Function

Let's re-write *linear regression cost function*:
$$
\begin{align*}
J(\theta) &= \frac{1}{m} \sum_{i=1}^m \frac12(h_\theta(x^{(i)}) - y^{(i)})^2\\
&= \frac1m \sum_{i=1}^m Cost(h_\theta(x^{(i)}), y^{(i)}) & ``\text{The average cost across the training dataset}"\\
Cost(a,b) &= \frac12 (a - b)^2
\end{align*}
$$
**Can we use the same $Cost$ for logistic regression?** No, we can't. This results in a **non-convex function**, a function with many local minima. This is due to $h_\theta(x) = \frac1{1+e^{-\theta^\intercal x}}$ not being linear. We need a convex function for logistic regression

#### Logistic Regression Cost Function

$$
Cost(a,b) = \begin{cases}
-log(a) & \text{if $y=1$}\\
-log(1-a) & \text{if $y=0$}\\
\end{cases}
$$

##### Looking at $y=1$

$$
cost = \begin{cases}
0 & \text{if $a=1$}\\
\infty & \text{as $a \rarr 0$}\\
\end{cases}
$$

`TODO Include graph.` Note - because we are dealing with logistic functions, $0 \leq a \leq 1$.

**Does $\lim_{a \rarr 0} cost = \infty$ make sense?** If we say, for some value of $x$, that $h_\theta(x) = 0$, then we are saying that there is **no chance that $y=1$**. If it turns out that $y=1$, then our hypothesis is completely, absolutely wrong.

##### Looking at $y=0$

$$
cost = \begin{cases}
0 & \text{if $a=0$}\\
\infty & \text{as $a \rarr 1$}\\
\end{cases}
$$

`TODO Include graph.` Note - because we are dealing with logistic functions, $0 \leq a \leq 1$.

**Does $\lim_{a \rarr1 } cost = \infty$ make sense?** If we say, for some value of $x$, that $h_\theta(x) = 1$, then we are saying that there is **no chance that it is not $y=1$**. If it turns out that $y=0$, then our hypothesis is completely, absolutely wrong.

## Simplified Cost Function and Gradient Descent

$$
Cost(a,b) = \begin{cases}
-log(a) & \text{if $y=1$}\\
-log(1-a) & \text{if $y=0$}\\
\end{cases}
$$

The cost function can be simplified, if we take advantage of the fact that $y \in \{0,1\}$:
$$
Cost(a,b) = -b\ log(a) + (-(1-b)\ log(1-a))
$$
Since $y \in \{0,1\}$, one of the log multipliers will be 0 and the other will be 1.

#### Logistic Regression Cost Function

$$
\begin{align*}
J(\theta) &= \frac1m \sum_{i=1}^m Cost(h_\theta(x^{(i)}), y^{(i)})\\
&= \frac1m \sum_{i=1}^m -y^{(i)}log(h_\theta(x^{(i)})) - (1-y^{(i)})log(1-h_\theta(x^{(i)}))\\
&= -\frac1m \sum_{i=1}^m y^{(i)}log(h_\theta(x^{(i)})) + (1-y^{(i)})log(1-h_\theta(x^{(i)}))\\
\end{align*}
$$

Vectorized:
$$
\begin{align*}
h &= g(X\theta)\\
J(\theta) &= \frac1m \cdot (-y^\intercal log(h) - (1-y)^\intercal log(1-h))
\end{align*}
$$
The above can be derived from the **principle of maximum likelihood estimation**. `TODO Derive this`.

**So how to do we find $\theta$ that minimizes $J(\theta)$?** Gradient descent:
$$
\begin{align*}
& Repeat \; \lbrace \\
& \; \theta_j := \theta_j - \alpha \dfrac{\partial}{\partial \theta_j}J(\theta) \\
& \rbrace
\end{align*}
$$

Let's calculate $\frac{\partial}{\partial\theta_j}J(\theta) = \frac1m \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)}\\$:
$$
\begin{align*}
\frac{\partial}{\partial \theta_j} h_\theta(x) &= \frac{\partial}{\partial \theta_j} \frac{1}{1+e^{-\theta^\intercal x}}\\
&= \frac{\partial}{\partial \theta_j}(1+e^{-\theta^\intercal x})^{-1}\\
&= -(1+e^{-\theta^\intercal x})^{-2} \frac{\partial}{\partial \theta_j} (1+e^{-\theta^\intercal x})\\
&= -(1+e^{-\theta^\intercal x})^{-2} \frac{\partial}{\partial \theta_j} e^{-\theta^\intercal x}\\
&= -(1+e^{-\theta^\intercal x})^{-2} e^{-\theta^\intercal x}  \frac{\partial}{\partial \theta_j}(-\theta^\intercal x)\\
&= (1+e^{-\theta^\intercal x})^{-2} e^{-\theta^\intercal x}  \frac{\partial}{\partial \theta_j}(\theta^\intercal x)\\
&= (1+e^{-\theta^\intercal x})^{-2} e^{-\theta^\intercal x}  x_j\\
&= h_\theta(x)^2 \times e^{-\theta^\intercal x} \times x_j\\
\end{align*}
$$

$$
\begin{align*}
\frac{\partial}{\partial \theta_j} J(\theta) &= \frac{\partial}{\partial \theta_j} \frac{-1}m \sum_{i=1}^m y^{(i)}log(h_\theta(x^{(i)})) + (1-y^{(i)})log(1-h_\theta(x^{(i)}))\\
&= -\frac1m \sum_{i=1}^m \frac{\partial}{\partial \theta_j} \left( y^{(i)}log(h_\theta(x^{(i)})) \right) + \frac{\partial}{\partial \theta_j} \left( (1-y^{(i)})log(1-h_\theta(x^{(i)}))\right)\\
&= -\frac1m \sum_{i=1}^m y^{(i)} \frac{\partial}{\partial \theta_j} \left( log(h_\theta(x^{(i)})) \right) + (1-y^{(i)}) \frac{\partial}{\partial \theta_j} \left( log(1-h_\theta(x^{(i)}))\right)\\
&= -\frac1m \sum_{i=1}^m \frac{y^{(i)}}{h_\theta(x^{(i)}) } \frac{\partial}{\partial \theta_j} \left( h_\theta(x^{(i)}) \right) + \frac{(1-y^{(i)})}{1 - h_\theta(x^{(i)})} \frac{\partial}{\partial \theta_j}\left( 1-h_\theta(x^{(i)})\right)\\
&= -\frac1m \sum_{i=1}^m \frac{y^{(i)}}{h_\theta(x^{(i)}) } \frac{\partial}{\partial \theta_j} \left( h_\theta(x^{(i)}) \right) - \frac{(1-y^{(i)})}{1 - h_\theta(x^{(i)})} \frac{\partial}{\partial \theta_j}\left( h_\theta(x^{(i)})\right)\\
&= -\frac1m \sum_{i=1}^m \frac{\partial h_\theta(x^{(i)})}{\partial\theta_j} \left[ \frac{y^{(i)}}{h_\theta(x^{(i)})} - \frac{(1-y^{(i)})}{1 - h_\theta(x^{(i)})} \right]\\
&= -\frac1m \sum_{i=1}^m \frac{\partial h_\theta(x^{(i)})}{\partial\theta_j} \left[ \frac{y^{(i)}(1 - h_\theta(x^{(i)})) - h_\theta(x^{(i)})(1-y^{(i)})}{h_\theta(x^{(i)})(1 - h_\theta(x^{(i)}))} \right]\\
&= -\frac1m \sum_{i=1}^m \frac{\partial h_\theta(x^{(i)})}{\partial\theta_j} \left[ \frac{y^{(i)} - h_\theta(x^{(i)})}{h_\theta(x^{(i)})(1 - h_\theta(x^{(i)}))} \right]\\
&= \frac1m \sum_{i=1}^m \frac{\partial h_\theta(x^{(i)})}{\partial\theta_j} \left[ \frac{h_\theta(x^{(i)}) - y^{(i)}}{h_\theta(x^{(i)})(1 - h_\theta(x^{(i)}))} \right]\\
&= \frac1m \sum_{i=1}^m h_\theta(x^{(i)})^2 e^{-\theta^\intercal x} \left[ \frac{h_\theta(x^{(i)}) - y^{(i)}}{h_\theta(x^{(i)})(1 - h_\theta(x^{(i)}))} \right] x_j^{(i)}\\
&= \frac1m \sum_{i=1}^m \left[ \frac{h_\theta(x^{(i)})^2}{h_\theta(x^{(i)})(1 - h_\theta(x^{(i)}))} \right] e^{-\theta^\intercal x} (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)}\\
&= \frac1m \sum_{i=1}^m \left[ \frac{ \frac{1}{1+e^{-\theta^\intercal x}} }{1 - \frac{1}{1+e^{-\theta^\intercal x}}} \right] e^{-\theta^\intercal x} (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)}\\
&= \frac1m \sum_{i=1}^m \left[ \frac{ \frac{1}{1+e^{-\theta^\intercal x}} }{\frac{e^{-\theta^\intercal x}}{1+e^{-\theta^\intercal x}}} \right] e^{-\theta^\intercal x} (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)}\\
&= \frac1m \sum_{i=1}^m \frac{1}{e^{-\theta^\intercal x}} e^{-\theta^\intercal x} (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)}\\
&= \frac1m \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)}\\
\end{align*}
$$

Our updated gradient descent:
$$
\begin{align*}
& Repeat \; \lbrace \\
& \; \theta_j := \theta_j - \alpha \frac1m \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)}) x_j \\
& \rbrace
\end{align*}
$$
Vectorized gradient descent: `TODO Think about this`
$$
\theta := \theta - \frac{\alpha}{m} X^\intercal(g(X\theta) - \vec{y})
$$
This looks very similar to linear regression gradient descent! **What is the difference between the two, then?** The $h(\theta)$.

-  Linear Regression - $h_\theta(x)=\theta^\intercal x$
-  Logistic Regression - $h_\theta(x)= \frac{1}{1 + e^{-\theta^\intercal x}}$

One last note, feature scaling applies for logistic regression as well.

## Advanced Optimization

There are other ways to find $\theta$ that minimizes $J(\theta)$:

- Conjugate Gradient
- BFGS
- L-BFGS

These are more sophisticated algorithms compared to gradient descent, but usually runs faster than it and we do not need to pick a step size ($\alpha$).

For more details, check the slides/video.
