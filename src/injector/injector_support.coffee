module.exports = support = 

    fn2modules: (fn) ->

        modules = []

        for arg in fn.fing.args

            modules.push 

                module: arg.name

        return modules
