# Content Deliver Network (CDN)

CDN
: Globally distributed network of proxy servers, serving content from locations closer to the user.

Usually serves static files like HTML/CSS/JS, photos, and videos. Some CDNs (like Amazon CloudFront) serve dynamic content.

Benefits

- User receives content from data centers close to them
- Servers do not have to serve requests that CDN can fulfill

## Push CDNs

Push CDNs
: CDNs that receive new content when changes occur on your server.

You have to update content on the CDN. It is only updated when data is new or changed. This means traffic is low, but storage is high. Content is placed on CDNs once, instead of being pulled regularly.

Sites with small amount of traffic or sites with really static content works well with this.

## Pull CDNs

Pull CDNs
: CDNs that grab new content from your server when the first user requests the content.

Slower request until the content is cached on the CDN.

A TTL determines how long content is cached. This minimizes storage, but can add redundant traffic if files expire when they haven't changed.

Sites with heavy traffic work well with this. Traffic is spread out more evenly with recently-requested content on the CDN.