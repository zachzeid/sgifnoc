SGIFNOC
======

Development environment
-----------------------

This repository expects Python 3.11.6 (pinned in `.python-version`) and uses `pyenv` + `Poetry` for environment and dependency management.


Quick setup on macOS (recommended):

1. Make sure Homebrew is installed: https://brew.sh
2. From the repo root run the Makefile target:

```bash
make setup
```

Optional (recommended): install the GitHub CLI (`gh`) to allow creating PRs quickly from your terminal. The Makefile `deps` target will install `gh` for you on macOS.

What this does:
- installs or validates Homebrew packages needed to build Python (xz, openssl, readline)
- installs `pyenv` via Homebrew if missing
- installs Python 3.11.6 via `pyenv` (or whatever is in `.python-version`)
- installs Poetry (using the pyenv-installed Python)
- configures Poetry to prefer the active Python provided by pyenv

After running `make setup`, open a new terminal (or source your shell profile). Then in the project directory you can create / use the environment with:

```bash
pyenv local 3.11.6
poetry env use "$(pyenv which python)"
poetry install
```

Notes
-----
- The script is idempotent and safe to run on multiple macbooks.
- If the script fails during Python build, ensure Xcode command-line tools are installed (`xcode-select --install`) and that Homebrew's paths are available.
- If you prefer Poetry virtualenvs to be created inside the project, update `poetry config virtualenvs.in-project true` (not set by the script by default).
## configuration files

#### Installation

```
make - Sets up standard dotfiles, vim and iterm

```

```
make dotfiles
make vim
make iterm-apply
make iterm-capture
```

##### Apps
```
Google Chrome
iTerm2
VirtualBox
Docker Toolkit
GPG
```
