# Source Notes

Date: 2026-06-04

## Connectivity

Direct access failed for:

- arXiv
- OpenReview
- alphaXiv
- Hugging Face

Proxy access succeeded for all four:

```powershell
http://127.0.0.1:10809
```

## Search And Selection Sources

Main paper sources:

- arXiv: `https://arxiv.org/abs/<id>`
- arXiv PDF: `https://arxiv.org/pdf/<id>`
- Hugging Face Papers: `https://huggingface.co/papers/<id>`
- alphaXiv: `https://www.alphaxiv.org/overview/<id>` or `https://www.alphaxiv.org/resources/<id>`
- OpenReview: used as a conference/publication cross-check where available, especially LPWM.

## Major Institution Recall Policy

Before freezing each weekly Top 10 list, explicitly scan the following institution channels:

- NVIDIA Research, NVIDIA Cosmos, NVIDIA model cards, NVIDIA Hugging Face orgs
- Google Research, Google DeepMind, Gemini Robotics, Google model/blog releases
- Genesis ecosystem pages and repositories
- Qwen / Alibaba model and technical-report releases
- DeepSeek model, paper, and technical-report releases
- Seed / ByteDance research and model releases

If one of these institutions releases a directly relevant world model, video generation model, VLA system, physical AI foundation model, embodied simulator, or major technical report during the week, it should be placed in the candidate pool even if it is not yet indexed cleanly by arXiv search.

## Selected IDs

```text
2605.19242
2605.23993
2605.07079
2604.01765
2603.04553
2603.22281
2603.22286
2603.06331
2601.00051
2512.13604
```

## Recency Caveat

The target week was 2026-05-28 to 2026-06-04. The strict one-week set was too small for 10 strong world-model/video-generation items, so the selected set expands to recent and recently surfaced papers/projects from 2026 and late 2025.
