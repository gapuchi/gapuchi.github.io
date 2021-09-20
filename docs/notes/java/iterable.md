# Iterable, Iterator

Iterable
: Something that can generate an **iterator**

Iterator
: Something that be iterated.

 The Spliterator API was designed to support efficient parallel traversal in addition to sequential traversal, by supporting decomposition as well as single-element iteration. In addition, the protocol for accessing elements via a Spliterator is designed to impose smaller per-element overhead than Iterator, and to avoid the inherent race involved in having separate methods for hasNext() and next().

For mutable sources, arbitrary and non-deterministic behavior may occur if the source is structurally interfered with (elements added, replaced, or removed) between the time that the Spliterator binds to its data source and the end of traversal. For example, such interference will produce arbitrary, non-deterministic results when using the java.util.stream framework.

