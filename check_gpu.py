import torch

print("=" * 60)
print(f"CUDA Available:     {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"Device Name:        {torch.cuda.get_device_name(0)}")
    print(f"Device Count:       {torch.cuda.device_count()}")
    props = torch.cuda.get_device_properties(0)
    print(f"Total VRAM:         {props.total_memory / (1024**3):.2f} GB")
    print(f"Compute Capability: {props.major}.{props.minor}")
print(f"PyTorch Version:    {torch.__version__}")
print("=" * 60)
