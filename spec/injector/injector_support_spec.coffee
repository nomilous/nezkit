require('nez').realize 'InjectorSupport', (InjectorSupport, test, it, should) -> 

    it 'converts function arguments to module definitions', (done) ->

        InjectorSupport.fn2modules( 

            (humpty, dumpty) -> 

        ).should.eql [
        
            { module: 'humpty' }
            { module: 'dumpty' }

        ]

        test done


    it 'supports : delimited hierarchy', (With) -> 

        # 
        # console.log '\n%s\n', require('coffee-script').compile '(one, two:a, three:b)->'
        # 
        # (function() {
        # 
        #   (function(one, _arg) {
        #     var a, b;
        #     a = _arg.two, b = _arg.three;
        #   });
        # 
        # }).call(this);
        # 

        With 'all having uniform depth', (done) -> 

            InjectorSupport.fn2modules(

                (mod1:class1, mod2:class2, mod3:class3) -> 

            ).should.eql [{ 

                _nested: [       # 
                    [2,'mod1']   # all these need to be injected as
                    [2,'mod2']   # the single _arg as compiled
                    [2,'mod3']   # 
                                 # 
                                 # 
                ] 
            }]

            test done


        With 'inital "and final as flat"', (done) -> 

            InjectorSupport.fn2modules(

                (mod0, mod1, mod2:class2, mod3:class3, mod4) -> 

            ).should.eql [
                {module: 'mod0'}
                {module: 'mod1'}
                {
                    _nested: [ 

                        [2,'mod2']
                        [2,'mod3']
                        [1,'mod4']  # <----------- # starts getting tricky when flat
                                                   # injectables follow hierarchic ones
                    ] 
                }
            ]

            test done
