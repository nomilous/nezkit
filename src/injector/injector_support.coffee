module.exports = support = 

    fn2modules: (fn) ->

        modules = []

        for arg in fn.fing.args

            module = arg.name

            if module.match /^_arg/

                console.log '\n\n%s\n\n', fn.toString()

                nestings = []

                for narg in fn.toString().match /_(arg|ref)\.(\w*)/g

                    chain = narg.split('.')

                    nested = []
                    name   = chain[1]
                    depth  = chain.length 

                    if fn.toString().match new RegExp "#{name} = _arg.#{name}"

                        #
                        # "and final as flat"
                        #

                        depth = 1

                    nested.push depth
                    nested.push name

                    nestings.push nested

                modules.push _nested: nestings

            else

                modules.push module: arg.name

        #console.log JSON.stringify modules, null, 2

        return modules
