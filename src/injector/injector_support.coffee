module.exports = support = 

    fn2modules: (fn) ->

        modules = []

        for arg in fn.fing.args

            module = arg.name

            if module.match /^_arg/

                console.log '\n\n%s\n\n', fn.toString()

                nested = []

                for narg in fn.toString().match /_(arg|ref)\.(\w*)/g

                    nested.push narg.split('.')[1]

                modules.push _nested: nested

            else

                modules.push module: arg.name

        return modules
