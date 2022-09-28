[TOC]

# Classification and Representation

## Classification

Here, $y$ is a discrete value
$$
y \in \{0,1\}
$$
$0$ is **negative class** and $1$ is **positive class**. This is a *two class problem.*

There is also multi-class problem:
$$
y \in \{0,1,2,3,4\}
$$
One thing we could try, we can take a similar approach to linear regression for logistic regression, specifically have the model $h_\theta(x)=\theta^\intercal x$:

* If $h_\theta(x) \geq 0.5$, predict $y=1$.
* If $h_\theta(x) < 0.5$, predict $y=0$.

It could work in some cases:
$$
\begin{bmatrix}
1 & 0\\
2 & 0\\
7 & 1\\
8 & 1\\
9 & 1\\
\end{bmatrix}
$$
but if we add an outlier, it may move the 0.5 so that $7$ is considered $0$. TODO add more details. So linear regression may have been lucky. Classification isn't a linear function. Not surprising since the hypothesis could ouput values above 1 or less than 0.

We'll talk about **logistic regression**: $0 \leq h_\theta(x) \leq 1$ (which is a classification algorithm).

## Hypothesis Representation

**What function will we use to rep our hypothesis for a classification problem?**

For linear regression, our model was $h_\theta(x) = \theta^\intercal x$.

For the **logistic regression**, we'll modify this to:
$$
\begin{align*}
h_\theta(x) &= g(\theta^\intercal x)\\
g(z) &= \frac{1}{1 + e^{-z}} \text{ where } z \in \R
\end{align*}
$$
$g(z)$ is called a **sigmoid function** or **logistic function** (the terms are interchangeable). This is why this regression is called **logistic regression**. The final hypothesis function then looks like:
$$
h_\theta(x) = \frac{1}{1 + e^{- \theta^\intercal x}}
$$
`TODO Include graph of logistic function`

**Why do we do this?** The logistic function has asymptotes at $0$ and $1$. That way, $0 \leq h_\theta(x) \leq 1$.

#### Interpretation of Hypothesis Output

- $h_\theta(x) = $ estimated probability that $y=1$ on input $x$.
- $h_\theta(x) = P(y=1|x;\theta)$
  - $P(y=1|x;\theta) + P(y=0|x;\theta) = 1$ since $y \in \{0,1\}$

## Decision Boundary

Given the interpretation:
$$
\begin{align*}
y=1 && \text{ if } && h_\theta(x) & \geq 0.5\\
&& && \frac{1}{1 + e^{- \theta^\intercal x}} & \geq 0.5\\
&& && 2 & \geq 1 + e^{- \theta^\intercal x}\\
&& && 1 & \geq e^{- \theta^\intercal x}\\
&& && ln(1) & \geq - \theta^\intercal x\\
&& && 0 & \geq - \theta^\intercal x\\
&& && \theta^\intercal x & \geq 0\\
\end{align*}
$$

$$
\begin{align*}
y=0 && \text{ if } && h_\theta(x) & < 0.5\\
&& && \frac{1}{1 + e^{- \theta^\intercal x}} & < 0.5\\
&& && 2 & < 1 + e^{- \theta^\intercal x}\\
&& && 1 & < e^{- \theta^\intercal x}\\
&& && ln(1) & < - \theta^\intercal x\\
&& && 0 & < - \theta^\intercal x\\
&& && \theta^\intercal x & < 0\\
\end{align*}
$$

Setting $y=1$ to include $0.5$ is arbitrary, it doesn't really matter how we interpret $0.5$ .

---

**Example**
$$
h_\theta(x) = g(\theta_0 + \theta_1 x_1 + \theta_2 x_2)\\
\theta = \begin{bmatrix}
-3\\
1\\
1\\
\end{bmatrix}
$$
Let's figure out when $y=1$ and $y=0$.
$$
\begin{align*}
y=1 && \text{ if } && \theta^\intercal x & \geq 0\\
&& && -3 + x_1 + x_2 & \geq 0\\
&& && x_1 + x_2 & \geq 3\\
\end{align*}
$$

$$
\begin{align*}
y=0 && \text{ if } && \theta^\intercal x & < 0\\
&& && -3 + x_1 + x_2 & < 0\\
&& && x_1 + x_2 & < 3\\
\end{align*}
$$

$x_1 + x_2 = 3$ is the **decision boundary**. On a graph, this is a line separating $y=1$ and $y=0$.

`TODO Include graph`

---

Decision boundary **is a property of the hypothesis, not a property of the dataset.**

- Looking at a training dataset, we cannot determine the decision boundary.
- Once we define the hypothesis, we can determine the decision boundary. Choosing the hypothesis often depends on the training dataset, but the actual decision boundary is determined from the hypothesis.
- We can choose whatever $\theta$, and then for whatever value we choose, we can find out the decision boundary.

Determining the $\theta$, and therefore our hypothesis, that best fits our training dataset is a separate task.

> **Another look at $\theta^\intercal x = 0$**
>
> $\theta^\intercal x = 0$ is the decision boundary. Another way to describe this is that the *dot product* of $\theta$ and $x$ is 0.
> $$
> \begin{align*}
> cos(\text{angle between } \theta \text{ and } x) &= \frac{\theta \cdot x}{|\theta| \cdot |x|}\\
> &= \frac{0}{|\theta| \cdot |x|}\\
> &= 0
> \end{align*}
> $$
> This means $\theta$ and $x$ are $\bot$.

#### Non-linear Decision Boundary

We've mentioned in linear regression that we can provide *polynomial regression*. We can do this in logistic regression as well.
$$
\begin{align*}
h_\theta(x) &= g(\theta_0 + \theta_1 x_1 + \theta_2 x_2 + \theta_3 x_1^2 + \theta_4 x_2^2)\\
\theta^\intercal &= \begin{bmatrix}-1 & 0 & 0 & 1 & 1\end{bmatrix}\\
y &= 1 \text{ if } -1 + x_1^2 + x_2^2 \geq 0\\
\text{decision boundary} &= -1 + x_1^2 + x_2^2 = 0\\
&= x_1^2 + x_2^2 = 1 \text{ (a unit circle)}
\end{align*}
$$
