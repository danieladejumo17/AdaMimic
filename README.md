# AdaMimic: Adaptive Motion Tracking
[![arXiv](https://img.shields.io/badge/arXiv-2510.14454-brown)](https://arxiv.org/abs/2510.14454)
[![](https://img.shields.io/badge/Website-%F0%9F%9A%80-yellow)](https://taohuang13.github.io/adamimic.github.io/)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)]()
[![](https://img.shields.io/badge/Youtube-🎬-red)](https://www.youtube.com/watch?v=OGDoPvs7GS0)


This is the official PyTorch implementation of the paper "[**Towards Adaptable Humanoid Control via Adaptive Motion Tracking**]()" by 

[Tao Huang](https://taohuang13.github.io/), [Huayi Wang](https://why618188.github.io/), [Junli Ren](https://renjunli99.github.io/), [Kangning Yin](https://yinkangning0124.github.io/), [Zirui Wang](https://scholar.google.com/citations?user=Vc3DCUIAAAAJ&hl=zh-TW), [Xiao Chen](https://xiao-chen.tech/), [Feiyu Jia](https://trap-1.github.io/), [Wentao Zhang](), [Junfeng Long](https://junfeng-long.github.io/), [Jingbo Wang](https://wangjingbo1219.github.io/)†, [Jiangmiao Pang](https://oceanpang.github.io/)†

<p align="left">
  <img width="98%" src="docs/teaser_website.png" style="box-shadow: 1px 1px 6px rgba(0, 0, 0, 0.3); border-radius: 4px;">
</p>

## Installation

### 1. Clone and conda environment

Isaac Gym Preview 3 on Linux ships Python bindings such as `gym_38.so`, so this workflow uses **Python 3.8**.

```bash
git clone https://github.com/InternRobotics/AdaMimic.git
cd AdaMimic
conda env create -f conda_env.yml
conda activate adamimic
```

### 2. Conda hook (Isaac Gym and `libpython`)

Isaac Gym’s native library loads `libpython3.8.so.1.0` at runtime. Conda installs that library under `$CONDA_PREFIX/lib`, but the dynamic linker does not always search there. Install the bundled activation hook once per environment:

```bash
bash scripts/install_conda_hooks.sh
conda deactivate && conda activate adamimic
```

Alternatively, for a single shell session only:

```bash
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
```

### 3. Isaac Gym, rsl_rl, legged_gym

Download [Isaac Gym](https://developer.nvidia.com/isaac-gym) into `AdaMimic/isaacgym` (this repository expects the `isaacgym/python` layout next to `legged_gym`). Then:

```bash
cd isaacgym/python && pip install -e . && cd ../..
cd rsl_rl && pip install -e . && cd ..
cd legged_gym && pip install -e . && cd ..
```

The vendored `isaacgym` in this tree includes a small patch for **NumPy ≥ 1.24** (`np.float` → `np.float64` in `torch_utils.py`). If you replace `isaacgym` with a fresh NVIDIA zip, re-apply that one-line change if you see `module 'numpy' has no attribute 'float'`.

### 4. Logging (Weights & Biases default)

Training uses **Weights & Biases** by default. Set your entity or username before running:

```bash
export WANDB_USERNAME=your_wandb_entity_or_username
```

To use **TensorBoard only** (no W&B login), override on the canonical Hydra path (`algorithm.algo` is the source for the `algo` alias):

```bash
algorithm.algo.runner.logger=tensorboard
```

## Usage

Training and play entrypoints live under **`legged_gym/legged_gym/scripts/`** (not `legged_gym/scripts/`).

Hydra requires **`robot`**, **`dataset`**, and **`algorithm`** overrides. For G1 27-DOF tasks, pass `+robot=g1_dof27` and a dataset such as `+dataset=g1_dof27/high_jump`.

**VRAM:** the default `num_envs` (4096) targets large GPUs. On smaller GPUs, reduce it (example: `num_envs=256`).

### AdaMimic training

Stage 1 (example task `high_jump`):

```bash
export WANDB_USERNAME=your_wandb_entity_or_username  # required for default W&B logging
python legged_gym/legged_gym/scripts/train.py \
  +robot=g1_dof27 +dataset=g1_dof27/high_jump +algorithm=adamimic/stage1 \
  num_envs=256
```

For TensorBoard only (no W&B), append `algorithm.algo.runner.logger=tensorboard` and skip `WANDB_USERNAME`.

`python legged_gym/legged_gym/scripts/train.py +robot=g1_dof27 +dataset=g1_dof27/high_jump +algorithm=adamimic/stage1 num_envs=256 algorithm.algo.runner.logger=tensorboard`

Replace `high_jump` with any task under [legged_gym/legged_gym/configs/dataset/g1_dof27/](legged_gym/legged_gym/configs/dataset/g1_dof27/).

Stage 2:

```bash
export WANDB_USERNAME=your_wandb_entity_or_username
python legged_gym/legged_gym/scripts/train.py \
  +robot=g1_dof27 +dataset=g1_dof27/high_jump +algorithm=adamimic/stage2 \
  num_envs=256 checkpoint_path=/path/to/stage1_ckpt.pt
```

Play:

```bash
python legged_gym/legged_gym/scripts/play.py \
  +robot=g1_dof27 +dataset=g1_dof27/high_jump +algorithm=adamimic/stage2 \
  resume_path=/path/to/stage2_ckpt.pt
```

### Baselines

```bash
export WANDB_USERNAME=your_wandb_entity_or_username
python legged_gym/legged_gym/scripts/train.py \
  +robot=g1_dof27 +dataset=g1_dof27/${task} +algorithm=${baseline} num_envs=256
```

Configurations for `${baseline}` are under [legged_gym/legged_gym/configs/algorithm/](legged_gym/legged_gym/configs/algorithm/). Use `algorithm.algo.runner.logger=tensorboard` on the command line if you prefer TensorBoard without W&B.

```bash
python legged_gym/legged_gym/scripts/play.py \
  +robot=g1_dof27 +dataset=g1_dof27/${task} +algorithm=${baseline} \
  resume_path=/path/to/baseline_ckpt.pt
```

## ✉️ Contact
For any questions, please feel free to email taou.cs13@gmail.com. We will respond to it as soon as possible.


## 🎉 Acknowledgments
This repository is built upon the support and contributions of the following open-source projects. Special thanks to:

* [legged_gym](https://github.com/leggedrobotics/legged_gym) and [HIMLoco](https://github.com/OpenRobotLab/HIMLoco): The foundation for training and running codes.
* [rsl_rl](https://github.com/leggedrobotics/rsl_rl.git): Reinforcement learning algorithm implementation.
* [ASAP](https://github.com/LeCAR-Lab/ASAP): Motion tracking implementation.
* [AMP for hardware](https://github.com/escontra/AMP_for_hardware): AMP implementation.
* [GVHMR](https://github.com/zju3dv/GVHMR): SMPL motion reconstruction algorithom.

## 📝 Citation

If you find our work useful, please consider citing:
```
@article{huang2025adaptive,
  title={Towards Adaptable Humanoid Control via Adaptive Motion Tracking},
  author={Huang, Tao and Wang, Huayi and Ren, Junli and Yin, Kangning and Wang, Zirui and Chen, Xiao and Jia, Feiyu and Zhang, Wentao and Long, Jungfeng and Wang, Jingbo and Pang, Jiangmiao},
  year={2025}
}
```

## 📄 License

The code is licensed under the <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">CC BY-NC-SA 4.0 International License</a> <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" /></a>.
Commercial use is not allowed without explicit authorization.
