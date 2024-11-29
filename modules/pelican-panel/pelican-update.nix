{ pkgs, dir }:

pkgs.writeShellScriptBin "pelican-update" ''
  DIR=${dir}
  
  echo "Updateing Pelican panel in $DIR ..."
  if [ -d $DIR ]; then
    echo "Directory $DIR found, entering maintenance mode ..."
  else
    echo "Directory $DIR does not exist, exiting"
    exit 1
  fi
  
  cd $DIR
  php artisan down

  echo "Downloading Pelican panel update ..."
  curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz | tar -xzv

  echo "Setting permissions ..."
  chmod -R 755 storage/* bootstrap/cache

  echo "Updating Pelican panel using composer ..."
  yes | composer install --no-dev --optimize-autoloader

  echo "Clearing compiled template cache ..."
  php artisan view:clear
  php artisan config:clear 

  echo "Optimizing Pelican panel ..."
  php artisan filament:optimize

  echo "Updating the database ..."
  php artisan migrate --seed --force

  echo "Setting permissions ..."
  chown -R nginx:nginx $DIR

  echo "Restart Pelican queue service ..."
  systemctl restart pelican-queue.service

  echo "Exiting maintenance mode ..."
  php artisan up

  echo "Pelican panel updated successfully"
''
