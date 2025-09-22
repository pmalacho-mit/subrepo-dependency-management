# subrepo-dependency-management

A workflow that relies on [git-subrepo](https://github.com/ingydotnet/git-subrepo) for project dependency management, when the dependency is a codebase you manage.

## Stack

In addition to [git](https://git-scm.com/)...

- [git-subrepo](https://github.com/ingydotnet/git-subrepo): Enables us to more easily include git repositories as project dependencies (as compared to [git submodules](https://www.atlassian.com/git/tutorials/git-submodule) and/or [subtrees](https://www.atlassian.com/git/tutorials/git-subtree))  
- [devcontainer](https://containers.dev/): Enables us to easily spin up a development environment that has [git-subrepo](https://github.com/ingydotnet/git-subrepo) installed.
- [github actions](https://github.com/features/actions): Enables us to keep our remote subrepo dependency branches (`main` and `dist`) up to date.

## Workflow

### Consuming a Dependency


```bash
git subrepo clone <repo URL> <destination>
```

For example: `git subrepo clone git@github.com:my-username/my-repo.git ./my-dependency`

### Creating a Dependency

1. If you haven't already, fork [git-subrepo-devcontainer-template](https://github.com/pmalacho-mit/git-subrepo-devcontainer-template) and configure it as a template (see [Creating a template repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)). 
2. Create a new repository using your [git-subrepo-devcontainer-template](https://github.com/pmalacho-mit/git-subrepo-devcontainer-template) fork as a template (see [Creating a repository from a template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)).
3. Clone your repository on your local machine (e.g. `git clone ...`)
4. Open you repository in your IDE that supports devcontainers and ensure you project is opened within a devcontainer
5. Execute the [install-templates.sh](https://github.com/pmalacho-mit/subrepo-dependency-management/blob/main/scripts/install-templates.sh) script from a terminal within your devcontainer

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/scripts/install-templates.sh)"
```

6. Update your repository's action settings (⚙️ Settings > ▶️ Actions > General) to enable:
- Read and write permissions
- Allow GitHub Actions to create and approve pull requests
> <img width="755" height="349" alt="Screenshot 2025-09-21 at 3 20 02 PM" src="https://github.com/user-attachments/assets/0595ad07-1bbb-4421-a876-161b2f1b1c24" />
