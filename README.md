# World Model Papers Weekly Study

Study date: 2026-06-04

This repository tracks recent and high-signal papers/projects around world models, video generation, embodied simulation, and interactive video world models.

## Scope

The original request asked for the latest one-week popular papers/projects from arXiv, OpenReview, alphaXiv, and Hugging Face. Direct site access failed in this environment, so all network access used the local proxy:

```powershell
http://127.0.0.1:10809
```

Strictly limiting to 2026-05-28 through 2026-06-04 did not yield 10 high-quality public papers across the requested topic. This batch therefore uses an expanded practical scope:

- Priority 1: latest papers near the target week.
- Priority 2: papers crawled or surfaced recently by Hugging Face / alphaXiv / paper aggregators.
- Priority 3: recent core papers from early 2026 and late 2025 that define the current world-model and video-generation trend.

## Directory

```text
papers/   Original PDF files
reports/  Per-paper analysis reports and weekly summary
sources/  Source notes and reproducibility records
```

## Selected Papers

| # | Paper | PDF |
|---|---|---|
| 01 | PhyWorld: Physics-Faithful World Model for Video Generation | `papers/01_PhyWorld_2605.19242.pdf` |
| 02 | Nano World Models: A Minimalist Implementation of Future Video Prediction | `papers/02_Nano_World_Models_2605.23993.pdf` |
| 03 | Learning Visual Feature-Based World Models via Residual Latent Action | `papers/03_Visual_Feature_RLA_2605.07079.pdf` |
| 04 | DriveDreamer-Policy: A Geometry-Grounded World-Action Model for Unified Generation and Planning | `papers/04_DriveDreamer_Policy_2604.01765.pdf` |
| 05 | Latent Particle World Models: Self-supervised Object-centric Stochastic Dynamics Modeling | `papers/05_Latent_Particle_World_Models_2603.04553.pdf` |
| 06 | ThinkJEPA: Empowering Latent World Models with Large Vision-Language Reasoning Model | `papers/06_ThinkJEPA_2603.22281.pdf` |
| 07 | WorldCache: Content-Aware Caching for Accelerated Video World Models | `papers/07_WorldCache_Content_Aware_2603.22286.pdf` |
| 08 | WorldCache: Accelerating World Models for Free via Heterogeneous Token Caching | `papers/08_WorldCache_Heterogeneous_Token_2603.06331.pdf` |
| 09 | TeleWorld: Towards Dynamic Multimodal Synthesis with a 4D World Model | `papers/09_TeleWorld_2601.00051.pdf` |
| 10 | LongVie 2: Multimodal Controllable Ultra-Long Video World Model | `papers/10_LongVie2_2512.13604.pdf` |

## Reports

- `reports/01_PhyWorld.md`
- `reports/02_Nano_World_Models.md`
- `reports/03_RLA_World_Model.md`
- `reports/04_DriveDreamer_Policy.md`
- `reports/05_Latent_Particle_World_Models.md`
- `reports/06_ThinkJEPA.md`
- `reports/07_WorldCache_Content_Aware.md`
- `reports/08_WorldCache_Heterogeneous_Token.md`
- `reports/09_TeleWorld.md`
- `reports/10_LongVie2.md`
- `reports/weekly_summary.md`
