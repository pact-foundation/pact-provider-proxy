#!/bin/sh
set -e

echo "Updating rack-reverse-proxy from master at 'git@github.com:bethesque/rack-reverse-proxy.git'..."
git subtree pull --prefix vendor/rack-reverse-proxy git@github.com:bethesque/rack-reverse-proxy.git master --squash
echo "\033[32mDone!\033[0m"
