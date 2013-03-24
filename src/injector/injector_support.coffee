module.exports = support = 

    fn2modules: (fn) ->

        modules = []
        funcStr = fn.toString()

        for arg in fn.fing.args

            module = arg.name

            if module.match /^_arg/

                #console.log '\n\n%s\n\n', funcStr

                nestings = {}

                for narg in funcStr.match /_(arg|ref)\.(\w*)/g

                    chain = narg.split('.')
                    ref   = chain.shift()
                    
                    if ref == '_arg'

                        targetArg = funcStr.match( new RegExp "(\\w*) = _arg.#{chain[0]}" )[1]

                        #
                        # "and final as flat"
                        #
                        chain.push targetArg unless chain[ chain.length - 1 ] == targetArg

                    nestings[targetArg] = chain

                modules.push _nested: nestings

            else

                modules.push module: arg.name

        #console.log JSON.stringify modules, null, 2

        return modules
