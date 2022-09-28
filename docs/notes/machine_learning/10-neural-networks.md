[TOC]

# Neural Networks

## Motivations

### Non-Linear Hypothesis

Let's say we have a non-linear classification problem. We have previously defined a way to represent this with logistic regression by combining terms. E.g. If we have $x_1$ and $x_2$, we can introduce higher polynomial terms but computing new features to be $x_1 x_2$, $x_1^2$, $x_1^2 x_2$, etc. Our hypothesis would look something like:

$$
h_\theta(x) = g(\theta_0 + \theta_1 x_1 + \theta_2 x_2 + \theta_3 x_1 x_2 + \theta_4 x_1^2 + \dots )
$$

This is fine for small number of features. **What happens if the number of features are large?** Let's say $n=100$. If we wanted to include all the quadratic terms, we have to combine all the $x_i$'s. This would result the features $x_1 x_2, x_1, x_3, \ldots, x_1 x_{100}, x_2 x_3, \dots$. ${100 \choose 2} = 4950$, meaning we'd have almost 5K features! If we includes cubic terms, this get's even more ridiculously big. This makes our computations way more complex.

We could limit the types of combinations we would include, but that would limit our possible hypotheses. **This approach doesn't seem to be a good when there are a lot of features**.

> **Example Where n is Large - Computer Vision**
>
> In computer vision, our input is a picture and our output could be some classification of the picture. The input is specifically represented as an array of numbers, each of which is a pixel. This means that for a 50x50 picture, we have 2500 features. (If this was in RBG, each pixel would be 3 numbers and the number of features would be 7500).
>
> Sure, the number of features are large, but is it a non-linear hypothesis? It's a bit difficult to imagine, but for picture recognition, it is unlikely that a linear relationship exists between pixels to distinguish certain objects.

### Neurons and the Brain

Neural networks mimics how the brain learns.

* It was used widely in the 80's and 90's, after which it kinda saw a decrease.
* There has been a recent resurgence - especially with the progression of computers being able to handle the computational complexity that neural networks required.

#### The "One Learning Algorithm" Hypothesis

There was an experiment that rewired the auditory cortex, which received signals from the ears and interprets sound, to be connected to the eyes instead. The auditor cortex learned to see. This suggests that the brain is compartmentalized by specific learning algorithms - we think that the brain has a single learning algorithm. Any part of the brain could

## Model Representations

### Neuron Model: A Logistic Unit

A neuron is a unit of computation that takes inputs and then produces an output. In neural networks, we use the same logistic function as classification, and we call it a **sigmoid (logistic) activation function**.

`TODO - Include Diagram`

The diagram of a single neuron can be expressed as $[x_0 x_1 x_2] \rarr [\dots] \rarr h_\theta(x)$.

#### Neural Network

A **neural network** is a group of different neurons strung together. An example:

$$
[x_0 x_1 x_2] \rarr [a_1^{(2)} a_2^{(2)} a_3^{(2)}] \rarr h_\Theta(x)
$$

|Term|Description|
|---|---|
|$[x_0 x_1 x_2]$|Layer 1, or **input layer**|
|$[x_0 x_1 x_2]$|Layer 2, a **hidden layer**|
|$h_\Theta(x)$|Layer 3, or **output layer**|

Some notation:

$$
\begin{align*}
& a_i^{(j)} = \text{"activation" of unit $i$ in layer $j$} \newline
& \Theta^{(j)} = \text{matrix of weights controlling function mapping from layer $j$ to layer $j+1$}\end{align*}
$$

"Activation" essentially means the value that is computed and outputted by the neuron.

Given this notation, we can calcualte the values of the activation nodes as:

$$
\begin{align*}
a_1^{(2)} &= g(\Theta_{10}^{(1)}x_0 + \Theta_{11}^{(1)}x_1 + \Theta_{12}^{(1)}x_2 + \Theta_{13}^{(1)}x_3) \newline
a_2^{(2)} &= g(\Theta_{20}^{(1)}x_0 + \Theta_{21}^{(1)}x_1 + \Theta_{22}^{(1)}x_2 + \Theta_{23}^{(1)}x_3) \newline
a_3^{(2)} &= g(\Theta_{30}^{(1)}x_0 + \Theta_{31}^{(1)}x_1 + \Theta_{32}^{(1)}x_2 + \Theta_{33}^{(1)}x_3) \newline
h_\Theta(x) = a_1^{(3)} &= g(\Theta_{10}^{(2)}a_0^{(2)} + \Theta_{11}^{(2)}a_1^{(2)} + \Theta_{12}^{(2)}a_2^{(2)} + \Theta_{13}^{(2)}a_3^{(2)}) \newline
\end{align*}
$$

Each layer has its own matrix of weights - $\Theta^{(j)}$.

> If network has $s_j$ units in layer $j$ and $s_{j+1}$ units in layer $j+1$, then $\Theta^{(j)}$ will be of dimension $s_{j+1} \times (s_j + 1)$.
> Why add 1 to $s_j$? That is the **bias unit** ($x_0 = 1$). This gets added to every layer. It may or may not be shown in the diagrams.

So in the above example, $\Theta^{(1)} \in \R^{3 \times 4}$. Layer 1 has 3 units and layer has 3 units, hence 3 by 4.

> For a $\Theta$, each row represents the next layers activation and each column represents the current layer's activation.

#### Vectorized Representation

We currently have this representation:

$$
\begin{align*}
a_1^{(2)} &= g(\Theta_{10}^{(1)}x_0 + \Theta_{11}^{(1)}x_1 + \Theta_{12}^{(1)}x_2 + \Theta_{13}^{(1)}x_3) \newline
a_2^{(2)} &= g(\Theta_{20}^{(1)}x_0 + \Theta_{21}^{(1)}x_1 + \Theta_{22}^{(1)}x_2 + \Theta_{23}^{(1)}x_3) \newline
a_3^{(2)} &= g(\Theta_{30}^{(1)}x_0 + \Theta_{31}^{(1)}x_1 + \Theta_{32}^{(1)}x_2 + \Theta_{33}^{(1)}x_3) \newline
h_\Theta(x) = a_1^{(3)} &= g(\Theta_{10}^{(2)}a_0^{(2)} + \Theta_{11}^{(2)}a_1^{(2)} + \Theta_{12}^{(2)}a_2^{(2)} + \Theta_{13}^{(2)}a_3^{(2)}) \newline
\end{align*}
$$

Let's refactor it (calculating layer 2 as the example):

$$
\begin{align*}
z_k^{(2)} &= \Theta_{k,0}^{(1)} x_0 +  \Theta_{k,1}^{(1)} x_1 + \dots +  \Theta_{k,n}^{(1)} x_n \newline
a_1^{(2)} &= g(z_1^{(2)}) \newline
a_2^{(2)} &= g(z_2^{(2)}) \newline
a_3^{(2)} &= g(z_3^{(2)}) \newline
\end{align*}
$$

We can vaguely see all the values of $\Theta$ in the system of equations to be a matrix operation: $\Theta^{(1)}x$. Let's say $x = a^{(1)}$. Then we can say:

$$
\begin{align*}
x = \begin{bmatrix}
x_0 \newline
x_1 \newline
\vdots \newline
x_n
\end{bmatrix}
&z^{(j)} = \begin{bmatrix}
z_1^{(j)} \newline
z_2^{(j)} \newline
\vdots \newline
z_n^{(j)}
\end{bmatrix}
\end{align*}
$$

which we then can generalize:

$$
\begin{align*}
z^{(j)} &= \Theta^{(j-1)}a^{(j-1)} \\
a^{(j)} &= g(z^{(j)}) &\text{$g$ is an element-wise operation.}
\end{align*}
$$

`TODO - Organize the flow of this`

The above operation is used to calculate every layer, **even the output layer**. The output layer will produce an array of a single element.

The process of computing $h(x)$ is called **forward propagation**.

## Intuition - Neural Networks Learns Its Own Features

If we only look at the llast 2 layers (ignore the other layers), we have:
$$
h_\theta(x) = g(\Theta_{10}^{(2)}a_0^{(2)} + \Theta_{11}^{(2)}a_1^{(2)} + \Theta_{12}^{(2)}a_2^{(2)} + \Theta_{13}^{(2)}a_0^{(3)}
$$
**This is essentially logistic regression with features $a$!**

The feature $a$ is computed from another set of features ($x$).

Essentially, neural networks takes input features, use those to learn its own features, and uses that to get the hypothesis.

Neural networks isn't contrained by the input features or polynomial features. It can learn whatever features it wants.

## Application 

