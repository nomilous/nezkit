fs         = require 'fs'
console.log 'remove colors'
colors     = require 'colors'
sequence   = require 'when/sequence' 

#
# **class** `GitSeed`
#
# A collection of Packages(s) that collectively define 
# a deployable unity.
#

class GitSeed

    @init: (root, Plugin, deferral) -> 

        #
        # deferral as promise object
        # should define resolve(), reject() and notify()
        #

        Plugin.Package.search root, Plugin, deferral, (error, packages) -> 

            tree = new GitSeed root, Plugin, deferral, packages
            tree.save()


    constructor: (@root, Plugin, @deferral, array) -> 

        if (

            typeof @deferral.resolve != 'function' or 
            typeof @deferral.reject != 'function' or
            typeof @deferral.notify != 'function'

        ) then throw new Error "#{ @constructor.name } requires deferral"

        @control = "#{@root}/.git-seed"

        if array instanceof Array

            for repo in array

                repo.ref = 'ROOT_REPO_REF' if repo.root

            @array = array

        else if typeof array == 'undefined'

            @array = @load Plugin

    save: -> 

        try

            fs.writeFileSync @control, 

                JSON.stringify( @array, null, 2 )

            console.log '(write)'.green, @control

        catch error

            console.log error.red
            throw error


    load: (Plugin) -> 

        try 

            throw '' unless fs.lstatSync(  @control  ).isFile()

        catch error

            throw "explected control file: #{@control}"

        try

            json = JSON.parse fs.readFileSync @control

            array = []

            for properties in json

                array.push new Plugin.Package properties

            return array

        catch error

            throw "error loading control file: #{@control} #{error.toString()}"


    status: -> 

        for repo in @array

            repo.getStatus @deferral



module.exports = GitSeed
