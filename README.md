# looooom

This repository is the starting point for **loom**, a Rails-based self-improving website.

Naming note: the site/product is **loom**. The repository and domain use **looooom**.

Current foundation:

* [Product requirements document](docs/looooom-prd.md)
* [Codex evolution prompt](docs/codex-evolution-prompt.md)
* [Bootstrap notes](docs/bootstrap-notes.md)
* [Research notes](docs/research-notes.md)

## Local Development

Use the Homebrew Ruby path on this machine:

```bash
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH" bin/setup
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH" bin/dev
```

The app runs at `http://127.0.0.1:3000`.

## Checks

```bash
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH" bin/ci
```
