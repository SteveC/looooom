# Environment Setup

This repository is public, so production secrets are env-only. Do not use Rails encrypted credentials for deploy secrets, and do not commit generated keys.

## Required For Production Boot

```bash
SECRET_KEY_BASE=...
DATABASE_URL=...
REDIS_URL=...
APP_HOST=looooom.com
MAILER_FROM=hello@looooom.com
```

Generate `SECRET_KEY_BASE` locally:

```bash
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH" bin/rails secret
```

## Feature Variables

```bash
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=

R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET=
R2_ACCOUNT_ID=

CLOUDFLARE_ACCOUNT_ID=
CLOUDFLARE_API_TOKEN=

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
ADMIN_EMAIL=
ADMIN_PASSWORD=
ADMIN_NAME=loom Admin

SENTRY_DSN=
SENTRY_TRACES_SAMPLE_RATE=0.1
```

`SENTRY_DSN` is optional. Sentry is external error monitoring: it records production exceptions and performance traces so you can see what broke after deploys. The app boots without it.

## Services

Set up these external services as needed:

* Railway app connected to `SteveC/looooom`
* Railway PostgreSQL
* Railway Redis
* Cloudflare R2 for durable Active Storage uploads. Without R2 vars, production boots with local storage.
* Cloudflare Email Service for outbound mail
* Stripe for billing
* Sentry for optional error monitoring
* Google OAuth app if social login is enabled

## Not Needed In The Rails App

The self-improvement workflow runs outside this Rails app in Codex. The website only collects tickets and votes. It does not need `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or a GitHub API token.

GitHub is still useful outside the app because the repository lives there and Railway can deploy from it. Codex can also use GitHub externally when it later turns tickets into branches or pull requests, but no GitHub secrets are required in the Rails runtime.
