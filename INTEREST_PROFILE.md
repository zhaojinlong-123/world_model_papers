# Interest Profile

This file defines the current research-interest weighting used for weekly paper retrieval.

Scores use a 1 to 5 scale:

- 5: highest priority, must search deeply every week.
- 4: strong interest, should be included when relevant.
- 3: useful background.
- 2: weak interest.
- 1: archive only.

## Direction Weights

| Direction | Score | Retrieval Guidance |
|---|---:|---|
| Physical AI world foundation models | 5 | Prioritize NVIDIA Cosmos, Google/DeepMind robotics, Genesis, embodied simulation, and physical reasoning. |
| Video world models and long-horizon video generation | 5 | Prioritize controllable long-video generation, world simulators, and interactive video models. |
| VLA / world-action models for robotics | 5 | Prioritize action-conditioned world models, robot policy learning, and world-action planning. |
| Object-centric / latent dynamics world models | 4 | Track structured world state, object-centric simulation, JEPA, latent particles, and feature-based prediction. |
| Inference acceleration for world models | 4 | Track caching, token skipping, distillation, and low-latency rollout methods. |
| Large institution releases | 5 | Force recall NVIDIA, Google/DeepMind, Genesis, Qwen, DeepSeek, Seed/ByteDance when topic-relevant. |
| General LLM reasoning models | 3 | Include as appendix unless directly tied to robotics, VLA, video, or world modeling. |

## Initial Paper Interest Scores

| Paper | Score | Reason |
|---|---:|---|
| PhyWorld | 5 | Physics-faithful video world model, highly aligned with Physical AI and simulation. |
| Nano World Models | 4 | Useful reproducible framework for internal experiments. |
| RLA World Model | 5 | Strong robotics relevance, learns action-useful feature dynamics. |
| DriveDreamer-Policy | 5 | Direct world-action/VLA-style planning relevance. |
| Latent Particle World Models | 4 | Object-centric dynamics for decision-making. |
| ThinkJEPA | 4 | Combines latent world models with VLM reasoning. |
| WorldCache Content-Aware | 4 | Deployment-relevant acceleration. |
| WorldCache Heterogeneous Token | 4 | Deployment-relevant acceleration. |
| TeleWorld | 5 | 4D world memory and dynamic multimodal synthesis. |
| LongVie 2 | 5 | Long-horizon controllable video world model. |

## Next-Week Retrieval Bias

Search should prioritize:

1. Cosmos / SANA / NVIDIA Physical AI releases.
2. Google DeepMind and Gemini Robotics world-model releases.
3. Genesis and physical simulation work.
4. VLA/world-action models for robots.
5. Long-horizon controllable video world models.
6. Efficient world-model inference.

General LLM-only releases such as Gemma-style models should be included only as appendix items unless they directly support world modeling, video generation, VLA, or embodied agents.
