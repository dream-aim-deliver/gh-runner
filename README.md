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

#### Option B: Automatically (via GitHub API)

You can script this using a GitHub PAT if needed.

---

### 3. Run the container

```bash
docker run -d \
  --name gh-runner \
  -e REPO_URL="https://github.com/youruser/yourrepo" \
  -e RUNNER_TOKEN="your_registration_token" \
  -e RUNNER_LABELS="docker,linux" \
  gh-runner
```

Optional:

* `RUNNER_NAME` – Custom name for the runner (defaults to container hostname)
* `RUNNER_LABELS` – Comma-separated custom labels (default: none)

---

## 📚 Resources

* [GitHub Actions Runners](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)
* [GitHub API – Register a runner](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28)
* [Docker Hub](https://hub.docker.com)

