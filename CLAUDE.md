# loom Context

loom is a Rails 8 self-improving website. The core product loop is:

1. Users submit tickets and feature requests.
2. The app records usage analytics and operational signals.
3. External Codex workflows can inspect tickets and usage data from outside the app.

Current implementation status:

* Rails 8.1.3 app at repository root.
* Devise auth with Google OmniAuth hooks.
* Ticket CRUD for signed-in users.
* Ticket voting for signed-in users.
* Local safe-for-work ticket validation.
* Feature usage events stored in Postgres.
* Sidekiq is configured for Redis-backed background jobs.
* Cloudflare R2, Cloudflare Email Service, Stripe, and optional Sentry are configured through environment variables.

Important guardrails:

* Do not commit secrets or generated local keys.
* Keep self-improvement work outside the Rails app. External Codex runs can read tickets and make pull requests.
* Prefer simple Rails conventions over custom infrastructure.
* Avoid native dependencies for git operations unless there is a strong reason; shelling out to `git` in isolated worktrees is the current default.
