<h1 style="text-align: center;">Beyond the 80/20 Rule: High-Entropy Minority Tokens Drive Effective Reinforcement Learning for LLM Reasoning</h1>

<div align="center">
<a href="https://arxiv.org/abs/2506.01939"><img src="https://img.shields.io/static/v1?label=NeurIPS-2025&message=Arxiv&color=red"></a>
  <a href="https://shenzhi-wang.github.io/high-entropy-minority-tokens-rlvr/"><img src="https://img.shields.io/static/v1?label=Project-Page&message=Link&color=blue"></a>
  <a href="https://api.wandb.ai/links/zhouxiangxin-university-of-chinese-academy-of-sciences/0ikhi10b"><img src="https://img.shields.io/static/v1?label=Wandb&message=Logs&color=yellow"></a>
</div>

<img src="img/qwen_leaplab_logo.jpg" style="zoom:50%;" />

👋 Hi, everyone!

Welcome to the open-source code for the NeurIPS 2025 paper, "[Beyond the 80/20 Rule: High-Entropy Minority Tokens Drive Effective Reinforcement Learning for LLM Reasoning](https://arxiv.org/abs/2506.01939)." Thank you for your interest!

<img src="img/teaser.png" alt="teaser" style="zoom:60%;" />

## Installation

Our code is based on [verl](https://github.com/volcengine/verl) (commit id `6cf90ceb079bdc0721b51c23e0107410651ccd82`). 

We recommend using [this Docker image](https://hub.docker.com/layers/hiyouga/verl/ngc-th2.7.1-cu12.6-vllm0.10.0/images/sha256-cfc8c1ce3ea52dee0444f3e58e900d0b1d3b6b315deaf5f58c44b5fbb52fa989), with the following command:

```bash
docker pull hiyouga/verl:ngc-th2.7.1-cu12.6-vllm0.10.0
```

Alternatively, you can refer to [the verl documentation](https://verl.readthedocs.io/en/latest/start/install.html) for instructions on installing the environment. We recommend aligning the installed environment with the Docker image mentioned above.

## Dataset Preparation

For the training dataset, we recommend using the [math dataset](https://huggingface.co/datasets/LLM360/guru-RL-92k/resolve/main/train/math__combined_54.4k.parquet) from the [Reasoning360 paper](https://arxiv.org/abs/2506.14965), as it is more comprehensive than the [DAPO-Math-17k](https://huggingface.co/datasets/BytedTsinghua-SIA/DAPO-Math-17k) dataset used in our paper.

For evaluation, we use the AIME24 and MATH500 benchmarks, duplicating the AIME split so that the AIME24 score reflects avg@32.

The helper script [recipe/rlvr_with_high_entropy_tokens_only/prepare_train_test_datasets.sh](recipe/rlvr_with_high_entropy_tokens_only/prepare_train_test_datasets.sh) downloads the recommended training split, fetches the validation sets, filters the test datasets to keep only the required keys (`data_source`, `prompt`, `reward_model`, `extra_info`) using [recipe/rlvr_with_high_entropy_tokens_only/filter_test_dataset_keys.py](recipe/rlvr_with_high_entropy_tokens_only/filter_test_dataset_keys.py), and invokes [recipe/rlvr_with_high_entropy_tokens_only/duplicate_aime.sh](recipe/rlvr_with_high_entropy_tokens_only/duplicate_aime.sh) to materialize `data/math__aime_repeated_32x_960.parquet`. Both `data/math__aime_repeated_32x_960.parquet` and `data/math__math_500.parquet` are then referenced by the run scripts through `data.val_files`.

## Model Preparation

For the base model, we recommend using [Qwen3-14B-Base](https://huggingface.co/Qwen/Qwen3-14B-Base). According to our paper, RLVR with the top 20% of high-entropy tokens results in a significant performance improvement when scaling the model to 14B or larger. You can download the [Qwen3-14B-Base](https://huggingface.co/Qwen/Qwen3-14B-Base) model to the path `${VERL_HOME}/models/Qwen3-14B-Base/` .

> [!NOTE]
>
> We currently only support the FSDP backend for RLVR with high-entropy tokens. The Megatron backend is not yet supported or verified.

## How to Run

For the DAPO baseline on [Qwen3-14B-Base](https://huggingface.co/Qwen/Qwen3-14B-Base), please refer to the script [recipe/rlvr_with_high_entropy_tokens_only/run_dapo_qwen3_14b.sh](recipe/rlvr_with_high_entropy_tokens_only/run_dapo_qwen3_14b.sh).

For our proposed method, i.e. DAPO with the top 20% high-entropy tokens, on [Qwen3-14B-Base](https://huggingface.co/Qwen/Qwen3-14B-Base), please refer to the script [recipe/rlvr_with_high_entropy_tokens_only/run_only_top20_high_entropy_tokens_dapo_qwen3_14b.sh](recipe/rlvr_with_high_entropy_tokens_only/run_only_top20_high_entropy_tokens_dapo_qwen3_14b.sh).

The training record of Qwen3-14B-Base is published in [W&B](https://api.wandb.ai/links/zhouxiangxin-university-of-chinese-academy-of-sciences/0ikhi10b).

## Citation

If you find our work useful, we would appreciate it if you could cite it:

```
@inproceedings{
  wang2025beyond,
  title={Beyond the 80/20 Rule: High-Entropy Minority Tokens Drive Effective Reinforcement Learning for {LLM} Reasoning},
  author={Shenzhi Wang and Le Yu and Chang Gao and Chujie Zheng and Shixuan Liu and Rui Lu and Kai Dang and Xiong-Hui Chen and Jianxin Yang and Zhenru Zhang and Yuqiong Liu and An Yang and Andrew Zhao and Yang Yue and Shiji Song and Bowen Yu and Gao Huang and Junyang Lin},
  booktitle={The Thirty-ninth Annual Conference on Neural Information Processing Systems},
  year={2025},
  url={https://openreview.net/forum?id=yfcpdY4gMP}
}
```

## Acknowledge

We greatly appreciate [Xiangxin Zhou](https://zhouxiangxin1998.github.io/)'s efforts in reproducing our paper on the public verl codebase.

We also sincerely appreciate the work that our research builds upon, especially [verl](https://github.com/volcengine/verl) for their codebase, [DAPO](https://arxiv.org/abs/2503.14476) for their algorithm and datasets, and [Reasoning360](https://arxiv.org/abs/2506.14965) for their datasets.

