fs           = require 'fs'
sequence     = require 'when/sequence'
nodefn       = require 'when/node/function'

SEED_VERSION = 2
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
# * (perhaps?) pre_checks ensures origin match between .git/config[remote.origin.url] 
#              and .git-seed [{origin:''},]
#   
#              perhaps only display warning on mismatch - because there are valid reasons
#              to operate an unusual .git/config[remote.origin.url] 
# 

class GitSeed


    #
    # GitSeed.init(superTask, root, Plugin)
    # -------------------------------------
    # 
    # Assembles the git-seed control file
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

    @init: (superTask, root, Plugin) -> 

        # 
        # * superTask will not be resolved() or rejected() by git-seed, that is a
        #   responsibility of whichever higher entity in the objective heirarchy
        #   made the call to git-seed.
        # * superTask.notify[] **must** be a configured instance of 
        #   [notice](https://github.com/nomilous/notice)
        # 

        Plugin.Package.search superTask, root, Plugin, (error, packages) -> 

            tree = new GitSeed superTask, root, Plugin, packages
            tree.save()


    constructor: (@superTask, @root, @Plugin, array) -> 

        if (

            typeof @superTask.resolve != 'function' or 
            typeof @superTask.reject != 'function' or
            typeof @superTask.notify.info.normal != 'function'

        ) then throw new Error "#{ @constructor.name } requires superTask"

        @control = "#{@root}/.git-seed"

        if array instanceof Array

            for repo in array

                repo.version = 'ROOT_REPO_REF' if repo.root

            @array = array

        else if typeof array == 'undefined'

            @array = @load Plugin

    save: -> 

        try

            fs.writeFileSync @control, 

                JSON.stringify {

                    version: SEED_VERSION
                    repos:   @array

                }, null, 2

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

            if typeof json.version == 'undefined'

                console.log """

                    Old .git-seed file detected!

                    updating to new format...

                """

                @array = []
                repos  = []

                for repo in json

                    newFormat = 

                        root:                repo.root
                        workDir:             repo.path
                        packageManager:      repo.manager
                        'remote.origin.url': repo.origin
                        'HEAD':              repo.branch
                        'version':           repo.ref

                    @array.push newFormat
                    repos.push newFormat


                @save()

                console.log """

                    IMPORTANT
                    ---------

                    before commiting the new .git-seed file consider that
                    other members of your team may still be using an older
                    git-seed version

                    the first version cannot handle unexpected format

                    IT WILL BLOW UP 

                """

            else 

                repos = json.repos

            @array = []

            for properties in repos

                array.push new Plugin.Package properties

            return array

        catch error

            throw "error loading control file: #{@control} #{error.toString()}"


    status: (callback) -> GitSeed.action @superTask, 'status', {}, @Plugin.Package, @array, callback
    commit: (message, callback) -> GitSeed.action @superTask, 'commit', {message: message}, @Plugin.Package, @array, callback
    clone:  (callback) -> 

        #
        # clone run is followed by an install run with whichever package manager plugin 
        # is provided. 
        # 
        # note that each repo in the seed file has a specified manager, this is currently
        # ignored... the same manager (@Plugin.Package) is used for all
        #

        sequence( [

            => nodefn.call GitSeed.action, @superTask, 'clone', {}, @Plugin.Package, @array
            => nodefn.call GitSeed.action, @superTask, 'install', {}, @Plugin.Package, @array

        ] ).then( 

            (results) -> if callback then callback null, results 
            (error)   -> if callback then callback error

        )

    pullRoot: (callback) -> 

        targets = [  @array[0]  ]

        nodefn.call( 

            GitSeed.action, @superTask, 'pull', {}, @Plugin.Package, targets

        ).then(

            (result)  -> if callback then callback null, result
            (error)   -> if callback then callback error

        )

    pull: (callback) -> 

        targets = @array[1..]
        @array

        sequence( [

            => nodefn.call GitSeed.action, @superTask, 'pull', {}, @Plugin.Package, targets
            => nodefn.call GitSeed.action, @superTask, 'install', {}, @Plugin.Package, @array

        ] ).then( 

            (results) -> if callback then callback null, results 
            (error)   -> if callback then callback error

        )


    @action: (superTask, action, args, Repo, repoArray, callback) -> 

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
                -> nodefn.call Repo[action], superTask, targs.pop(), args

        ).then succeed, fail

module.exports = GitSeed
