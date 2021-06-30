---
part: 1
---

# Introduction

## What is Machine Learning?

> Field of study that gives computers the ability to learn without being explicitly programmed

> **Learning Problem** - A computer program is said to *learn* from experience E with respect to some task T and some performance P if P improves with E.

The 2 most broad classification of machine learning algorithms:

1. Supervised Learning
2. Unsupervised Learning

## Supervised Learning

In this type of learning, we provide the *right answers*, and the computer will learn to try to give more right answers.

> Ex - Predict the cost of a house based on the square footage
>
> This is a **regression problem** - predicting continuous valued output (i.e. the price). If we were to perform a supervised learning, we would provide a sample of house prices and its square footage.\

> Ex - See if breast cancer is malignant based on the tumor size
>
> This is a **classification problem** - we are trying to determine a discrete valued output (e.g yes or no, 1 or 2 or 3, etc). We are trying to see if the person has a malignant tumor or not.

## Unsupervised Learning

In this type of learning, we provide data without the answers. In supervised learning, we may provide yes and no, or some sort of answers, but in this, the data we provide is unlabelled.

> "Here is some data, can you find some structure in the data?"

This learning may recognize, for example, that our data has two main clusters. This is a **clustering algorithm**.

> Ex - Google News Stories
>
> Google news will cluster together various articles about the same topic. It may find a CNN article MSNBC video, Fox News article all about global warming bill passing in congress.

### Another classification - Cocktail Party Algorithm

Two speakers at the party, and two microphones. Both microphones pick up both speakers, but each microphone is closer to one of the speakers.

The algorithm will listen to both mics and separate out the two audio sources.