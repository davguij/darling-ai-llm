FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ARG OOBABOOGA_COMMIT=2af7e382b121f2eae16dd1f7ace621d31028b319
ARG MODEL="TheBloke/Wizard-Vicuna-13B-Uncensored-SuperHOT-8K-GPTQ"

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade apt packages and install required dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    python3-dev \
    python3-pip \
    git \
    git-lfs && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean -y

WORKDIR /workspace
RUN git clone https://github.com/oobabooga/text-generation-webui && \
    cd text-generation-webui && \
    git checkout ${OOBABOOGA_COMMIT} && \
    pip3 install --no-cache-dir torch==2.1.2 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install --no-cache-dir xformers && \
    pip3 install -r requirements.txt && \
    bash -c 'for req in extensions/*/requirements.txt ; do pip3 install -r "$req" ; done' && \
    mkdir -p repositories && \
    cd repositories && \
    git clone https://github.com/turboderp/exllama && \
    pip3 install -r exllama/requirements.txt

# Fetch the model
COPY download_model.py fetch_model.py /
RUN pip3 install huggingface_hub runpod && \
    /fetch_model.py ${MODEL} /workspace/text-generation-webui/models

# Include the custom characters
COPY characters/Carm.json /workspace/text-generation-webui/characters/Carm.json

# Docker container start script
COPY start_standalone.sh /start.sh
COPY rp_handler.py /
COPY schemas /schemas

# Start the container
RUN chmod +x /start.sh
ENTRYPOINT /start.sh
