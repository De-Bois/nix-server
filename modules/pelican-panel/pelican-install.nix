{ pkgs, dir }:

pkgs.writeShellScriptBin "pelican-install" ''
  DIR=${dir}
  
  echo "Installing Pelican panel to $DIR ..."
  if [ -d $DIR ]; then
    echo "Directory $DIR already exists, exiting"
    exit 1
  fi
  echo "Creating directory ..."
  mkdir -p $DIR
  cd $DIR

  echo "Downloading Pelican panel ..."
  curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz | tar -xzv
  echo "Installing Pelican panel using composer ..."
  yes | composer install --no-dev --optimize-autoloader

  echo "Setting up the environment ..."
  yes "" | php artisan p:environment:setup

  echo "Setting permissions ..."
  chmod -R 755 storage/* bootstrap/cache/
  chown -R nginx:nginx $DIR

  echo "Pelican panel installed successfully"
''
