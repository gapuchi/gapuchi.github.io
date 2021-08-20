# Kubernetes API

This API is a RESTful programmatic interface provided via HTTP.

## API Terminology

* Resource type - the name used in the URL
* Kind - the object schema, the representation in JSON
* Collection - A list of instances of a resource type
* Resource - A single instance of the resource type

The resource types are scoped by either:

 * cluster - `/apis/GROUP/VERSION/*`
 * namespace - `/apis/GROUP/VERSION/namespaces/NAMESPACE/*`

 Retrieving collections and resources look like:

* Cluster-scoped resources
  * `GET /apis/GROUP/VERSION/RESOURCETYPE` - return the collection of resources of the resource type
  * `GET /apis/GROUP/VERSION/RESOURCETYPE/NAME` - return the resource with NAME under the resource type
* Namespace-scoped resources
  * `GET /apis/GROUP/VERSION/RESOURCETYPE` - return the collection of all instances of the resource type across all namespaces
  * `GET /apis/GROUP/VERSION/namespaces/NAMESPACE/RESOURCETYPE` - return collection of all instances of the resource type in NAMESPACE
  * `GET /apis/GROUP/VERSION/namespaces/NAMESPACE/RESOURCETYPE/NAME` - return the instance of the resource type with NAME in NAMESPACE

  ```
  TODO HTTP Codes, Error, etc.
  ```