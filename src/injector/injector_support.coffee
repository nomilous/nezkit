module.exports = support = 

    fn2modules: (fn) ->

        modules = []

        for arg in fn.fing.args

            module = arg.name

            # if module.match /^_arg/
            #     nested = []
            #     for narg in fn.toString().match /_(arg|ref)\.(\w*)/g
            #         nested.push narg.split('.')[1]
            #     modules.push _nested: nested
            # else
            #     modules.push module: arg.name
            # 
            # 
            # Too much complexity per the following example:
            # 
            # - three:b:c results in two matches ('three' and 'b') as mosules to inject, 
            #   cant think of a way to detect that _ref.b does not refer to an injectable.
            # 
            # - 
            #
            # 
            # coffee> console.log '\n\n\n%s\n\n', require('coffee-script').compile '(one, two:a, three:b:c, four) ->'
            # 
            # (function() {
            # 
            #   (function(one, _arg) {
            #     var a, c, four, _ref;
            #     a = _arg.two, (_ref = _arg.three, c = _ref.b, four = _ref.four);
            #   });
            # 
            # }).call(this);
            # 
            # 
            # 
            # 
            
            modules.push module: arg.name

        return modules
