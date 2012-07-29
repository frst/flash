vows = require("vows")
should = require("should")
archer = require("../lib/archer")

vows.describe("Working with a user in Archer")
        .addBatch({
                "Valid user registration": {
                        topic: ()->
                                archer.deploy '../example', @callback
                                return

                        "should return a registered user": (err, response)->
                                should.not.exist(err)
                                should.exist(response)
                }
        }).export(module)