# Archer - For hitting the point from a distance

Archer is a command line tool we use to create, build, deploy, and
manage our user facing applications.

## Installing Archer

Installing Archer is quick on a POSIX system. You may simply run the
following command inside your shell to get it going.

    npm install archer -g

Documentation for installing Node.js and the Node Package Manager can
be found at [the Node.js homepage](http://nodejs.org)

## Basic Usage

Create, and start an example application

    archer init test-application --template=blog-application
    cd blog-application
    archer run
    # server running on localhost:29547

## Deployment

We provide a simple cloud application service for running your archer
applications. An account registration is required, and hosting will
affect your account usage. If you are offering an open source
application, send us an email and we can look into setting you up with
a free shared account.

To provide a secondary option for users
wishing to remain independent you can deploy and run any application
using traditional Node.js techniques. 

### Hosted

You can use any domain or subdomain to host an archer
application, simply create a `CNAME` record with your DNS provider
that points to `quiver.onfrst.com`.

    # inside of a project
    archer deploy [site-url]

### Private

In order to deploy a private installation of your application you will
need to build your application and send it where it will be
run. Wherever you have decided to host your application, you may
simply start it up with a traditional node command. 

The `build` command includes all dependencies, so the platform you use
to build should be similar to your hosted environment.

    # in your build environment
    archer build
    scp [project-name].tgz [site-url]:/home/user/

    # on your remote host
    tar xzf [project-name].tgz
    cd [project-name]
    node [main-file].js

It should be as easy as that in all deployment cases. Setting up your
servers users, directories, application services are all left up to
you in most cases. Whether you use coffee-script or not, we compile
everything into a clean `js` package.

## Templates

Project templates may be created & distributed easily. We include a
number of useful project templates to get you started.

## License 

(The MIT License)

Copyright (c) 2012 <%= @author.name %> <<%= @author.email %>>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
