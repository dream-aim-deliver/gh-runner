# GitHub Actions Self-Hosted Runner (Dockerized)

This project provides a Dockerized GitHub Actions **self-hosted runner** that registers with a repository or organization and runs jobs inside a secure containerized environment.


## 🚀 Features

- GitHub Actions self-hosted runner in a Docker container
- Auto-registers and connects to a GitHub repository or org
- Custom runner labels and naming
- Graceful shutdown with deregistration
- Lightweight Ubuntu-based image


## 🛠️ Requirements

- Docker Engine (v20+)
- A GitHub **Personal Access Token (PAT)** to generate registration tokens
- A repository or organization to attach the runner to


## 🧪 Usage

### 1. Build the image

```bash
docker build -t gh-runner .
```

### 2. Generate a runner token

#### Option A: Manual (via GitHub UI)

1. Go to your GitHub **repository or organization**
2. Navigate to: `Settings → Actions → Runners`
3. Click **"New self-hosted runner"**
4. Copy the registration **URL** and **token**
5. Then run the following command, this will register the runner in GitHub (only done once). Take note of your labels, because you can use them in the workflow YAML files to decide which self-hosted runners are user:

```sh
docker run -d --rm -it \
  -v gh-runner-data:/runner \
  -e REPO_URL="https://github.com/org-name" \
  -e RUNNER_TOKEN="token" \
  -e RUNNER_NAME="gh-runner" \
  -e RUNNER_LABELS="self-hosted,docker,linux,my-gh-runner" \
  gh-runner
```

### 3. Run the container

If the container stops, you can run it again with the following command:

```bash
docker run -d --name gh-runner --restart always \
  -v gh-runner-data:/runner \
  --entrypoint /runner/run.sh \
  gh-runner
```
