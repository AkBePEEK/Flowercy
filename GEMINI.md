# Project Instructions: AI Florist

## Environment
- **Python**: 3.10 (Required for CUDA support)
- **Virtual Env**: `./venv`
- **GPU Acceleration**: Enabled via PyTorch + CUDA 12.1

## Key Components
- `api.py`: FastAPI server for mobile integration.
- `image_generator.py`: Core logic for Stable Diffusion / Catalog / Pillow.
- `main.py`: CLI demo of the full pipeline.

## Workflows
- **Image Generation**:
  - Always prefer GPU (`cuda`) for Stable Diffusion.
  - To bypass catalog matching from API/CLI, use `force_gen=True` / `--force-gen`.
  - Output directory: `./outputs/`

## Integration with Mobile
- Refer to `MOBILE_INTEGRATION.md` for API schemas and request examples.
