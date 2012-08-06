#!/usr/bin/env coffee
program = require("commander")
async = require("async")
exec = require('child_process').exec
util = require 'util'

archer = require("../lib/archer")

package_json = require("../package.json")

bold = '\x1b[0;1m'
green = '\x1b[0;32m'
red = '\x1b[0;31m'
reset = '\x1b[0m'

complete = (err, res)->
        code = 0

        if err
                console.log red + util.inspect(err) + reset if err
                code = 1

        console.log green + res + reset if res

        process.exit(code)

program.name = "archer"
program
        .version(package_json.version)

program.command("run")
        .description("Run the application in the current directory")
        .action () ->
                archer.run complete

program.command("create <name>")
        .description("Create a local application")
        .action (name) ->
                #console.log("create", name)
                async.waterfall [
                        (callback)->
                                program.prompt 'type (application, module): ', (type)->
                                        type = "module" unless type == "a" or type == "application" or type == "app" or type == ""
                                        type = "application"
                                        callback(null, type)
                        ], (err, type)->
                                console.log(type)
                                archer.create name, type, complete

program.command("deploy")
        .description("Deploys a server configuration across your nodes")
        .action () ->
                archer.deploy complete

program.command("ps")
        .description("Shows processes running on any drones")
        .action (project)->
                archer.ps complete

program.command("login")
        .description("Create a session the programmable-matter server")
        .action () ->
                async.waterfall [
                        (callback)->
                                program.prompt 'email: ', (email)->
                                        # TODO test if email is available, if not switch to registration
                                        res = {email: email}
                                        callback(null, res)
                        ,(res, callback)->
                                program.password 'password: ', "*", (password)->
                                        res.password = password
                                        process.stdin.destroy();
                                        callback(null, res)
                        ], (err, res)->
                                console.log(res)
                                archer.login res, (err, body)->
                                        console.log('finished')

program.command("register")
        .description("Register a user account with the programmable-matter server")
        .action ()->
                async.waterfall [
                        (callback)->
                                program.prompt 'first name: ', (first_name)->
                                        user = {first_name: first_name}
                                        callback(null, user)
                        ,(user, callback)->
                                program.prompt 'last name: ', (last_name)->
                                        user.last_name = last_name
                                        callback(null, user)
                        ,(user, callback)->
                                program.prompt 'email: ', (email)->
                                        # TODO test if email is available, if not switch to registration
                                        user.email = email
                                        callback(null, user)
                        ,(user, callback)->
                                program.password 'password: ', "*", (password)->
                                        user.password = password
                                        callback(null, user)
                        ,(user, callback)->
                                program.password 'confirm password: ', "*", (password_confirmation)->
                                        user.password_confirmation = password_confirmation
                                        process.stdin.destroy();
                                        callback(null, user)
                        ], (err, user)->
                                archer.register user, (err, user)->
                                        console.log(user == 'ok')

program.command("test")
        .description("Run the test suite")
        .action ()->
                archer.test complete

program.command("stop [pid]")
        .description("Stop the current application")
        .action (pid)->
                archer.stop pid, complete

program.command("start [name]")
        .description("Start the current application")
        .action (name)->
                archer.start name, complete

program.command("restart [pid]")
        .description("Restart the current application")
        .action (pid)->
                archer.restart pid, complete

program.command("ports")
        .description("Display the running port configuration")
        .action ()->
                archer.ports complete

program.command("jobs [name]")
        .description("Run a given job by name or list all available jobs")
        .action (name)->
                archer.job name, complete

program.command("servers [command]")
        .description("List all servers")
        .action (command)->
                if command == "add"
                        async.waterfall [
                                (cb)->
                                        program.prompt 'server address: ', (host)->
                                                console.log host
                                                cb(null, host)
                                (host, cb)->
                                        server =
                                                name: host
                                        cb(null, server)
                                ], (err, server)->
                                        archer.add_server server, completed
                else
                        archer.servers complete

program.command("version [command] [version]")
        .description("List or update the version of the current application")
        .action (command, version)->
                archer.version complete

                if command == "update"
                        # TODO prompt for version number unless version
                        program.prompt ''
                        archer.version version, complete

program.command("install [name]")
        .description("Install an application recipe by name or init file")
        .action (name)->
                archer.install name, complete

program.command("add [name]")
        .description("Install a dependency or component as necessary")
        .action (name)->

                unless name
                        program.prompt 'name', (name)->
                                archer.add_dependency name, complete
                else
                        archer.add_dependency name, complete

help_text = "#{bold}For usage information run:#{reset} archer --help"
program.command("*")
        .description("Fallback command")
        .action ()->
                console.log help_text

program.parse(process.argv)

unless process.argv[2]
        console.log help_text
