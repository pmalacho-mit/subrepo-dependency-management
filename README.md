# subrepo-dependency-management

A workflow that relies on [git-subrepo](https://github.com/ingydotnet/git-subrepo) for project dependency management, when the dependency is a codebase you manage.

## Stack

- [git-subrepo](https://github.com/ingydotnet/git-subrepo): Enables us to more easily include git repositories as project dependencies (as compared to [git submodules](https://www.atlassian.com/git/tutorials/git-submodule) and/or [subtrees](https://www.atlassian.com/git/tutorials/git-subtree))  
- [devcontainer](https://containers.dev/): Enables us to easily spin up a development environment that has [git-subrepo](https://github.com/ingydotnet/git-subrepo) installed.
- [github actions](https://github.com/features/actions): Enables us to keep our remote subrepo dependency branches (`main` and `dist`) up to date.
