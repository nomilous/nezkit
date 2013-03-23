#
# **function** `set.series( opts, args, callback )`
# *Injectable* `nezkit$set$series`
# 
# *Usage*
# 
# <pre>
#
#   series 
#
#
#       #
#       # array of objects to action() on
#       #
#
#       targets: [ object1, object2 ] 
#
#       afterEach: (err, result) ->
#
#           #
#           # Optional callback to receive the callback
#           # passed onward from each object.action()
#           # call in the series
#           #  
#           # and passed directlythrough from the
#           # eachobject after the action()
#           #
#
#
#       #
#       # The action/functionName and args to call on each 
#       # object. Object.functionName should accept an 
#       # (err, result) callback as lastarg.
#       #
#
#       action: 'functionName', ['arg1', 'arg2'], (error, results) -> 
#
#           #
#           # The final callback receives an array of the results
#           # accumulated from each object.functionName() call 
#           # in the series. 
#           #
# 
# </pre>
# 

set = 

    series : -> 

        opts = arguments[0]

        for required in ['targets', 'action']

            if typeof opts[required] == 'undefined'

                throw new Error "undefined opts.#{required} in set.series(opts, args, callback)"


        unless opts.targets instanceof Array

            throw new Error "opts.targets should be array in set.series(opts, args, callback)"


        action    = opts.action
        targets   = []
        results   = []
        afterEach = opts.afterEach || ->
        args      = if arguments[1] instanceof Function then [] else arguments[1]
        afterAll  = arguments[2] || arguments[1]

        unless afterAll instanceof Function

            throw new Error "undefined callback in set.series(opts, args, callback)"


        #
        # shallow clone targetsArray, 
        # so's not to shift() the original
        # 

        for target in opts.targets

            targets.push target


        #
        # callback resursion
        # 
        # each call to target[action] will 
        # make this callback....
        #

        args.push (error, result) -> 

            #
            # ....which accumulates results and then recurses back
            #     or goes to finalCallback on error
            #

            afterEach error, result

            if error

                afterAll error, results
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


module.exports = series: set.series
