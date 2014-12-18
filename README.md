# Install recipes for quick server setup

## Serverside
###Add new user
```bash
useradd -m [username] -s /bin/bash
```
###Grant access rights to new user: run `visudo` and add:
```
username ALL=(ALL:ALL) NOPASSWD: ALL
```
###Remote repo keys 
Add remote repo keys to users .ssh/known_hosts to avoid requests while running cap procedures
Git:
```bash
ssh git@github.com
```

## Locally in your app
### Add recipes
```bash
git submodule add git@github.com:linko/cap-recipes.git
cd cap-recipes && git checkout recap
```

### Copy files
```bash
cp cap-recipes/Capfile.recap.example ./
mkdir config/deploy
cp cap-recipes/config/deploy/* ./config/deploy/
```

### Update Gemfile
Copy everything from Gemfile.example to your Gemfile and run `bundle install`

### Setup instructions

```bash
cap deploy:install
cap bootstrap
cap deploy:setup
cap deploy
```
