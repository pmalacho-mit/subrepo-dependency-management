git checkout main
curl -L \
  https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/main/.devcontainer/devcontainer.json \
  -o ./.devcontainer/devcontainer.json
curl -L \
  https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/main/.github/workflows/subrepo-push-dist.yml \
  -o ./.github/workflows/subrepo-push-dist.yml
git add ./.devcontainer/devcontainer.json ./.github/workflows/subrepo-push-dist.yml
git commit -m "Adding subrepo dependency management template files (main)"
git push
git checkout --orphan dist
curl -L \
  https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/dist/.github/workflows/subrepo-pull-into-main.yml \
  -o ./.github/workflows/subrepo-pull-into-main.yml
git add ./.github/workflows/subrepo-pull-into-main.yml
git commit -m "Adding subrepo dependency management template files (dist)"
git push
git checkout main
