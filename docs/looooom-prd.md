# loom - Self-Improving Website
## PRD + Technical Specification v1.0

**A focused product feedback board for collecting and prioritizing tickets**

**Date:** May 13, 2026<br>
**Status:** Ready for immediate AI implementation (Codex / Claude Code)

---

## System Prompt For The AI Coder

You are an expert senior Rails 8 developer and system architect. Your job is to build **loom** exactly as described in this document.

* Use **Rails 8**.
* Follow modern Rails conventions: Hotwire, Turbo, Stimulus, Tailwind CSS, Active Storage, Action Mailer, Sidekiq, and Rails-native defaults.
* Write clean, production-ready, well-tested code.
* Prioritize security, observability, and the self-improvement architecture from day one.
* After generating code, always explain what you built and what the next command should be.
* Never skip tests or security considerations.

Start by creating a new Rails 8 application and follow the exact phases and structure below.

---

## 1. Project Vision And Goals

### Vision

loom is a product feedback application that collects user tickets, lets users vote on the most important requests, and keeps the feedback board safe for work. Any self-improvement work happens outside the Rails app through Codex using the collected tickets as input.

### Primary Goal

Build the foundation so that within 8-12 weeks the system can:

* Accept user tickets and feature requests.
* Analyze usage data.
* Let external Codex runs inspect tickets and propose code changes outside the web app.
* Continuously optimize itself and discover monetization opportunities.

### Success Metrics For Phase 2+

* Clear ticket and vote data for prioritizing product work.
* External Codex runs can turn high-priority tickets into pull requests.
* No OpenAI, Anthropic, or GitHub API keys are required inside the Rails app.

---

## 2. Tech Stack

| Layer | Technology | Notes |
| --- | --- | --- |
| Backend | Ruby on Rails 8 | Use the current stable Rails 8 line available when generating the app. |
| Frontend | Hotwire (Turbo + Stimulus) + Tailwind CSS | Rails-native, fast, and simple to maintain. |
| Database | PostgreSQL | Hosted via Railway. |
| Cache / Queue | Redis + Sidekiq | Background work and cache support. |
| File Storage | Cloudflare R2 | S3-compatible via `aws-sdk-s3` and Active Storage. |
| Email | Cloudflare Email Service | Public beta. Use `cloudflare-email` for Action Mailer if it remains viable. |
| Payments | Stripe | Use `stripe-ruby` for subscriptions and one-time payments. |
| Auth | Devise + OmniAuth | Google OAuth only for user-facing login. |
| Deployment | Railway | Rails web process, worker process, Postgres, Redis. |
| AI Coding Agents | Codex CLI outside the app | Runs externally against tickets and repo context. |
| Monitoring | Railway logs, optional Sentry | Sentry is optional error monitoring. |
| Analytics | Built-in Postgres/Redis events, optional PostHog | Usage stats inform prioritization. |
| Version Control | Git + GitHub | Used by external Codex workflows, not by the Rails app. |

### Key Gems

```ruby
gem "devise"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "stripe"
gem "aws-sdk-s3"
gem "cloudflare-email"
gem "sidekiq"
gem "sentry-ruby"
gem "sentry-rails"
```

Implementation note: `cloudflare-email` is new and Cloudflare Email Service is beta. Verify the gem, API path, limits, pricing, and Railway compatibility again before shipping production mail.

Implementation note: first implementation uses shell commands for future git worktree operations instead of `rugged`; this avoids a native extension dependency until a stronger need appears.

---

## 3. Phased Roadmap

### Phase 1 - Foundation MVP

Core app, auth, Stripe, R2 uploads, tickets, basic analytics, Redis, and Sidekiq.

### Phase 2 - External Self-Improvement Loop

External Codex workflows analyze tickets and usage data, propose changes, run tests, and create pull requests. The Rails app does not store OpenAI, Anthropic, or GitHub API keys for this.

### Phase 3 - External Automation

External automation can inspect tickets, create pull requests, and help with implementation without adding AI API keys to the Rails app.

This document focuses on the Phase 1 and Phase 2 foundation so the system can begin self-improving quickly.

---

## 4. Core MVP Features

* User authentication through Google OAuth.
* Dashboard with usage stats.
* Ticket and feature request system.
* Voting on tickets.
* Local safe-for-work content guardrails for tickets.
* Stripe integration for free and paid tiers.
* File uploads to Cloudflare R2 via Active Storage.
* Email notifications via Cloudflare Email Service.
* Admin dashboard for ticket triage, moderation, user visibility, billing visibility, and usage signals.
* Basic analytics: feature usage, ticket volume, conversion events.

---

## 5. Self-Improvement Architecture

The system supports an external Evolution Loop:

1. Trigger: external Codex run, scheduled outside the Rails app, or manual developer run.
2. Analysis: Codex reads recent tickets, votes, and usage analytics.
3. Planning: Codex creates a bounded plan from tickets, user feedback, usage statistics, and repository context.
4. Execution: Codex works in a local worktree outside the web process.
5. Validation: Codex runs the full test suite and any relevant linters/security checks.
6. Output: Codex creates a GitHub pull request with a clear description of changes.
7. Later autonomy: auto-merge and Railway deploy when confidence is above the configured threshold and tests pass.

### Safety Mechanisms For MVP

* All AI changes go through pull requests first.
* Human approval is required before merge during the bootstrap phase, then can be removed once confidence thresholds and rollback automation are proven.
* AI actions happen outside the Rails runtime.
* Pull requests remain the audit trail.
* No production secret exposure in prompts, logs, pull request bodies, or model context.

---

## 6. Detailed Technical Requirements

### Models

* `User`
* `Ticket`: `title`, `description`, `status`, `priority`, `user_id`
* `Vote`: user_id, ticket_id
* `FeatureUsage`: user, event name, metadata, occurred_at
* `Subscription`: Stripe customer/subscription references and billing state

### Background Jobs

* `SendEmailJob`
* `SyncStripeJob`

### Initial Routes

* `/` -> landing page
* `/dashboard`
* `/admin` -> env-configured admin dashboard
* `/tickets`
* `/tickets/new`
* `/dashboard`

### Admin Dashboard Requirements

The admin dashboard is available only to the user whose email matches `ADMIN_EMAIL`. It must not be shown in navigation for normal signed-in users.

The dashboard should reflect the current product surface. Every new feature that adds a model, usage event, workflow, billing state, or moderation concern should also add an admin dashboard signal when that signal would help operate the product or prioritize work.

Current dashboard signals:

* User counts and recently joined users.
* Configured admin count for verifying `ADMIN_EMAIL`.
* Ticket totals, open work, status counts, priority counts, top-voted tickets, and recent tickets.
* Vote totals.
* Seven-day usage event volume and top usage events.
* Paid subscription count, subscription status counts, paid revenue, and recent payments.
* System test actions, beginning with an R2/Active Storage smoke test that writes, reads, and deletes a 1-byte file.

Future dashboard additions should prefer cheap Active Record aggregates from existing tables before adding an external analytics service. Add a dedicated reporting table only when raw queries become slow, hard to explain, or materially affect production request latency.

---

## 7. Environment Variables

```bash
SECRET_KEY_BASE=...
DATABASE_URL=...
REDIS_URL=...
STRIPE_SECRET_KEY=...
STRIPE_PUBLISHABLE_KEY=...
STRIPE_WEBHOOK_SECRET=...
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_BUCKET=...
CLOUDFLARE_ACCOUNT_ID=...
CLOUDFLARE_API_TOKEN=...
APP_HOST=looo0om.com
MAILER_FROM=hello@looo0om.com
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
ADMIN_EMAIL=...
ADMIN_NAME=loom Admin
SENTRY_DSN=...                         # Optional
SENTRY_TRACES_SAMPLE_RATE=0.1          # Optional
```

---

## 8. Initial Project Structure

```text
looooom/
├── app/
│   ├── controllers/
│   │   ├── tickets_controller.rb
│   │   └── dashboard_controller.rb
│   ├── jobs/
│   │   ├── send_email_job.rb
│   │   └── sync_stripe_job.rb
│   ├── models/
│   │   ├── ticket.rb
│   │   └── vote.rb
│   └── views/
├── config/
│   ├── initializers/
│   │   ├── cloudflare_email.rb
│   │   └── active_storage.rb
│   └── sidekiq.yml
├── lib/
├── docs/
│   ├── looooom-prd.md
│   └── codex-evolution-prompt.md
├── CLAUDE.md
├── AGENTS.md
├── Procfile
├── Dockerfile
└── ...
```

---

## 9. Implementation Instructions For Codex / Claude Code

1. Ensure Ruby 3.2.0 or newer is active.
2. Install Rails 8.
3. Create the app:

   ```bash
   rails new looooom --css=tailwind --database=postgresql
   cd looooom
   ```

4. Add the gems listed in section 2.
5. Configure `storage.yml` for Cloudflare R2.
6. Configure Action Mailer with `cloudflare-email` if still current, or document and use the best maintained Cloudflare Email Service integration available.
7. Set up Devise, OmniAuth, and the basic Ticket model/CRUD.
8. Add Sidekiq and Redis.
9. Add ticket voting and safe-for-work ticket validation.
10. Add `CLAUDE.md` at the app root with full project context.
11. Add the Railway `Procfile`.
12. Implement the full evolution loop in Phase 2.

---

## 10. Deployment On Railway

* Connect the GitHub repo to Railway.
* Add PostgreSQL and Redis services.
* Set all environment variables.
* Use this `Procfile`:

  ```Procfile
  web: bin/rails server -p ${PORT:-3000}
  worker: bundle exec sidekiq
  ```

* Enable zero-downtime deploys if available for the selected Railway plan/configuration.
* Add a custom domain later.

---

## 11. Next Steps After Foundation

Once Phase 1 is live:

* Run external Codex against ticket and vote data.
* Add better ticket triage and admin moderation tools.
* Add Stripe plans when the paid tier is ready.
* Add durable upload/email flows once R2 and Cloudflare Email are configured.

---

## Source Of Truth

This document is the product and technical source of truth until superseded by a newer PRD version.
