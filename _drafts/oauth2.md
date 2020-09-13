---
layout: post
title: "Learning OAuth2"
date: 2020-09-12
---

## The Driving Example

In my attempt to learn Rust (check out my notes [here](https://github.com/gapuchi/hello-rust)), I wanted to see if I can create a discord API wrapper in Rust.

I was able to create a new project, use an http crate, and make api calls. Cool! The next step was hitting Discord API's. This is when it got tricky.

Discord requires authentication (as it should) from clients that want to access it API's. It does this by supporting **OAuth2**.

Glancing over [Discord's documentation for OAuth2](https://discord.com/developers/docs/topics/oauth2), I saw terms such as *authorization url*, *token url*, *OAuth2 scopes*, *code grant*, etc - which made me realize I had no idea what I was doing.

I took a step back and decided to learn what OAuth2 was. I found a helpful article [on DigitalOcean](https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2) that broke it down in a helpful way.

## OAuth2

OAuth2 is an *authorization framework* that allows:

1. an application (my rust binary) to
1. access user accounts (my discord account)
1. on an HTTP service (i.e. Discord)

This allows any third party applications to access a users account for their own purposes. This could be an application that populates a calendar with your friend's birthdays by looking at Facebook. The application needs access to your Facebook account to do this, and it can't just sign in as you to achieve this.

### Roles

There are 4 OAuth roles:

|Role|Description|
|---|---|
|Resource Owner|The *user* who authorizes an application to access their account. (i.e. me)|
|Client| The *application* that wants to access a user's account. (i.e. my rust binary)|
|Resource Server| The server that hosts the user's account. (i.e. Discord)|
|Authorization Server| The server that verifies the user's id and issues access tokens to the application. (i.e. Discord)|

### High Level Flow of Authorization

1. The *application* requests the *user* authorization to access (some) service resources.
1. The *user* authorizes the request, and the *application* receives an authorization grant.
1. The *application* requests the *authorization server* an *access token* by showing authentication of its own identity (the application's, not the user's) and the authorization grant.
1. The *authorization server* issues an *access token* to the application.
1. The *application* requests the *resource server* some resources and presents the access token.
1. The *resource server* serves the resource to the *application*.

### Application Registration

Before an application can use OAuth2, it needs to register itself with the service. Services usually provide a registration form of some manner.

In Discord, this looks like [a developer portal](https://discord.com/developers/applications), where you can create a new application:

![Discord Application Screenshot](/assets/DiscordApplicationScreenShot.png)

#### Client ID and Client Secret

The service will issue *client credentials* in the form of

* *client id* - A publicly exposed string used by the service to identify the application
* *client secret* - A private string used to authenticate the application when requesting user resources to the service. This must kept private.

### Authorization Grant

There are 4 types of authorization grants defined by OAuth2:

|Grant Type|Description|
|---|---|
|Authorization Code|Used with server-side applications|
|Implicit|Used with mobile apps or web applications|
|Resource Owner Password Credentials||

1. Authorization Code - used with server-side Applications
1. Implicit - used with Mobile Apps or Web Applications (applications that run on the user’s device)
1. Resource Owner Password Credentials - used with trusted Applications, such as those owned by the service itself
1. Client Credentials - used with Applications API access

The authorization grant type used depends on:

1. The method used by the application to request authorization.
1. The grant types supported by the service API.

#### Grant Type - Authorization Code

This grant type is optimized for *server-side applications*. The source code is not publicly exposed so *client secret* can be maintained.
