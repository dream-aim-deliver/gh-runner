# GitHub Actions Self-Hosted Runner (Dockerized)

This project provides a Dockerized GitHub Actions **self-hosted runner** that registers with a repository or organization and runs jobs inside a secure containerized environment.


## 🚀 Features

- GitHub Actions self-hosted runner in a Docker container
- Auto-registers and connects to a GitHub repository or org
- Custom runner labels and naming
- Lightweight Ubuntu-based image
- Runners with docker-in-docker


## 🛠️ Requirements

- Docker Engine (v20+)
- A repository or organization to attach the runner to


## 🧪 Usage

### 1. Build the images

You'll build an image per runner, and will need a registration token per runner. The setup script will create these programatically, and for this you'll need an organization PAT with read and write permissions for runners.
Once you have it, set up an `.env` file following the `.env.template`:

- GH_ORG_PAT: the PAT of your organizations with read and write permissions on runners
- ORG_NAME: your GitHub organization name
- REPO_URL: your GitHub organization URL
- RUNNER_LABELS: needs to include "self-hosted"; others recommended are "docker", "linux", and "org-gh-runner". This gives us `self-hosted,docker,linux,org-gh-runner`
- RUNNER_COUNT: the amount of runners that will be created. At least 5 are recommended
- DOCKER_GID: the docker group ID of the host machine

### 2. Run the containers

You're now ready to start the containers in detached mode. You can also re-execute this command if the container stops:

```bash
docker compose up -d
```

To remove, simply run
```bash
docker compose down --volumes --remove-orphans
```

