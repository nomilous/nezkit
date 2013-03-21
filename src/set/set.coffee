module.exports = set = 

    # series: (targetsArray, functionName, args, finalCallback, stepCallback) ->

    series: (opts = {}, callback) -> 

        for required in ['targets', 'function', 'args']

            if typeof opts[required] == 'undefined'

                throw new Error "missing opts.#{required} in set.series(opts, cb)"


        for arrays in ['targets', 'args']

            unless opts[arrays] instanceof Array

                throw new Error "opts.targets should be array"



        return

        #
        # shallow clone targetsArray, 
        # so's not to shift() the original
        # 

        targets = []
        results = []
        args    = [] unless args

        for target in targetsArray

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

            if typeof stepCallback == 'function'

                stepCallback error, result

            if error

                finalCallback error, results
                return

            results.push result

            set.recurse results, targets, functionName, args, finalCallback


        #
        # start the recursion
        #

        set.recurse results, targets, functionName, args, finalCallback


    recurse: (results, targets, fname, args, finalCallback) -> 

        #
        # shift next from targets 
        # terminate recursion when none left
        # or make the call to functionName 
        #

        target = targets.shift() 
        unless target

            finalCallback null, results
            return


        target[fname].apply target, args

