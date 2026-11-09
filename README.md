# Deploy and Host Terminal on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/terminal?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=terminal)

Terminal is a browser shell that runs inside your Railway project's private network. Add it to a project that already has Postgres, MySQL, Redis or MongoDB, open its domain, and you have `psql`, `mysql`, `redis-cli`, `mongosh`, the dump tools and the Railway CLI right next to your data. Nothing gets a public TCP proxy, and traffic over the private network doesn't count as egress.

## About Hosting Terminal

One service and a small volume for your home directory. A `ttyd` web terminal behind basic auth drops you into a `tmux` session, so a long `pg_dump` or migration keeps running when you close the tab. The `db` command finds the databases in the project and opens the right client:

```
$ db
   1  postgres Postgres/DATABASE_URL  postgresql://postgres:•••@postgres.railway.internal:5432/railway
   2  redis    Redis/REDIS_URL        redis://default:•••@redis.railway.internal:6379

$ db 1            # psql on Postgres
$ db dump 1       # pg_dump -Fc into ~/dumps
```

## Common Use Cases

- Query a project's Postgres, MySQL, Redis or MongoDB from the browser, without a public TCP proxy
- Take a dump before a risky migration, or restore one into a new database
- Run a one-off script or migration against a private service
- Debug service-to-service traffic: `dig`, `curl` and `nc` against `*.railway.internal`
- Use the Railway CLI from a phone or a locked-down laptop

## Dependencies for Terminal Hosting

- None of its own. It's meant to be added to an existing project, next to the services you want to reach.

### Deployment Dependencies

- [ttyd](https://github.com/tsl0922/ttyd) web terminal
- PostgreSQL 18 client tools (they dump older servers too), MySQL 8 client, `redis-cli`, `mongosh` and the MongoDB database tools
- [Railway CLI](https://docs.railway.com/guides/cli)

### Implementation Details

**Add it to your project:** open the project, press the **+** button (or `Cmd/Ctrl+K`), pick **Template** and search for "Terminal". Deploying the template from the marketplace page instead creates a new, empty project.

**Log in:** open the service's domain and sign in with `WEB_USER` and the generated `WEB_PASSWORD` (Variables tab).

**Point it at your databases**, in one of two ways:

- Add reference variables to the terminal service, for example `DATABASE_URL=${{Postgres.DATABASE_URL}}` or `REDIS_URL=${{Redis.REDIS_URL}}`. Any variable holding a `postgres://`, `mysql://`, `redis://` or `mongodb://` URL shows up in `db`.
- Or set `RAILWAY_TOKEN` to a project token (Project Settings → Tokens). `db` then lists the connection URLs of every service in the environment, and the `railway` CLI works without `railway login`.

**Handy commands:**

- `db`, `db N`, `db dump N`, `db url N`
- `pg_restore -d "$DATABASE_URL" --no-owner ~/dumps/<file>.dump`
- `dig AAAA api.railway.internal`, `nc -zv api.railway.internal 8080`

Notes and limits:

- Anyone with the password can reach every database the shell can. Keep `WEB_PASSWORD` strong. If it's empty, the domain shows a notice instead of the terminal.
- You're root. `apt install` works, but only `/root` survives a redeploy.
- Big dumps need disk: grow the volume first, or stream them elsewhere.

## Why Deploy Terminal on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Terminal on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
