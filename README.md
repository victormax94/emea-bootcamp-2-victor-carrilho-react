# Docker Assignment

## Standards to Achieve

By completing this assignment, you demonstrate the following Standards:

- Define Docker image and Docker container
- Run a container in the foreground, mapping ports
- List images and containers
- Show running containers
- Pull and push images
- Create a Dockerfile containing `nginx` and build it

## Steps

For this assignment you will containerize a React application and serve it using `nginx`.

### React

> **NOTE** For Windows users, run all commands from within Ubuntu (WSL)

#### Create the React app

First, create a new React app:

```
cd ~
npx create-react-app react-intro
cd react-intro
```

If you do not have [`npx`](https://www.npmjs.com/package/npx) installed, you can install it with `npm install -g npx`.

### Start the React app

```
npm start
```

This should open `http://localhost:3000` and you should see a React welcome page.

### Run Tests

```
npm test
```

This starts an interactive test window. Tests should be green.

Press `q` or `CTRL+C` to exit.

### Create Remote GitHub Repository and Push

Go to [GitHub](https://github.com), make sure you have authenticated, then create a repository with a unique name. A good convention is to begin with your cohort, then name, then assignment, so for me it would be, for example: `apac-1-andreas-kavountzis-react`.

Create a commit of this process (if needed).

Copy the commands for pushing an existing repository and execute them where you created the React application in the previous steps.

## Dockerizing a React App

Since React is a client-side JavaScript framework, we need something to act as a webserver. For our purposes we select [Nginx](https://www.nginx.com/).

### Option 1: Multistage build

`nginx.conf` (same as above):

```
server {
    listen       8080;
    server_name  localhost;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html =404;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

`Dockerfile`

```
FROM quay.io/upslopeio/node-alpine as build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM quay.io/upslopeio/nginx-unprivileged
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/nginx.conf /etc/nginx/conf.d/default.conf
```

Then from the command line, to build you would execute the following commands:

```
# no need to run npm build
docker build --no-cache -t dockerized-react-app .
docker run -it -p 8080:8080 --rm dockerized-react-app
```

Then open `http://localhost:8080` in your browser to see it work.

When you have completed this, make a commit to your React repository.

**Pros**: You don't need to build the React application separately

**Cons**: The Dockerfile is more complex, and re-downloads npm packages and re-runs the build which might not be necessary (depending on your build system).

## Submit the Assignment

1. `cd` to the `assignments` repository.
1. In your directory (e.g. mine is `andreas-kavountzis`). create a directory named `day-2`, next create a text file named `docker-assignment.txt`.
1. Copy the URL to your React repository into the text file and save it.
1. Make a commit with just this URL and push it. (_hint:_ Why might your changes be rejected? What do you need to do first?)

Please make sure both members of the Pair submit the assignment.

## Stretch Material

1. If you have finished this assignment early, start on this series of [Docker Katas](https://github.com/eficode-academy/docker-katas/tree/master/labs) or try the [In Browser Scenarios with Docker on Katacoda](https://www.katacoda.com/courses/docker).
1. (Build and Burn) Attempt to recreate what you just did without referring to what you just did. _Hint:_ the first command is `npx create-react-app <my-app-name>`.
1. Find an open source application in a stack of your choosing. Attempt to write a simple Dockerfile for that stack that works for development environment, locally. If you complete this, please commit your `Dockerfile` to the `assignments` repository in the `day-2` directory.

---

🛑 Everything in the next section is **optional**, you may skip this if you are not interested.

---

### Background

Public DockerHub images are [severely rate-limited](https://www.docker.com/increase-rate-limits).

Quay.io does not have rate limits on public repositories. See the [Docker Lab](https://cloudnative101.dev/lectures/containers/activities/) for more information on how to create a Quay.io account.

On a client site, you will have an internal Docker registry. In fact, even in class there's an [internal docker registry](https://docs.openshift.com/container-platform/3.3/install_config/registry/accessing_registry.html) on OpenShift Container Platform which you can use.

You can see access information about the OpenShift image repository by running `igc credentials`.

For this tutorial we're referencing images pushed to a personal Quay.io account.

❌️❌ WARNING: these images are not maintained up-to-date and may contain un-patched security vulnerabilities. DO NOT USE on a production application or client site. ❌❌

If you want a more recent image, do the following:

```
export QUAY_USER=<your quay.io username>

docker pull node:alpine
docker tag node:alpine quay.io/$QUAY_USER/node-alpine
docker push quay.io/$QUAY_USER/node-alpine

docker pull nginxinc/nginx-unprivileged
docker tag nginxinc/nginx-unprivileged quay.io/$QUAY_USER/nginx-unprivileged
docker push quay.io/$QUAY_USER/nginx-unprivileged
```

### Build then Build 😉

React applications (as well as other single-page applications) compile down to static files (HTML, CSS, fonts, etc...).

In order to build these applications, you need to add two files:

1. Dockerfile
1. nginx.conf

`nginx.conf`:

```
server {
    listen       8080;
    server_name  localhost;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html =404;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

`Dockerfile`

```
FROM quay.io/upslopeio/nginx-unprivileged
COPY build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

Then from the command line, to build you would execute the following commands:

```
npm run build
docker build -t dockerized-react-app .
docker run -it -p 8080:8080 --rm dockerized-react-app
```

Then open `http://localhost:8080` in your browser to see it work.

**Pros** Your Dockerfile is super simple.

**Cons** You need to build the application before building the Dockerfile.