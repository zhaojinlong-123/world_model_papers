# 08. WorldCache: Accelerating World Models for Free via Heterogeneous Token Caching

## Metadata

- arXiv: https://arxiv.org/abs/2603.06331
- PDF: `../papers/08_WorldCache_Heterogeneous_Token_2603.06331.pdf`
- Hugging Face Papers: https://huggingface.co/papers/2603.06331
- Topic: heterogeneous token caching, diffusion world model acceleration

## Core Problem

Generic diffusion caching policies do not transfer cleanly to world models. World models have multimodal coupling, spatially varying tokens, and non-uniform temporal dynamics. Some tokens are stable, some are predictable, and some are chaotic. Uniform skipping is either unsafe or too conservative.

## Main Idea

This WorldCache variant introduces:

- Curvature-guided heterogeneous token prediction.
- Hermite-guided damped prediction for chaotic tokens.
- Chaotic-prioritized adaptive skipping.
- Curvature-normalized drift estimation.

The model selectively recomputes only the tokens that begin to drift.

## Technical Reading

This paper focuses on token-level dynamics rather than region-level perceptual caching. The key idea is to classify tokens by temporal behavior:

- Stable tokens can be reused.
- Smooth tokens can be extrapolated.
- Chaotic tokens need careful updating.

This framing makes caching closer to a lightweight dynamics model.

## Experiments And Evidence

The paper reports up to 3.7x end-to-end speedup while maintaining around 98% rollout quality. The important takeaway is that the speedup comes without retraining, making it attractive for deployment.

## Strengths

- Strong speedup.
- Training-free and model-compatible.
- Uses world-model-specific temporal structure.
- Good fit for resource-constrained inference.

## Limitations

- Speed-quality trade-off may vary significantly by scene.
- It may be hard to know whether skipped chaotic tokens harm planning until downstream tests are run.
- It does not solve semantic or physical inconsistency.

## Relevance To World Models

This paper reinforces a key trend: inference optimization is now part of world-model research. The best simulator is not just the most accurate but the one that can run fast enough to be useful.

## Product Implication

For robot products, heterogeneous caching could reduce inference cost and enable more frequent world-state prediction under limited compute budgets.
