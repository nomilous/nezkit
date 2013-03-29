fs         = require 'fs'
colors     = require 'colors'
series     = require('../set/set').series


#
# **class** `GitSeed`
#
# A collection of Packages(s) that collectively define 
# a deployable unity.
#

class GitSeed

    @init: (root, Plugin) -> 

        arrayOfGitWorkdirs = []
        list  = {}
        find  = require('findit').find root

        find.on 'directory', (dir, stat) -> 

            if match = dir.match /(.*)\/.git\//

                return unless typeof list[match[1]] == 'undefined'

                console.log '(found)'.green, "#{match[1]}/.git"
                list[match[1]] = 1
                arrayOfGitWorkdirs.push match[1]


        find.on 'end', ->

            packages = []
            seq = 0

            for path in arrayOfGitWorkdirs

                packages.push Plugin.Package.init path, seq++

            tree = new GitSeed root, Plugin, packages
            tree.save()


    constructor: (@root, Plugin, list) -> 

        @control = "#{@root}/.git-seed"

        if list instanceof Array

            @array = list

        else if typeof list == 'undefined'

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
            repo.printStatus()


    clone: (callback) -> 

        series
            targets: @array
            action: 'clone', callback


    commit: (message, callback) ->

        series
            targets: @array
            action: 'commit', [message], callback


    noControl: (ex) ->

        throw error = ex || new Error( 

            'Expected control file, not this:' + @control

        )



module.exports = GitSeed
