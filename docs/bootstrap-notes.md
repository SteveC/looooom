# Bootstrap Notes

## Current Local State

* Repository path: `/Users/steve/looooom`
* Git remote: `git@github.com:SteveC/looooom.git`
* Local Ruby detected: `ruby 2.6.10p210`
* Rails command: not installed for the active Ruby
* Bundler detected: `1.17.2`

Rails 8 cannot be generated with this active Ruby. Rails official guidance says Rails 8.0 and 8.1 require Ruby 3.2.0 or newer.

## Recommended Bootstrap

Use a project-local Ruby manager before generating the Rails app:

```bash
brew install ruby-build rbenv
rbenv install 3.4.8
rbenv local 3.4.8
gem install bundler rails
rails new evosite --css=tailwind --database=postgresql
```

After generation, copy or keep these repository documents at the Rails app root as appropriate:

* `AGENTS.md`
* `docs/evosite-prd.md`
* `docs/codex-evolution-prompt.md`
* `docs/research-notes.md`

## First Rails Milestone

1. Generate Rails 8 with PostgreSQL and Tailwind.
2. Add Devise, OmniAuth providers, Stripe, Sidekiq, Sentry, R2 storage, and Cloudflare Email Service wiring.
3. Create the Ticket, FeatureUsage, Subscription, and EvolutionLog models.
4. Add a minimal dashboard and ticket CRUD.
5. Add `EvolutionAnalysisJob` as a no-op prompt builder that records an `EvolutionLog`.
6. Run tests and commit.

