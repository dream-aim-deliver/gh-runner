# GitHub Actions Self-Hosted Runner

This project provides GitHub Actions **self-hosted runners** in virtual machines that registers with a repository or organization and runs jobs inside a secure containerized environment.


## 🚀 Features

- GitHub Actions self-hosted runner in a Virtual Machine
- Auto-registers and connects to a GitHub repository or org
- Custom runner labels and naming
- Lightweight Ubuntu-based image
- Runners have basic tools like docker and gh


## 🛠️ Requirements

- Vagrant
- A repository or organization to attach the runner to


## 🧪 Usage

### 1. Get the necessary ENV variables

You'll build a VM per runner, and will need a registration token per runner. The setup script will create these programatically, and for this you'll need an organization PAT with read and write permissions for runners.
Once you have it, set up an `.env` file following the `.env.template`:

- GH_ORG_PAT: the PAT of your organizations with read and write permissions on runners
- ORG_NAME: your GitHub organization name
- REPO_URL: your GitHub organization URL
- RUNNER_LABELS: needs to include "self-hosted"; others recommended are "docker", "linux", and "org-gh-runner". This gives us `self-hosted,docker,linux,org-gh-runner`
- RUNNER_COUNT: the amount of runners that will be created. At least 5 are recommended
- RUNNER_VERSION: the version of the github runner


### 2. Setup the VMs

You're now ready to start the virtual machines:

```bash
./setup
```

If you have a VM name-clashing problem, and don't mind destroying old VMs, you can pass the `-d` argument to the setup script:

```bash
./setup -d
```

