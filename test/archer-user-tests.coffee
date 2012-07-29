vows = require("vows")
should = require("should")
archer = require("../lib/archer")

vows.describe("Working with a user in Archer")
        .addBatch({
                "Valid user registration": {
                        topic: ()->
                                #user =
                                #        first_name: "Test"
                                #        last_name: "User"
                                #        email: "test@onfrst.com"
                                #        password: "asdf1234"
                                #        password_confirmation: "asdf1234"
                                #console.log(user, archer)
                                #archer.register user, @callback
                                @callback()
                                return

                        "should return a registered user": (err, user)->
                                #should.not.exist(err)
                                #should.exist(user)
                                #user.should.have.property('id')
                }
        }).export(module)