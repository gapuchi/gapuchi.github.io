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

1. Authorization CodeApplications
1. Implicit
1. Resource Owner Password Credentials
1. Client Credentials

The authorization grant type used depends on:

1. The method used by the application to request authorization.
1. The grant types supported by the service API.

#### Grant Type - Authorization Code

This grant type is optimized for *server-side applications*. The application must be able to receive HTTP requests from the *user-agent* (i.e. the user's web browser) because the service will redirect the user once authorization is granted.

1. Client is given an *authorization code link*: `https://discord.com/api/oauth2/authorize?response_type=code&client_id=123456789&permissions=8&redirect_uri=http%3A%2F%2Farjun.adhia.net&scope=bot`
    * `https://discord.com/api/oauth2/authorize` - Discord's API authorization endpoint
    * `client_id=123456789` - the *application*'s *client id*.
    * `redirect_uri=http%3A%2F%2Farjun.adhia.net` - The URI that the service redirects the user after an authorization code is granted.
    * `response_type=code` - Specifies that the application is requesting an authorization code grant.
    * `scope=bot` - specifies the level of access that the application is requesting. (For Discord, this is defined under [OAuth2 Scopes](https://discord.com/developers/docs/topics/oauth2#shared-resources-oauth2-scopes)).
1. Client authorizes the application - The user will click on the above link, and the service will ask the user to authorize or deny the application.
1. Client is redirected to the provided `redirect_url` once they authorize: `https://arjun.adhia.net/?code=987654321`
    * `code=987654321` - The authorization code provided by the service, as an argument to the redirect url.
1. Application requests access token - The application, requests a token with a `POST`: `https://discord.com/api/oauth2/token?client_id=1234567890&client_secret=3216549870&grant_type=authorization_code&code=098763421&redirect_uri=http%3A%2F%2Farjun.adhia.net&scope=bot`
    * `client_id=1234567890`
    * `client_secret=3216549870` - the client secret. The client secret can be held by the application because it is server-side and source code is hidden. If this was client side, anyone can see the secret.
    * `grant_type=authorization_code`
    * `code=098763421`
    * `redirect_uri=http%3A%2F%2Farjun.adhia.net`
    * `scope=bot`
1. The API will return a response with the access token (and potentially a refresh token, to get a new token when the returned one expires) - the application can now use this token when making calls to the service.

#### Grant Type - Implicit

This grant type is for mobile apps and web applications, where the client secret confidentaility is not guaranteed.

In this grant type, the user-agent gets the access token to give to the application. Because of this, the token is exposed to the user and potentially other applications on the user device.

This flow **does not authenticate the identity of the application**. It relies that the redirect URI is properly configured.

1. THe user is given an authorization link, to get a token from the service. This is similar to autorization code link except it **requests a token instead of a code**. (Check the reponse type in the url): `https://discord.com/api/oauth2/authorize?response_type=token&client_id=290926444748734499&state=15773059ghq9183habn&scope=identify`
1. Client authorizes the application - The user will click on the above link, and the service will ask the user to authorize or deny the application.
1. User-agent receives the redirect URI and the URL contains the access token: `https://arjun.adhia.net/?access_token=RTfP0OK99U3kbRtHOoKLmJbOn45PjL&token_type=Bearer&expires_in=604800&scope=identify&state=15773059ghq9183habn`.
1. User-agent gets redirected to the redirect URI.
1. The application returns a webpage that contains a script that can get the access token from the redirect URI.
1. User-agent gets the token and passes it to the application.

#### Grant Type - Resource Owner Password Credentials

The user provides their service credentials (like username and password) directly to the application, which uses the credentials to get the token from the service.

**This should only be used if the application is trusted by the user**.

1. The application requests a token via a `POST`. Ex: `https://oauth.example.com/token?grant_type=password&username=USERNAME&password=PASSWORD&client_id=CLIENT_ID`

(Discord doesn't have this grant type)

#### Grant Type - Client Credentials

This provides an application a way to access its own service account.

Examples of when this would be useful:

* An application wants to update its registered description or redirect URI
* Access other data stored in its service account via the API.

1. The application requests a token via a `POST` with its credentials, client id, and client secret:

```
'https://discord.com/api/oauth2/token'

auth = (CLIENT_ID, CLIENT_SECRET)
data = {
    'grant_type': 'client_credentials',
    'scope': 'identify connections'
}
headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
}
```

### Token Usage

Once an application has a token, it can use the token to access the user's account via the API.

`curl -X POST -H "Authorization: Bearer ACCESS_TOKEN""https://discord.com/api/users/@me"`.

### Refresh Token Flow

After an access token expires, API's will return an "Invalid Token Error". If a refresh toke was included when getting the original token was provided, the application can use it to request a new token.

Discord requires the following (for authorization code grant type, the other grant types do not have refresh token):

* client id
* client secret
* grant type
* refresh token
* redirect uri
* scope

```
'https://discord.com/api/oauth2/token'

data = {
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET,
    'grant_type': 'refresh_token',
    'refresh_token': refresh_token,
    'redirect_uri': REDIRECT_URI,
    'scope': 'identify email connections'
}
headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
}
```
