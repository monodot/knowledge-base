---
layout: page
title: Nginx
---

## Logs

Logs on CentOS are in **/var/log/nginx/error.log**.

## Configuration samples

### Reverse proxy at a location

How to get Nginx to forward (reverse proxy) any requests to `/backend-api` to another service which is running on port 8181 on the host - e.g. useful for forwarding traffic to Docker containers:

```
server {
    listen 80;
    listen [::]:80;

    root /var/www/services.examplecat.com/public_html;
    server_name services.examplecat.com;
    index index.html;

    location /backend-api/ {
        proxy_pass http://localhost:8181/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Troubleshooting

In the nginx logs: _2020/12/21 13:33:32 [error] 19947#0: *9567 FastCGI sent in stderr: "Primary script unknown" while reading response header from upstream, client: 31.14.251.152, server: example.com, request: "GET /hello.php HTTP/1.1", upstream: "fastcgi://unix:/var/run/php-fpm/php-fpm.sock:", host: "example.com"_

- PHP-FPM can't find the file it's supposed to interpret. Probably related to a wrong `SCRIPT_FILENAME` in the nginx configuration file.
- Ensure that the site's conf file has a line like: `fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;`
- Also ensure that the `root` is set correctly for this vhost, as the document root will be passed to PHP-FPM so it knows where the PHP script is.
 
