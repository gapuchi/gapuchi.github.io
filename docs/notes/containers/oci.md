# Open Contianer Initiative (OCI)

https://opencontainers.org/

> The mission of the Open Container Initiative (OCI) is to promote a set of common, minimal, open standards and specifications around container technology.

OCI is an open governance structure (i.e. project) to create open industry standards around container formats and runtime.

OCI contains two specifications:

1. Runtime Specification (runtime-spec)
1. Image Specification (image-spec)

Runtime Specification outlines how to run a "filesystem bundle" that is unpacked on a disk. High level, an OCI implementation would download an OCI image and unpack it into an OCI Runtime filesystem bundle. This would then be run by an OCI Runtime.

This workflow should provide the ability to run an image with no additional arguments (a common expectation from users of container engines like Docker and rkt)

```
docker run example.com/org/app:v1.0.0
rkt run example.com/org/app,version=v1.0.0
```

In order to do this, the OCI Image Format contains the needed info to launch the application on the target platform. This includes arguments, command, env variables, etc. The specification defines how to create an OCI Image.

The creation of the image is usually done by a build system and outputs:

* image manifest - contains metadata about the contents and dependencies of the image. Including the content-addressable (TODO - define this) identity of one or more filesystem serialization archives that will be unpacked to make up the final funnable filesystem. (TODO - explain all of this)
* filesystem (layer) serialization - TODO
* image configuration - includes info such as app arguments, environments, etc.

```
TODO Link all the terms above.
```

## Image Spec

Ref: https://github.com/opencontainers/image-spec

[OCI Image Specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)