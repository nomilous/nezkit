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

            chain = narg.split('.')
            ref   = chain.shift()
            
            if ref == '_arg'

                targetArg = funcStr.match( new RegExp "(\\w*) = _arg.#{chain[0]}" )[1]

                #
                # "and final as flat"
                #
                chain.push targetArg unless chain[ chain.length - 1 ] == targetArg

            else if ref == '__ref'

                console.log funcStr

            nestings[targetArg] = chain

        modules.push _nested: nestings


                


