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
    # * superTask.resolve() - Will be called by this process on success
    # * superTask.reject() - Will be called by this process on failure
    # * superTask.notify[] - Will be used to communicate status updates into the superTask 
    # 
    # **superTask.notify** must be a configured instance of [notice](https://github.com/nomilous/notice)
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

            @superTask.notify.info.good 'saved seed', @control

        catch error

            @superTask.notify.info.bad 'save seed failed', error.toString()
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


    status: (callback) -> GitSeed.action 'status', @Plugin.Package, @array, @superTask, callback
    clone:  (callback) -> #@action 'clone',  callback



    @action: (action, Repo, repoArray, superTask, callback) -> 

        event = superTask.notify.event
        info  = superTask.notify.info

        succeed = (results) -> 

            #
            # a successful seed clone is elevated
            # to an event (notice)
            # 

            switch action

                when 'clone' then event.good "seed #{action}", 'success'
                else info.good "seed #{action}", 'success'

            info.good  "seed #{action} results", results: results
            callback null, results

        fail   = (error)   -> 

            switch action

                when 'clone' then event.bad "seed #{action}", 'failed'
                else info.bad "seed #{action}", 'failed'

            info.bad  "seed #{action} error", error: error
            callback error

        targs = []
        sequence( 

            for repo in repoArray

                targs.unshift repo
                -> nodefn.call Repo[action], targs.pop(), superTask

        ).then succeed, fail



    #     cloneAll = []
    #     targets  = []

    #     for repo in @array

    #         # targets.unshift repo
    #         # cloneAll.push targets.pop().clone()
    #         cloneAll.push -> 

    #             console.log 'clone'
    #             defer = w.defer()
    #             targets.pop().clone defer
    #             defer.promise

    #     sequence( cloneAll ).then(

    #         success = (result) => @install callback
    #         failed = (reason) -> callback reason 

    #     )

    # install: (callback) -> 

    #     installAll = []
    #     targets    = []

    #     for repo in @array

    #         targets.unshift repo
    #         installAll.push -> targets.pop().install()


    #     sequence( installAll ).then(

    #         success = (result) -> callback result
    #         failed = (reason) -> callback reason 

    #     )


module.exports = GitSeed
