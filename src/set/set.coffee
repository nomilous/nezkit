module.exports = set = 

    
    #
    # **function** `set.series( opts, callback )`
    # 
    # Runs a specified function on a set of objects in series. 
    # 
    # `opts`           - As hash of args to configure the series.
    # 
    # `callback        - A standard callback, ie. function(error, result) 
    #                    to call upon completion of the series (or error)
    # 
    #                    The callback result will contain an array composed
    #                    of each individual result as called back from each
    #                    of the objects in the series.
    # 
    #
    # *Required opts:*
    # 
    # `opts.targets`   - Array of target objects.
    # 
    # `opts.function`  - The function to call on each target. This function 
    #                    is called with the targets scope and should accept 
    #                    a standard callback as lastarg.
    # 
    # *Optional opts:*
    # 
    # `opts.args`      - An array of args to pass into in each target.function.
    #                    The same args array instance is passed to each target.
    # 
    # `opts.afterEach` - As a function(error, result), to callback with the 
    #                    results from each individual target.function.
    # 
    # 
    #

    series: (opts = {}, callback) -> 

        for required in ['targets', 'function']

            if typeof opts[required] == 'undefined'

                throw new Error "undefined opts.#{required} in set.series(opts, callback)"


        for array in ['targets', 'args']

            if opts[array] 

                unless opts[array] instanceof Array

                    throw new Error "opts.#{array} should be array in set.series(opts, callback)"


        unless typeof callback == 'function'

            throw new Error "undefined callback in set.series(opts callback)"


        results   = []
        targets   = []
        action    = opts.function 
        args      = opts.args || []
        afterEach = opts.afterEach || ->
        afterAll  = callback

        #
        # shallow clone targetsArray, 
        # so's not to shift() the original
        # 

        for target in opts.targets

            targets.push target




        #
        # callback resursion
        # 
        # each call to target[functionName] will 
        # make this callback....
        #

        args.push (error, result) -> 

            #
            # ....which accumulates results and then recurses back
            #     or goes to finalCallback on error
            #

            afterEach error, result

            if error

                afterEach error, results
                return

            results.push result

            set.recurse results, targets, action, args, afterAll


        #
        # start the recursion
        #

        set.recurse results, targets, action, args, afterAll


    recurse: (results, targets, action, args, afterAll) -> 

        #
        # shift next from targets 
        # terminate recursion when none left
        # or make the call to functionName 
        #

        target = targets.shift() 
        unless target

            afterAll null, results
            return


        target[action].apply target, args

