request = require 'request'
child_process = require 'child_process'
{spawn, exec} = child_process
fs = require 'fs'
path = require 'path'
mime = require 'mime'
async = require 'async'
nconf = require 'nconf'

try
        package_json = require(process.cwd() + '/package.json')
catch e
        #console.log 'not in a project directory'
throw "no package.json" unless package_json

bold = '\x1b[0;1m'
green = '\x1b[0;32m'
blue = '\x1b[0;34m'
red = '\x1b[0;31m'
reset = '\x1b[0m'

app =
        session: null
        user: null
        access_token: null

nconf.file(process.env.HOME + '/.flash.json')
#console.log 'nconf', nconf
unless nconf.get('user')
        nconf.set('user', {email:"anonymous@onfrst.com"})
        nconf.save()
#console.log 'user', nconf.get('user')

FrstClient = require("frst")
frst = new FrstClient
        access_token: nconf.get('access_token')
        host: nconf.get('host')

module.exports =
        register: (user, cb)->
                console.log('flash.register', user)
                frst.post 'users', user, (err, res)->
                        console.log(err) if err
                        console.log 'res', res
                        cb(err, res)

        login: (user, cb)->
                #console.log('flash.login', user)
                frst.post 'login', user, (err, res)->
                        if err
                                cb(err, null)
                        else
                                #console.log('frst.login', res)
                                nconf.set('session', res.session)
                                nconf.set('user', res.user)
                                nconf.set('access_token', res.user.access_tokens[0])
                                frst.access_token = nconf.get('access_token')
                                nconf.save()
                                cb(null, res.message)

        run: (app, cb)->
                if typeof app == 'function'
                        cb = app
                        app = null

                main_filepath = path.join(process.cwd(), package_json.main)
                args = [main_filepath]
                command = if package_json.main.match('coffee') then "coffee" else "node"
                @local command, args, cb

        local: (command, cb)->
                @launch 'sh', ['-c', command], cb

        remote: (command, cb)->
                @launch 'ssh', ['onfrst.com', command], cb

        launch: (command, options, cb)->
                throw new Error('No command specified') unless command

                host = if command == "ssh" then options[0] else "local"

                console.log "#{blue}[#{host}]: #{reset}#{command} #{options.join(' ').replace(/\n/g, '')}"
                res = []

                child = spawn(command, options)


                child.stderr.on 'data', (chunk)->
                        console.log red + "#{red}[#{host}]: #{reset}#{chunk}"

                child.stdout.on 'data', (chunk)->
                        console.log "#{green}[#{host}]: #{reset}#{chunk}"
                        res.push chunk

                child.on 'exit', (code)->
                        #console.log(green + '> ' + reset + res)
                        #console.log(red + '> ' + reset + code) unless code == 0

                        code = if code == 0 then null else code
                        cb(code, 'done')

        deploy: (host, cb)->
                if typeof host == "function"
                        host = "onfrst.com"
                        user = "nrub" # XXX
                        cb = host

                project = package_json.name
                archive = "#{project}.tgz"
                mime_type = mime.lookup(archive)

                @remote """
                git clone git@onfrst.com:#{project}.git;
                cd ~/#{project};
                """, (err, res)=>
                        console.log err if err
                        console.log res

                        #console.log archive
                        fs.stat archive, (err, stat)->
                                fs.readFile archive, (err, file)->
                                        #console.log 'read file', stat
                                        data = {}
                                        data._attachments = {}
                                        data._attachments[archive] =
                                                follows: true
                                                length: stat.size
                                                'content_type': mime_type
                                        options =
                                                route: 'applications'
                                                multipart: [
                                                        {'content-type': 'application/json',body: JSON.stringify(data)}
                                                        ,{body:file}
                                                ]
                                        #frst.post options, (err, res)->
                                        #        console.log 'posted', res
                                        #        cb(null, 'done') if cb


                #@launch 'fleet deploy --hub=onfrst.com:7000 --secret=elevenanddragons', (err, res) =>
                #        @clean => @setup => @start => cb(err, 'done')

        clean: (cb)->
                @launch 'fleet exec -- rm -rf node_modules', (err, res) =>
                        cb(err, 'done') if cb

        setup: (cb)->
                @launch 'fleet exec -- npm install -l', (err, res) =>
                        cb(err, 'done') if cb

        start: (cb)->
                @launch 'fleet spawn -- coffee server.coffee', (err, res) =>
                        cb(err, 'done') if cb

        stop: (pid, cb)->
                return cb('process id is required', null) unless pid
                @launch "fleet stop #{pid}", (err, res) =>
                        cb(err, 'done') if cb

        restart: (pid, cb)->
                @stop pid, => @start (err, res) =>
                        cb(err, 'done') if cb

        ps: (cb)->
                @launch 'fleet ps', (err, res)=>
                        cb(err, "done") if cb

        test: (project, cb)->
                @launch "mocha --compilers coffee:coffee-script test/*.coffee", (err, res)=>
                        cb(err, 'done') if cb

        create: (project, type, cb)->
                console.log 'create'
                throw new Error('No project name specified') unless project
                throw new Error('Unknown project type') unless type == "application" or type == "module"

                template = if type == "application" then "#{__dirname}/../templates/application" else "#{__dirname}/../templates/module"

                console.log 'template', template

                async.waterfall [
                        (callback)=>
                                @launch "cp -r #{template} #{project}", callback
                        ,(res, callback)=>
                                @launch "cd #{project}; git init", callback
                        ,(res, callback)=>
                                @launch "cd #{project}; git add .", callback
                        ,(res, callback)=>
                                @launch "cd #{project}; git commit -m 'initial commit for #{project}'", callback
                        ], (err, res)->
                                cb(null, 'done') if cb

        ports: (cb)->
                frst.get 'applications', (err, applications)->
                        if applications and applications.length
                                for app in applications
                                        console.log app
                        else
                                console.log "No applications running"
                        if err
                                cb(err)
                        else
                                cb(null, 'done') if cb

        # Lists and executes system jobs
        job: (name, cb)->
                #console.log 'job', typeof name
                if typeof name == "function"
                        cb = name
                        name = null
                if name
                        #console.log 'run job', name
                        try
                                job = require("/Users/nrub/com/onfrst/worker/jobs/#{name}")
                                job.run {}, cb
                        catch e
                                if e.message.match('Cannot find module')
                                        console.log 'job not found'
                                else
                                        console.log e
                                cb(null, 'done')
                else
                        # list jobs
                        fs.readdir "/Users/nrub/com/onfrst/worker/jobs", (err, dir)->
                                for script in dir
                                        console.log script.replace('.coffee', '')
                                cb(null, 'done')

        servers: (cb)->
                #console.log 'listing all servers'
                frst.get 'servers', (err, servers)->
                        if servers and servers.length
                                for server in servers
                                        console.log server
                        else
                                console.log "No servers currently clustered"
                        if err
                                cb(err)
                        else
                                cb(null, 'done')

        add_server: (server, cb)->
                console.log 'add server', server
                frst.post 'servers', server, (err, server)->
                        console.log err if err
                        console.log server
                cb(null, 'done')

        add_dependency: (name, cb)->
                # is this a versioned string? name@0.0.0
                [name, version] = name.split("@") if name.match("@")

                # is this a git repo? git+ssh://github.com/frst/logging.git
                if name.match(".git")
                        # is there a tag?
                        if name.match("#")
                                console.log name, version, name.split("#")
                                [name, version] = name.split("#")

                try
                        @add_component name, version, cb
                        return
                catch e
                        console.log 'not a component', e

                try
                        @add_npm_dependency name, version, cb
                        return
                catch e
                        console.log 'not an npm dependency', e

        add_npm_dependency: (name, version, cb)->
                console.log 'adding npm dependency', name, version
                try
                        @launch "npm install #{name}", cb
                catch e
                        cb(e)

        init: (cb)->
                repo = process.cwd().replace(process.env.HOME + '/', '')
                console.log 'repo', repo
                @remote """
                mkdir -p #{repo}.git;
                cd #{repo}.git;
                git --bare init;
                true
                """, (res)=>
                        @local """
                        git init;
                        touch .gitignore;
                        git add .gitignore;
                        git commit -m 'Add git ignore';
                        git remote add origin onfrst.com:#{repo}.git;
                        git push -u origin master
                        """, cb
