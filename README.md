# Why

It's an experiment to test the size between Debian/Alpine/Distroless images.

# Build

```
docker build -t distroless-nginx .

# Keep build files
docker build --build-arg CLEAN_BUILD=0 -t distroless-nginx .
```

# Run

```
# Launch & stop it in background
docker run -it --rm -d -p 8080:80 --name web distroless-nginx
docker stop web

# Launch it in "interactive mode"
docker container run -p 8080:80 -it distroless-nginx
```

# Images sizes

```
# docker images | grep nginx
nginx                                                            latest           f0b8a9a54136   3 days ago          133MB
nginx                                                            alpine           a64a6e03b055   4 weeks ago         22.6MB
distroless-nginx                                                 latest           24ac4d97aa9a   16 minutes ago      28.3MB
```

# Security

The next step:

```
# docker scan nginx
[...]
Package manager:   deb
Project name:      docker-image|nginx
Docker image:      nginx
Platform:          linux/amd64

Tested 136 dependencies for known vulnerabilities, found 108 vulnerabilities.

For more free scans that keep your images secure, sign up to Snyk at https://dockr.ly/3ePqVcp

# docker scan nginx:alpine
[...]
Package manager:   apk
Project name:      docker-image|nginx
Docker image:      nginx:alpine
Platform:          linux/amd64

Tested 43 dependencies for known vulnerabilities, found 1 vulnerability.

For more free scans that keep your images secure, sign up to Snyk at https://dockr.ly/3ePqVcp

# docker scan distroless-nginx
[...]
Package manager:   deb
Project name:      docker-image|distroless-nginx
Docker image:      distroless-nginx
Platform:          linux/amd64

Tested 6 dependencies for known vulnerabilities, found 21 vulnerabilities.

For more free scans that keep your images secure, sign up to Snyk at https://dockr.ly/3ePqVcp
```

It's better with distroless than debian. But alpine still with lower vulnerability issues.
