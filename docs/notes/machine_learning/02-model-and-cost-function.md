---
part: 2
---

# Model and Cost Function

## Model Representation

In supervised learning, we have a dataset - called **training dataset**.

We feed our training set to a **learning algorithm** which will then output a function - called `h` , our **hypothesis** function. `h` then can take in `x` and output `y`.

**Some Notation**

$$
\begin{align*}
x^{(i)} &&& \text{Input variable/feature where }i\text{ is the index} \\
y^{(i)} &&& \text{Ouput/Target variable/feature }i\text{ is the index} \\
(x^{(i)}, y^{(i)}) &&& \text{Training example}\\
(x^{(i)}, y^{(i)}); i = 1, \ldots,m &&& \text{Training set}\\
X &&& \text{Space of input values}\\
Y &&& \text{Space of output values}\\
\end{align*}
$$

For *supervised learning*, our goal is to learn a function $h:X \rightarrow Y$ so that $h(x)$ is a good predictor for the corresponding value of $y$. `h` is the **hypothesis**.

How do we represent `h`?

$$
\begin{align*}
h_\theta(x) &= \theta_0 + \theta_1x\\
h(x) && \text{Shorthand}\\
\end{align*}
$$

The above is a **linear regression with one variable** or **univariate linear regression**.

## Cost Function

Let's say we have a training set and a hypothesis of $h_\theta(x) = \theta_0+\theta_1x$. The $\theta_i$'s are **parameters**. With various values of $\theta_i$'s, we will get various hypothesis.

> **Reminder** - this is a regression problem. We cannot do this classification problems.

$$
\begin{align*}
\theta_0&=1.5 & \theta_1&=0\\
\theta_0&=0 & \theta_1&=0.5\\
\theta_0&=1 & \theta_1&=0.5\\
\end{align*}
$$

We want to come up with the values for these parameters so that $h_\theta(x)$ is as close to $y$ for our training examples $(x,y)$. This is a **minimization problem**. We want to find $\theta_0$ and \theta_1$ to minimize:

$$
\frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
$$

By convention, we redefine our problem to minimize a **cost function**:

$$
J(\theta_0,\theta_1) = \frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
\min_{\theta_0\theta_1} J(\theta_0,\theta_1)\\
$$

To break this down:

$$
\begin{align*}
J(\theta_0,\theta_1) &= \frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
&= \frac{1}{2}\frac{1}{m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
&= \frac{1}{2}\frac{1}{m}\sum^m_{i=1}(\text{difference between predicted and actual})^2\\
&= \frac{1}{2}\frac{1}{m}\sum^m_{i=1}(\text{error})^2\\
&= \frac{1}{2}\frac{1}{m}(\text{sum of error squared})\\
&= \frac{1}{2}(\text{mean of error squared})\\
&= \frac{1}{2}\bar{x} & \bar{x}\text{ is the mean of the squares of errors}\\
\end{align*}
$$

This cost function is called the **squared error function** or **mean squared error**. The $\frac{1}{2}$ is there to simplify the calculus. The squared and one half cancels out. It probably the most commonly used cost function. It should be a pretty reasonable thing to try for linear regression.

To summarize:

$$
\begin{align*}
\text{Hypothesis} &&& h_\theta(x)=\theta_0+\theta_1x\\
\text{Parameteres} &&& \theta_0,\theta_1\\
\text{Cost Function} &&& J(\theta_0,\theta_1) = \frac{1}{2m}\sum^m_{i=1}(h_\theta(x^{(i)}) - y^{(i)})^2\\
\text{Goal} &&& \min_{\theta_0,\theta_1} J(\theta_0,\theta_1)
\end{align*}
$$

Let's take a closer look at the *cost function* $J(\theta_0,\theta_1)$ and the *hypothesis function* $h_\theta(x)$.

* $h_\theta(x)$ - For fixed $\theta_0,\theta_1$, this is a function of $x$.
* $J(\theta_0,\theta_1)$ - function of the parameters $\theta_0,\theta_1$.

We want to minimize the cost function. It is important to note that this is a linear regression so $h_\theta(x)$ and $J(\theta_0,\theta_1)$ are *continuous functions*.