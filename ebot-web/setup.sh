#!/bin/bash
set -e

INSTALL_MARKER="/var/www/storage/app/.ebot_installed"

cd /var/www

if [ ! -f "$INSTALL_MARKER" ]; then
    echo "First run: setting up eBot CS2 Web..."

    # Generate app key if not set
    APP_KEY_VALUE=$(grep "^APP_KEY=" .env 2>/dev/null | cut -d'=' -f2)
    if [ -z "$APP_KEY_VALUE" ]; then
        echo "Generating application key..."
        php artisan key:generate --force --no-interaction
    fi

    # Run database migrations
    echo "Running database migrations..."
    php artisan migrate --force --no-interaction

    # Create admin user from environment variables
    if [ -n "$EBOT_ADMIN_LOGIN" ] && [ -n "$EBOT_ADMIN_PASSWORD" ]; then
        echo "Creating admin user: $EBOT_ADMIN_LOGIN"
        cat > /tmp/create_admin.php << 'PHPEOF'
<?php
require '/var/www/vendor/autoload.php';
$app = require_once '/var/www/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();
\App\Models\User::updateOrCreate(
    ['username' => getenv('EBOT_ADMIN_LOGIN')],
    [
        'email_address' => getenv('EBOT_ADMIN_EMAIL') ?: getenv('EBOT_ADMIN_LOGIN') . '@localhost',
        'password'      => \Illuminate\Support\Facades\Hash::make(getenv('EBOT_ADMIN_PASSWORD')),
        'algorithm'     => 'bcrypt',
        'is_super_admin' => true,
        'is_active'     => true,
    ]
);
echo "Admin user '" . getenv('EBOT_ADMIN_LOGIN') . "' created." . PHP_EOL;
PHPEOF
        php /tmp/create_admin.php
        rm /tmp/create_admin.php
    fi

    # Mark installed in .env
    if grep -q "^APP_INSTALLED=" .env 2>/dev/null; then
        sed -i "s/^APP_INSTALLED=.*/APP_INSTALLED=true/" .env
    else
        echo "APP_INSTALLED=true" >> .env
    fi

    touch "$INSTALL_MARKER"
    echo "Installation complete!"
else
    echo "eBot CS2 Web already installed. Skipping setup."
fi

# Cache config, routes, and views for performance
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec php-fpm
