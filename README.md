# frA-GRA

Central hub for the frA-GRA Open Mission Systems (OMS) ecosystem. Contains specifications, Docker Compose examples, and git submodules for a complete local checkout.

## Quick Start

Clone with all submodules:

```bash
git clone --recurse-submodules https://github.com/frA-GRA/frA-GRA
cd frA-GRA
```

Run an example system with Docker Compose:

```bash
docker compose -f examples/1-quad-basic/docker-compose.yml up
```

More examples are listed in [examples/README.md](examples/README.md).

## Repository Structure

```
frA-GRA/
├── specs/              OMS specifications and UCI schema summaries
│   └── a-gra/          submodule — A-GRA interface specifications
├── examples/           Docker Compose example systems
├── rcal/               submodule — OMS CAL in Rust
├── rcal-ardupilot/     submodule — MAVLink/UCI gateway for ArduPilot SITL
└── cosmos-oms/         submodule — OpenC3/COSMOS OMS plugin
```

## Submodules

| Module | Description | Remote |
|--------|-------------|--------|
| `rcal` | OMS CAL implementation in Rust | [frA-GRA/rcal](https://github.com/frA-GRA/rcal) |
| `rcal-ardupilot` | MAVLink-to-UCI gateway | [frA-GRA/rcal-ardupilot](https://github.com/frA-GRA/rcal-ardupilot) |
| `cosmos-oms` | OpenC3/COSMOS OMS plugin | [frA-GRA/cosmos-oms](https://github.com/frA-GRA/cosmos-oms) |
| `specs/a-gra` | A-GRA interface specifications | [open-arsenal/a-gra](https://github.com/open-arsenal/a-gra) |

All submodules track the `main` branch.

Update submodules to latest:

```bash
git submodule update --remote
```

## Specifications

The `specs/` directory contains:

- `cal_cert_requirements.md` — CERT requirements from OMSC-SPC-001 Rev L
- `cpp_cert_requirements.md` — C++ CAL CERT requirements from OMSC-SPC-008
- `rust_cal_specification.md` — Rust CAL specification
- `schema_summary.md` — UCI schema type and message summary
- `04_OMSC-SPC-001_RevL_CAL_Specification_DandD_v2_5.docx.pdf` — full CAL spec
- `06_OMSC-SPC-008_RevK_CxxCALSpec_DandD_v2_5.docx.pdf` — full C++ CAL spec
- `specs/a-gra/` — A-GRA interface specifications (submodule)

## Website

The organization website is hosted at [https://fra-gra.github.io/frA-GRA/](https://fra-gra.github.io/frA-GRA/).
