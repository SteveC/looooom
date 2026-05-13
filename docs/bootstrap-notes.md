# Bootstrap Notes

## Current Local State

* Repository path: `/Users/steve/looooom`
* Git remote: `git@github.com:SteveC/looooom.git`
* Homebrew Ruby used for the app: `ruby 4.0.3`
* Rails version: `8.1.3`
* App location: repository root
* PostgreSQL was available locally and `bin/rails db:prepare` succeeded.

The macOS system Ruby is still `2.6.10`, so local commands should prepend the Homebrew Ruby paths shown below.

## Local Command Prefix

```bash
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"
```

## Bootstrap Performed

```bash
gem install rails -v 8.1.3
rails new /tmp/looooom --css=tailwind --database=postgresql --skip-git
rsync generated Rails files into /Users/steve/looooom
bundle add devise stripe aws-sdk-s3 cloudflare-email sidekiq sentry-ruby sentry-rails omniauth omniauth-google-oauth2
```

`rugged` was intentionally not added because it required CMake/native extension setup and shelling out to `git` in isolated worktrees is simpler for the first evolution runner.

## First Rails Milestone Status

1. Rails 8 app generated with PostgreSQL and Tailwind.
2. Devise, Google OmniAuth hooks, Stripe, Sidekiq, optional Sentry, R2 storage, and Cloudflare Email Service wiring added.
3. `Ticket`, `Vote`, `FeatureUsage`, and `Subscription` models created.
4. Landing page, dashboard, ticket CRUD, voting, and local content guardrails added.
6. `bin/ci` passes.
