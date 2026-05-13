# EvoSite Context

EvoSite is a Rails 8 self-improving website. The core product loop is:

1. Users submit tickets and feature requests.
2. The app records usage analytics and operational signals.
3. Evolution jobs build prompts from tickets, usage, history, and repository context.
4. AI coding agents use those prompts to create tested pull requests.

Current implementation status:

* Rails 8.1.3 app at repository root.
* Devise auth with Google/GitHub OmniAuth hooks.
* Ticket CRUD for signed-in users.
* Feature usage events stored in Postgres.
* Evolution logs stored in Postgres.
* `EvolutionAnalysisJob` currently generates and stores prompts only. It intentionally does not shell out to Codex or Claude until the runner isolation and command allowlist are implemented.
* Sidekiq is configured for Redis-backed background jobs.
* Cloudflare R2, Cloudflare Email Service, Stripe, and Sentry are configured through environment variables.

Important guardrails:

* Do not commit secrets or generated local keys.
* Keep AI-generated changes behind pull requests until confidence gates are implemented.
* Prefer simple Rails conventions over custom infrastructure.
* Avoid native dependencies for git operations unless there is a strong reason; shelling out to `git` in isolated worktrees is the current default.
