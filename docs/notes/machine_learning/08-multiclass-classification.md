[TOC]

# 8 Multiclass Classification

**Multiclassification** - $y \in \{0,1,2,3,4\}$. It is not only a boolean classification. E.g. does a patient have a malignant tumor is a binomial classification (yes or no).

`TODO - Include graphs`

## One Versus All

We assign $y=1$ for one specific class and $y=0$ for the remaining class and then do normal logistic regression. We would then have as many logistic regression models as we do have classes.

> $$
> h_\theta^{(i)}(x) = P(y=i|x;\theta) \quad (i=1,2,3,4,\ldots,n)
> $$
>
> Train a logistic regression classifier $h_\theta^{(i)}(x)$ for each class $i$ to predict the probability that $y=i$.
>
> On a new input $x$, to make a prediction, pick the class $i$ that $\max_i h_\theta^{(i)}(x)$.