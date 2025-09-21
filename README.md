# subrepo-dependency-management

A workflow that relies on [git-subrepo](https://github.com/ingydotnet/git-subrepo) for project dependency management, when the dependency is a codebase you manage.

## Stack

- [git]:
- [git-subrepo](https://github.com/ingydotnet/git-subrepo): Enables us to more easily include git repositories as project dependencies (as compared to [git submodules](https://www.atlassian.com/git/tutorials/git-submodule) and/or [subtrees](https://www.atlassian.com/git/tutorials/git-subtree))  
- [devcontainer](https://containers.dev/): Enables us to easily spin up a development environment that has [git-subrepo](https://github.com/ingydotnet/git-subrepo) installed.
- [github actions](https://github.com/features/actions): Enables us to keep our remote subrepo dependency branches (`main` and `dist`) up to date.

## Workflow

### Consuming a Dependency

### Creating a Dependency

```bash
git clone ...your repo url...
cd ..your repo...
git checkout main
curl -L \
  https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/main/.devcontainer/devcontainer.json \
  -o ./.devcontainer/devcontainer.json
curl -L \
  https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/main/.github/workflows/subrepo-push-dist.yml \
  -o ./.github/workflows/subrepo-push-dist.yml
git add ./.devcontainer/devcontainer.json ./.github/workflows/subrepo-push-dist.yml
git commit -m "Adding gitsubrepo dependency management supporting files (main)"
git push
git checkout --orphan dist
curl -L \
  https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/dist/.github/workflows/subrepo-pull-into-main.yml \
  -o ./.github/workflows/subrepo-pull-into-main.yml
git add ./.github/workflows/subrepo-pull-into-main.yml
git commit -m "Adding gitsubrepo dependency management supporting files (main)"
git push
```

Update github action permissions
