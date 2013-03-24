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


    loadServices: (dynamic, preDefined) -> 

        #console.log arguments

        skip = preDefined.length

        services = preDefined

        for config in dynamic

            continue if skip-- > 0


            if config._nested

                injector.loadNested services, config._nested
                continue

            if config.module.match /^[A-Z]/

                #
                # Inject local module (from ./lib or ./app)
                #

                services.push injector.findModule config

            else

                #
                # Inject installed npm module
                #

                module = require config.module
                services.push module


        #console.log "services:", services

        return services


    loadNested: (services, config) -> 

        #
        # This function ''slide''s the hierarchy
        # so that the coffee script...
        # 
        #   (module1:class1) -> 
        #      class1.method 'arg'
        # 
        # ...as compiled to javascript... 
        # 
        #   function( _arg ) {
        #       var class1 = _arg.module1;
        #       class1.method('arg');
        #   }
        # 
        # ...actually has module1.class1 loaded 
        #    into var class1
        # 
        #

        services.push {} # destined to be _arg (per above)

        for name of config

            #
            # re-arrange so that sending back through
            # loadServices has the necessary args
            # to append the specified service.
            #

            defn = config[name]
            rebuild = []

            for existing in services
                rebuild.push existing

            rebuild.push module: defn[0]

            #
            # send back through loadServices and then
            # pop off the new last service and insert
            # it into the 
            #

            injector.loadServices rebuild, services

            nextService = services.pop()

            #
            # append this service into _arg
            #

            if defn.length > 1

                #
                # ''slide''
                #

                services[ services.length - 1 ][defn[0]] = nextService[name]

            else

                services[ services.length - 1 ][name] = nextService


module.exports = injector