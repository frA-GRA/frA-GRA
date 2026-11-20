# Description
frA-GRA is the hub repo for the frA-GRA Open Mission Systems (OMS) ecosystem. It holds specifications, Docker Compose example systems, the organization website (`index.html`, served by GitHub Pages at https://fra-gra.github.io/frA-GRA/), and git submodules for each component.

# Layout
 - `specs/` contains the OMS CAL specs (PDF), Markdown summaries of the requirements and schema, and A-GRA notes. This is the only copy of the specs in the ecosystem.
   - `specs/a-gra/` is a submodule (open-arsenal/a-gra) with the A-GRA ASK 6.0a PDFs (`Documentation/`) and XSDs (`Schema/`).
 - `examples/` holds Docker Compose example systems, one per subdirectory, each with a `docker-compose.yml`, `README.md`, a `CALConfig.toml` per OMS system, and an `A-GRA_subset.xsd` made with rcal's `xsd-subset`. `examples/README.md` lists them. Image tags are placeholders.
 - `rcal/` is a submodule: the OMS CAL in Rust (`rcal`, `rcal_macros` crates).
 - `rcal-ardupilot/` is a submodule: a MAVLink-to-UCI gateway for ArduPilot SITL.
 - `cosmos-oms/` is a submodule: an OpenC3/COSMOS plugin that ingests OMS UCI.
 - `index.html` is the website. It is one self-contained page.

# Submodule instructions
Each submodule may have its own CLAUDE.md. Read it before working in that submodule. Its rules override this file.
 - `rcal/CLAUDE.md`: CAL naming and module rules, GitHub issue workflow
 - `cosmos-oms/CLAUDE.md`: COSMOS references, gem build/load commands
 - `rcal-ardupilot`: none yet. Use the shared rules below.

# Submodules and git
 - Each submodule is its own repo and tracks `main`. Commit, branch, and open PRs inside the submodule, not in the hub.
 - The hub only records submodule pointers. Bump a pointer (`git add <submodule>`) only when asked.
 - Update everything: `git submodule update --remote`
 - Never commit secrets. `.env*` and `.secrets/` are gitignored. `.env.ps1` holds local API settings, so never read it or print it.

# Specifications
Look things up in this order. Read a PDF or XSD only when the summary doesn't cover the question.
 - CAL requirements: `specs/cal_cert_requirements.md`, then `specs/04_OMSC-SPC-001_*.pdf`
 - C++ CAL requirements: `specs/cpp_cert_requirements.md`, then `specs/06_OMSC-SPC-008_*.pdf`
 - Rust CAL API: `specs/rust_cal_specification.md` (an AI-generated draft, so trust the rcal code where they differ)
 - UCI schema types and messages: `specs/schema_summary.md`, then the raw `.xsd`
 - A-GRA: `specs/entity-status.md` and `specs/ownship-status.md`, then `specs/a-gra/Documentation/*.pdf` and `specs/a-gra/Schema/*.xsd`

# Shared Rust coding standards (all Rust submodules)
 - Follow the de facto Rust formatting and design standards.
 - Use stable toolchain features only.
 - Ask before adding a dependency. New features of an existing dependency don't need approval.
 - Write unit tests in a private `test` module whenever a test can be written. Purely abstract interfaces don't need tests unless asked.

# Review and checks (Rust submodules)
Run these after implementing a feature and before opening a PR:
 - `cargo check --workspace --all-targets`
 - `cargo clippy --no-deps`
 - `cargo fmt --all`
 - `cargo test --workspace --all-targets`
 - `ponytail-review`
 - `caveman-review`

# Other rules
 - You are a junior software engineer, not the technical lead. Implement only the changes you are asked for, efficiently and precisely.
 - **NEVER** commit to `main` in any repo unless explicitly asked.
 - **NEVER** merge a PR. A human reviews and merges every PR.
