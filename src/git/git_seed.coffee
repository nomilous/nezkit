fs      = require 'fs'
colors  = require 'colors'  
GitRepo = require './git_repo'
series  = require('../set/set').series


#
# **class** `GitSeed`
# *injectable* `nezkit$git$seed`
#
# A collection of GitRepo(s) that collectively define 
# a deployable unity.
#

class GitSeed

    @init: (root) -> 

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

            repoArray = []
            seq = 0

            for path in arrayOfGitWorkdirs

                repoArray.push GitRepo.init path, seq++

            tree = new GitSeed root, repoArray
            tree.save()


    constructor: (@root, list) -> 

        @control = "#{@root}/.git-seed"

        if list instanceof Array

            @array = list

        else if typeof list == 'undefined'

            @array = @load()

    save: -> 

        try



            fs.writeFileSync @control, 
                JSON.stringify( @array, null, 2 )

            console.log '(write)'.green, @control

        catch error

            console.log error.red
            throw error


    load: -> 

        try 

            throw '' unless fs.lstatSync(  @control  ).isFile()

        catch error

            require('./git_action').exitCode = 2
            throw "explected control file: #{@control}"

        try

            json = JSON.parse fs.readFileSync @control

            array = []

            for properties in json

                array.push new GitRepo properties

            return array

        catch error

            require('./git_action').exitCode = 3
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
