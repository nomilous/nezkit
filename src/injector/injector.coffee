support = require './injector_support'

injector = 
    

    #
    # **function** `injector.inject (module [,module2, ...]) ->` 
    # **function** `injector.inject [list,of,objects], (list, of, objects, module [,module2, ...]) ->`
    # 
    # Injects modules by name into the function at lastarg.
    # 
    # 
    # *Usage*
    # 
    # <pre>
    #
    #    inject [1,2,3], (one, two, three, should) -> 
    #
    #        should.should.equal require 'should'
    #        one.should.equal   1
    #        two.should.equal   2
    #        three.should.equal 3
    #
    # </pre>
    # 

    inject: ->

        if typeof arguments[0] == 'function' 

            fn = arguments[0]
            fn.apply null, injector.loadServices support.fn2modules fn

        else

            list = arguments[0]

            #
            # fn as last argument
            #

            for key of arguments

                #
                # function is the last argument
                #

                fn = arguments[key]

            # console.log "LIST:", list

            fn.apply null, injector.loadServices support.fn2modules( fn ) , list



module.exports = injector