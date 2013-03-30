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

        Plugin.Package.search root, Plugin, (error, packages) -> 

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
            action: 'clone', (error, result) => 

                #
                # all clones done, callback and exit if error
                # 

                if error

                    callback error, results
                    return

                #
                # no errors, perform package manager install 
                # and callback the final result
                #

                # TODO: commandline -no-auto-install to disable this

                series

                    targets: @array
                    action: 'install', callback


    commit: (message, callback) ->

        series

            targets: @array
            action: 'commit', [message], callback

    pull: (gitSeed, callback) -> 

        unless gitSeed

            #
            # seed not specified (only fetch root repo)
            #

            @array[0].pull callback
            return

        #
        # seed was specified and now contains the latest
        # branches/refs for each repo 
        #
        # populate target list with all but the root repo
        # 

        targets = []
        last    = gitSeed.array.length - 1

        for repo in gitSeed.array[1..last]

            targets.push repo

        #
        # make calls to Repo.pull() in series and 
        # supply the final callback for passthrough
        #

        series

            targets: targets
            action: 'pull', (error, result) => 

                if error

                    callback error, results
                    return

                #
                # TODO: only install where pull was necessary
                #

                series

                    targets: @array
                    action: 'install', callback


    noControl: (ex) ->

        throw error = ex || new Error( 

            'Expected control file, not this:' + @control

        )



module.exports = GitSeed
