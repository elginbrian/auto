#!/bin/bash
# SSL certificate renewal script

sudo certbot renew --quiet
sudo systemctl reload nginx
echo "SSL certificates renewed and Nginx reloaded."
