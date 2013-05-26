fs         = require 'fs'
sequence   = require 'when/sequence'
nodefn     = require 'when/node/function'

#
# **class** `GitSeed`
# ===================
#
# A collection of Packages(s) that collectively define 
# a deployable unity.
#

#
# Pending features
# ----------------
# 
# * (perhaps?) add an _authorized_.githubforks / feature/branches array to EACH repo 
#              in the seedfile so that a cumulative HEAD can be automerged onto a test 
#              server - to enable a view into the overall progress across a distributed
#              development effort.
# 
#              this will also be handy in catching merge conflicts early - when the _team_
#              is most capable of resolving them expediently
# 

class GitSeed


    #
    # GitSeed.init(root, Plugin, superTask)
    # -------------------------------------
    # 
    # Assembles the git-seed control file
    # 
    # ### root 
    # 
    # The directory containing the root repository.
    # 
    # 
    # ### Plugin
    # 
    # Should define Plugin.Package as the definition of an implementation that extends the 
    # baseclass [git-seed-core.GitRepo](https://github.com/nomilous/git-seed-core/blob/master/src/git_repo.coffee) 
    # and overrides the [install class method](https://github.com/nomilous/git-seed-npm/blob/master/src/npm_package.coffee) to perform any
    # post seed package manager activities (eg. npm install).
    # 
    # 
    # ### superTask
    # 
    # As the [promise] made by the parent process (or its parent, or it'sit's parent, or... 
    # 
    #    As the yank!
    # 
    #       For a chain that could escalate...  
    #    
    #             IF NOTH!NG GOES WELL
    #  
    #     ...all the way up the Chairman's iKnow
    # 
    # 
    # * superTask.resolve() - superTask has succeeded
    # * superTask.reject()  - superTask has failed permanently
    # * superTask.notify[] -  to send status updates into the superTask 
    # 
    # #### Notes
    # 
    # * superTask will not be resolved() or rejected() by git-seed, that is a
    #   responsibility of whichever higher entity in the objective heirarchy
    #   made the call to git-seed.
    # * superTask.notify[] **must** be a configured instance of 
    #   [notice](https://github.com/nomilous/notice)
    # 
    # 

    @init: (root, Plugin, superTask) -> 

        #
        # deferral as promise object
        # should define deferral.resolve(), deferral.reject() and deferral.notify()
        #
        # deferral.notify() must be an instance of [notice]()
        # 

        Plugin.Package.search root, Plugin, superTask, (error, packages) -> 

            tree = new GitSeed root, Plugin, superTask, packages
            tree.save()


    constructor: (@root, @Plugin, @superTask, array) -> 

        if (

            typeof @superTask.resolve != 'function' or 
            typeof @superTask.reject != 'function' or
            typeof @superTask.notify != 'function'

        ) then throw new Error "#{ @constructor.name } requires superTask as deferral"

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

            #
            # new seed file generated is elevated to an event (notice)
            # it includes the seed itself at event.content.seed
            #

            @superTask.notify.event.good 'seed update', 
                description: "wrote file: #{@control}"
                seed: @array

        catch error

            @superTask.notify.info.bad 'seed update failed', error.toString()
            throw error


    load: (Plugin) -> 

        try 

            throw '' unless fs.lstatSync(  @control  ).isFile()

        catch error

            throw "expected control file: #{@control}"

        try

            json = JSON.parse fs.readFileSync @control

            array = []

            for properties in json

                array.push new Plugin.Package properties

            return array

        catch error

            throw "error loading control file: #{@control} #{error.toString()}"


    status: (callback) -> GitSeed.action 'status', {}, @Plugin.Package, @array, @superTask, callback
    commit: (message, callback) -> GitSeed.action 'commit', {message: message}, @Plugin.Package, @array, @superTask, callback
    clone:  (callback) -> 

        #
        # clone run is followed by an install run with whichever package manager plugin 
        # is provided. 
        # 
        # note that each repo in the seed file has a specified manager, this is currently
        # ignored... the same manager (@Plugin.Package) is used for all
        #

        sequence( [

            => nodefn.call GitSeed.action, 'clone',   {}, @Plugin.Package, @array, @superTask
            => nodefn.call GitSeed.action, 'install', {}, @Plugin.Package, @array, @superTask

        ] ).then( 

            (results) -> if callback then callback null, results 
            (error)   -> if callback then callback error

        )

    


    @action: (action, args, Repo, repoArray, superTask, callback) -> 

        event = superTask.notify.event
        info  = superTask.notify.info

        succeed = (results) -> 

            #
            # a successful seed clone is elevated
            # to an event (notice)
            # 

            switch action

                when 'clone','install' then event.good "seed #{action}", 'success'
                else info.good "seed #{action}", 'success'

            info.good  "seed #{action} results", results: results
            callback null, results

        fail   = (error)   -> 

            switch action

                when 'clone','install' then event.bad "seed #{action}", 'failed'
                else info.bad "seed #{action}", 'failed'

            info.bad  "seed #{action} error", error: error
            callback error

        targs = []
        sequence( 

            for repo in repoArray

                targs.unshift repo
                -> nodefn.call Repo[action], targs.pop(), args, superTask

        ).then succeed, fail

module.exports = GitSeed
