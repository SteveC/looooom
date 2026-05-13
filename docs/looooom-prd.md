# loom - Self-Improving Website
## PRD + Technical Specification v1.0

**A website that starts simple and evolves itself biologically**

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

loom is a living web application that begins with core functionality and then autonomously improves itself based on real user behavior, explicit feature requests, and usage analytics, with no humans required in the loop after the initial bootstrap.

### Primary Goal

Build the foundation so that within 8-12 weeks the system can:

* Accept user tickets and feature requests.
* Analyze usage data.
* Write, test, and deploy code changes autonomously, initially via pull requests and later fully automatic.
* Continuously optimize itself and discover monetization opportunities.

### Success Metrics For Phase 2+

* Ticket-to-deployed-feature time under 4 hours with human review initially.
* More than 60% of new code changes authored by AI agents.
* Clear evolution log showing compounding improvements.

---

## 2. Tech Stack

| Layer | Technology | Notes |
| --- | --- | --- |
| Backend | Ruby on Rails 8 | Use the current stable Rails 8 line available when generating the app. |
| Frontend | Hotwire (Turbo + Stimulus) + Tailwind CSS | Rails-native, fast, and simple to maintain. |
| Database | PostgreSQL | Hosted via Railway. |
| Cache / Queue | Redis + Sidekiq | Critical for evolution jobs and background work. |
| File Storage | Cloudflare R2 | S3-compatible via `aws-sdk-s3` and Active Storage. |
| Email | Cloudflare Email Service | Public beta. Use `cloudflare-email` for Action Mailer if it remains viable. |
| Payments | Stripe | Use `stripe-ruby` for subscriptions and one-time payments. |
| Auth | Devise + OmniAuth | Google and GitHub OAuth. |
| Deployment | Railway | Rails web process, worker process, Postgres, Redis. |
| AI Coding Agents | Claude Code CLI + Codex CLI | Triggered by Sidekiq jobs in controlled worktrees. |
| Monitoring | Sentry, Railway logs, custom telemetry | AI reads errors to propose fixes. |
| Analytics | Built-in Postgres/Redis events, optional PostHog | Usage stats feed the evolution loop. |
| Version Control | Git + GitHub | AI creates branches and pull requests. |

### Key Gems

```ruby
gem "devise"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-github"
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

### Phase 2 - Self-Improvement Loop

Background jobs trigger Claude Code and Codex CLI to analyze tickets and usage data, propose changes, run tests, and create pull requests.

### Phase 3 - Autonomous Evolution

Multi-agent system, auto-deployment after confidence thresholds, monetization optimizer, and self-improving prompts/skills.

This document focuses on the Phase 1 and Phase 2 foundation so the system can begin self-improving quickly.

---

## 4. Core MVP Features

* User authentication: signup, login, Google OAuth, GitHub OAuth.
* Dashboard with usage stats.
* Ticket and feature request system.
* Stripe integration for free and paid tiers.
* File uploads to Cloudflare R2 via Active Storage.
* Email notifications via Cloudflare Email Service.
* Admin dashboard showing tickets and evolution history.
* Basic analytics: feature usage, ticket volume, conversion events.

---

## 5. Self-Improvement Architecture

The system has a dedicated Evolution Loop:

1. Trigger: new ticket created, nightly cron, or manual "Evolve Now" action.
2. Analysis: `EvolutionAnalysisJob` collects recent tickets and usage analytics from Postgres and Redis.
3. Planning: the job creates a rich prompt containing the current codebase summary, recent tickets, user feedback, usage statistics, previous evolution history, environment constraints, and allowed actions.
4. Execution: Sidekiq shells out to `claude` or `codex` CLI in a controlled worktree or container.
5. Validation: the agent runs the full test suite and any relevant linters/security checks.
6. Output: the agent creates a GitHub pull request with a clear description of changes.
7. Later autonomy: auto-merge and Railway deploy when confidence is above the configured threshold and tests pass.

### Safety Mechanisms For MVP

* All AI changes go through pull requests first.
* Human approval is required before merge during the bootstrap phase, then can be removed once confidence thresholds and rollback automation are proven.
* Full audit log of every AI action.
* Automatic rollback plan on test failure, deploy failure, or Sentry error spike.
* Daily spend cap on AI API calls.
* Explicit allowlist for commands the evolution worker can run.
* Isolated git worktrees per evolution attempt.
* No production secret exposure in prompts, logs, pull request bodies, or model context.

---

## 6. Detailed Technical Requirements

### Models

* `User`
* `Ticket`: `title`, `description`, `status`, `priority`, `user_id`
* `EvolutionLog`: AI action summary, branch, pull request link, status, metrics before/after, failure reason
* `FeatureUsage`: user, event name, metadata, occurred_at
* `Subscription`: Stripe customer/subscription references and billing state

### Background Jobs

* `EvolutionAnalysisJob`
* `ProcessTicketJob`
* `SendEmailJob`
* `SyncStripeJob`

### Initial Routes

* `/` -> landing page
* `/dashboard`
* `/tickets`
* `/tickets/new`
* `/admin/evolution`

---

## 7. Environment Variables

```bash
RAILS_MASTER_KEY=...
DATABASE_URL=...
REDIS_URL=...
STRIPE_SECRET_KEY=...
STRIPE_PUBLISHABLE_KEY=...
STRIPE_WEBHOOK_SECRET=...
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_BUCKET=...
R2_ACCOUNT_ID=...
CLOUDFLARE_ACCOUNT_ID=...
CLOUDFLARE_API_TOKEN=...
SENTRY_DSN=...
ANTHROPIC_API_KEY=...
OPENAI_API_KEY=...
GITHUB_TOKEN=...
EVOLUTION_DAILY_SPEND_CAP_USD=...
EVOLUTION_AUTOMERGE_ENABLED=false
```

---

## 8. Initial Project Structure

```text
looooom/
├── app/
│   ├── controllers/
│   │   ├── tickets_controller.rb
│   │   └── evolution_controller.rb
│   ├── jobs/
│   │   ├── evolution_analysis_job.rb
│   │   └── ...
│   ├── models/
│   │   ├── ticket.rb
│   │   └── evolution_log.rb
│   └── views/
├── config/
│   ├── initializers/
│   │   ├── cloudflare_email.rb
│   │   └── active_storage.rb
│   └── sidekiq.yml
├── lib/
│   └── evolution/
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
9. Create the first `EvolutionAnalysisJob` skeleton and prompt builder in `lib/evolution/`.
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

* Implement the full `EvolutionAnalysisJob` and CLI integration.
* Add the evolution dashboard.
* Remove the human approval gate progressively.
* Add a monetization analysis agent.
* Add prompt and skill evolution so the AI improves its own process over time.

---

## Source Of Truth

This document is the product and technical source of truth until superseded by a newer PRD version.
