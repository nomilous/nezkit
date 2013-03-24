module.exports = support = 

    fn2modules: (fn) ->

        modules = []
        funcStr = fn.toString()

        for arg in fn.fing.args

            module = arg.name

            if module.match /^_arg/

                if funcStr.match /_ref = _arg/

                    support.mixedDepth modules, funcStr
                    
                else

                    support.uniformDepth modules, funcStr

            else 

                modules.push module: arg.name

        return modules


    mixedDepth: (modules, funcStr) -> 

        # console.log '\n\n%s\n\n', funcStr
        # console.log JSON.stringify modules, null, 2


        #
        # (mod0, mod2:class2, mod1:class1:function1, mod3:class3, mod4) -> 
        # 
        # as: 
        # 
        #   'class2 = _arg.mod2, (_ref = _arg.mod1, function1 = _ref.class1, class3 = _ref.mod3, mod4 = _ref.mod4);'
        # 
        # is not possible to use without somehow jumping over the fact that:
        # 
        #   '_ref = _arg.mod1' and then 'class3 = _ref.mod3 // when _ref is still _arg.mod1'
        # 

        throw new Error 'Mixed depth focussed injection not yet supported'


    uniformDepth: (modules, funcStr) -> 

        nestings = {}

        for narg in funcStr.match /_(arg|ref)\.(\w*)/g

            chain     = narg.split('.')
            ref       = chain.shift()
            targetArg = funcStr.match( new RegExp "(\\w*) = _arg.#{chain[0]}" )[1]

            #
            # "and final as flat"
            #
            chain.push targetArg unless chain[ chain.length - 1 ] == targetArg

            nestings[targetArg] = chain

        modules.push _nested: nestings


    loadServices: (dynamic, preDefined = []) -> 


        skip = preDefined.length

        services = preDefined

        for config in dynamic

            continue if skip-- > 0


            if config._nested

                support.loadNested services, config._nested
                continue

            if config.module.match /^[A-Z]/

                #
                # Inject local module (from ./lib or ./app)
                #

                services.push support.findModule config

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

        services.push {}
        _arg = services[services.length - 1]

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

            support.loadServices rebuild, services
            nextService = services.pop()

            if defn.length > 1

                #
                # ''slide''
                #

                _arg[defn[0]] = nextService[name]

            else

                #
                # flat (no nesting)
                # 
                # necessary here because flat args that follow nested ones
                # also need to be appended into _arg, because...
                # 
                #    (flat1, module1:class1, flat2) -> 
                #      
                # ...becomes...
                # 
                #    function(flat1, _arg) {
                #        var class1, flat2;
                #        class1 = _arg.module1, flat2 = _arg.flat2;
                #    }
                #

                _arg[name] = nextService

