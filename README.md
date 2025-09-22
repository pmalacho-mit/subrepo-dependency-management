# subrepo-dependency-management (Suede Man)

> That's nice... Like <ins style="text-decoration: underline;">suede, man</ins>.
> 
> — <cite><em><strong>You,</strong> hopefully</em> (after using this workflow)</cite>

A workflow that relies on [git-subrepo](https://github.com/ingydotnet/git-subrepo) for project dependency management, especially when the dependency is a codebase you manage. 

## Stack

In addition to [git](https://git-scm.com/)...

- [git-subrepo](https://github.com/ingydotnet/git-subrepo): Enables us to more easily include git repositories as project dependencies (as compared to [git submodules](https://www.atlassian.com/git/tutorials/git-submodule) and/or [subtrees](https://www.atlassian.com/git/tutorials/git-subtree))  
- [github actions](https://github.com/features/actions): Enables us to keep our remote subrepo dependency branches (`main` and `dist`) up to date.

It is also highly recommended to use:
- [devcontainers](https://containers.dev/): Enables us to easily spin up a development environment that has [git-subrepo installed as a feature](https://github.com/pmalacho-mit/devcontainer-features/tree/main/src/git-subrepo).

## Workflow

### Consuming a Dependency

1. Confirm that your environment has the `git subrepo` command available. If not, see [instructions on installing git-subrepo]().

```bash
git subrepo --version
```

2. Use the `git subrepo clone` command to clone the `dist` branch of your dependency repository into a location of your choosing.

```bash
git subrepo clone --branch dist <repo URL> <destination>
```

> For example: `git subrepo clone --branch dist git@github.com:my-username/my-repo.git ./my-dependency`

3. From here, you are in control of how your dependency's source code is included in your project. Consider:
   - Using symlinks:
   - Create a typescript alias:

#### Upgrading (i.e. `pull`ing)

To get the latest changes for your dependency, simply run the `git subrepo pull` command, with the final argument being the location of your dependency.

```
git subrepo pull <path-to-dependency>
```

> For example: `git subrepo pull ./my-dependency`
 
#### Modifying (i.e. `push`ing)

Since this workflow treats your dependencies as source code within your project, you can freely modify a dependency's files, and track those changes in your top-level project's history (i.e., with the normal `git add` / `git commit` workflow).

If you then want to make those changes available to all consumers of the dependency, you can simply run the `git subrepo push` command, with the final argument being the location of your dependency.

```
git subrepo push <path-to-dependency>
```

> For example: `git subrepo push ./my-dependency`

This will do two things:

1. <u>Immediately</u> make your changes available to any consumer that follows the [upgrading instructions]()
2. Kick off the [subrepo-pull-into-main]() github action, which will create a pull request of your changes into the `main` branch. That way, your changes can be easily reviewed, tested, adjusted, and/or rolled-back, if necessary. See more in [maintaing a dependency]().

> **NOTE:** Because these changes are immediately available, any large and/or breaking changes should instead be accomplished via the [maintaing a dependency guidance]().

### Creating a Dependency

Follow the below steps when setting up a codebase that will behave as a dependency for one or more "consumer" projects.

1. Create a new github repository to contain your dependency's source code.
   - (**RECOMMENDED**) Follow [initializing a repository with git subrepo devcontainer support]()
2. Open your repository in an environment that has the `git subrepo` command available. If not, see [instructions on installing git-subrepo]().

```
git subrepo --version
```

3. Execute the [install-templates.sh](https://github.com/pmalacho-mit/subrepo-dependency-management/blob/main/scripts/install-templates.sh) script from a terminal within your devcontainer

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/scripts/install-templates.sh)"
```

4. Update your repository's action settings (⚙️ Settings > ▶️ Actions > General) to enable:
   - Read and write permissions
   - Allow GitHub Actions to create and approve pull requests
> <img width="755" height="349" alt="Screenshot 2025-09-21 at 3 20 02 PM" src="https://github.com/user-attachments/assets/0595ad07-1bbb-4421-a876-161b2f1b1c24" />

### Maintaing a Dependency

## Prequisites

### Install [git-subrepo](https://github.com/ingydotnet/git-subrepo) 

#### (RECOMMENDED) Within a devcontainer

1. If you haven't already, fork [git-subrepo-devcontainer-template](https://github.com/pmalacho-mit/git-subrepo-devcontainer-template) and configure it as a template (see [Creating a template repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)). 
2. Create a new repository using your [git-subrepo-devcontainer-template](https://github.com/pmalacho-mit/git-subrepo-devcontainer-template) fork as a template (see [Creating a repository from a template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)).

Use a [devcontainer](https://containers.dev/) with a `.devcontainer/devcontainer.json` file that includes [git-subrepo as a feature](https://github.com/pmalacho-mit/devcontainer-features/tree/main/src/git-subrepo)

##### Initializing a repository with `git subrepo` devcontainer support

1. Fork [git-subrepo-devcontainer-template](https://github.com/pmalacho-mit/git-subrepo-devcontainer-template) and configure it as a template (see [Creating a template repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)). 
2. Create a new repository using your [git-subrepo-devcontainer-template](https://github.com/pmalacho-mit/git-subrepo-devcontainer-template) fork as a template (see [Creating a repository from a template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)).

#### On your system

Install `git subrepo` on your system according to their [installation instructions](https://github.com/ingydotnet/git-subrepo?tab=readme-ov-file#installation).
