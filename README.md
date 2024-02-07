# darling.ai LLM

## Runpod serverless worker

## Model

Using this model for darling.ai -> TheBloke/Wizard-Vicuna-13B-Uncensored-SuperHOT-8K-GPTQ

~~The worker uses the [TheBloke/Synthia-34B-v1.2-GPTQ](https://huggingface.co/TheBloke/TheBloke/Synthia-34B-v1.2-GPTQ)
model by [TheBloke](https://huggingface.co/TheBloke). Feel free to fork
the repo and switch it to an alternate model.~~

## Building the Docker image that will be used by the Serverless Worker

### Default (for darling.ai)

Self-contained; doesn't need a Runpod Network volume, as the model is already included in the Docker image.

```bash
depot build --build-platform linux/amd64 -t davguij/darling-ai-llm:1 --push .
```

There are two other options:

1. [Network Volume](docs/building/with-network-volume.md)
2. [Standalone](docs/building/without-network-volume.md) (without Network Volume)

## RunPod API Endpoint

You can send requests to your RunPod API Endpoint using the `/run`
or `/runsync` endpoints.

Requests sent to the `/run` endpoint will be handled asynchronously,
and are non-blocking operations. Your first response status will always
be `IN_QUEUE`. You need to send subsequent requests to the `/status`
endpoint to get further status updates, and eventually the `COMPLETED`
status will be returned if your request is successful.

Requests sent to the `/runsync` endpoint will be handled synchronously
and are blocking operations. If they are processed by a worker within
90 seconds, the result will be returned in the response, but if
the processing time exceeds 90 seconds, you will need to handle the
response and request status updates from the `/status` endpoint until
you receive the `COMPLETED` status which indicates that your request
was successful.

### Available Oobabooga APIs

- [Chat](docs/api/chat.md)
- [Generate](docs/api/generate.md)
- [Get Model](docs/api/get-model.md)
- [List Models](docs/api/list-models.md)
- [Load Model](docs/api/load-model.md)
- [Model Info](docs/api/model-info.md)
- [Stop Stream](docs/api/stop-stream.md)
- [Token Count](docs/api/token-count.md)
- [Unload Model](docs/api/unload-model.md)

### Endpoint Status Codes

| Status      | Description                                                                                                                    |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------ |
| IN_QUEUE    | Request is in the queue waiting to be picked up by a worker. You can call the `/status` endpoint to check for status updates.  |
| IN_PROGRESS | Request is currently being processed by a worker. You can call the `/status` endpoint to check for status updates.             |
| FAILED      | The request failed, most likely due to encountering an error.                                                                  |
| CANCELLED   | The request was cancelled. This usually happens when you call the `/cancel` endpoint to cancel the request.                    |
| TIMED_OUT   | The request timed out. This usually happens when your handler throws some kind of exception that does return a valid response. |
| COMPLETED   | The request completed successfully and the output is available in the `output` field of the response.                          |

## Serverless Handler

The serverless handler (`rp_handler.py`) is a Python script that handles
the API requests to your Endpoint using the [runpod](https://github.com/runpod/runpod-python)
Python library. It defines a function `handler(event)` that takes an
API request (event), calls the appropriate [oobabooba](https://github.com/oobabooga/text-generation-webui) Text Generation API
with the `input`, and returns the `output` in the JSON response.

## Acknowledgements

- [Generative Labs YouTube Tutorials](https://www.youtube.com/@generativelabs)
- [oobabooga Text Generation Web UI](https://github.com/oobabooga/text-generation-webui)

## Additional Resources

- [Postman Collection for this Worker](RunPod_Oobabooga_Worker.postman_collection.json)
- [Generative Labs YouTube Tutorials](https://www.youtube.com/@generativelabs)
- [Getting Started With RunPod Serverless](https://trapdoor.cloud/getting-started-with-runpod-serverless/)
- [Serverless | Create a Custom Basic API](https://blog.runpod.io/serverless-create-a-basic-api/)

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/runpod-worker-oobabooga)
are welcome. Bug fixes and new features are encouraged.

You can contact me and get help with deploying your Serverless
worker to RunPod on the RunPod Discord Server below,
my username is **ashleyk**.

<a target="_blank" href="https://discord.gg/pJ3P2DbUUq">![Discord Banner 2](https://discordapp.com/api/guilds/912829806415085598/widget.png?style=banner2)</a>
