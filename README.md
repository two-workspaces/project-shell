# Deploy and Host Terminal on Railway

Terminal is a browser shell that runs inside your Railway project's private network. Add it next to your databases and services to inspect data, run migrations and one-off jobs, or debug a service over its private domain, without exposing anything to the internet.

This template is being built and isn't ready to deploy yet.

## About Hosting Terminal

It ships the clients you reach for when something in a project needs a look: psql, mysql, redis-cli, mongosh and the Railway CLI. The browser terminal is password protected, and it reaches other services over Railway's private network.

## Common Use Cases

- Query a project's Postgres, MySQL, Redis or MongoDB from the browser
- Run a migration or a one-off script against a private service
- Debug a service over its private domain

## Dependencies for Terminal Hosting

- None. It's a single service added to an existing project.

### Deployment Dependencies

- ttyd (browser terminal), the database clients and the Railway CLI

## Why Deploy Terminal on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Terminal on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
