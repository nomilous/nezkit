require('nez').realize 'InjectorSupport', (InjectorSupport, test, it, should) -> 

    it 'converts function arguments to module definitions', (done) ->

        InjectorSupport.fn2modules( 

            (humpty, dumpty) -> 

        ).should.eql [
        
            { module: 'humpty' }
            { module: 'dumpty' }

        ]

        test done


    it 'supports : delimited hierarchy for foussed injection', (With) -> 

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


        With 'a test that fails if future coffee-script compiler output changes', (done) -> 

            require('coffee-script').compile(

                '(a, b:c, d:e:f, g) -> '

            ).should.match(

                /c = _arg\.b, \(_ref = _arg\.d, f = _ref\.e, g = _ref\.g\);/

            )

            require('coffee-script').compile(

                '(a, b:c, d:e:f, g) -> '

            ).should.match(

                /function\(a, _arg\)/

            )

            test done


        With 'all having uniform depth', (done) -> 

            InjectorSupport.fn2modules(

                (mod1:class1, mod2:class2, mod3:class3) -> 

            ).should.eql [{ 

                _nested: 

                    class1: ['mod1','class1']   # all these need to be injected as
                    class2: ['mod2','class2']   # the single _arg as compiled
                    class3: ['mod3','class3']   #                 
                
            }]

            test done


        With 'inital "and final as flat"', (done) -> 

            InjectorSupport.fn2modules(

                (mod0, mod1, mod2:class2, mod3:class3, mod4) -> 

            ).should.eql [
                {module: 'mod0'}
                {module: 'mod1'}
                {
                    _nested: {

                        class2: ['mod2', 'class2']
                        class3: ['mod3', 'class3']
                        mod4:   ['mod4']  

                    }
                }
            ]

            test done


        With 'mixed depth and deepest firts', (done) -> 

            InjectorSupport.fn2modules(

                (mod0, mod1:class1:function1, mod2:class2, mod3:class3, mod4) -> 
                    '(mod0, mod1:class1:function1, mod2:class2, mod3:class3, mod4)'

            ).should.eql [

                {module: 'mod0'}
                {
                    _nested: {

                        function1: ['mod1','class1','function1']
                        class2:    ['mod2', 'class2']
                        class3:    ['mod3', 'class3']
                        mod4:      ['mod4']  

                    }
                }
            ]

            test done


        With 'mixed depth and deepest middle', (done) -> 

            
            InjectorSupport.fn2modules(

                (mod0, mod2:class2, mod1:class1:function1, mod3:class3, mod4) -> 
                    '(mod0, mod2:class2, mod1:class1:function1, mod3:class3, mod4)'

            ).should.eql [

                {module: 'mod0'}
                {
                    _nested: {

                        class2:    ['mod2', 'class2']
                        function1: ['mod1','class1','function1']
                        class3:    ['mod3', 'class3']
                        mod4:      ['mod4']  

                    }
                }
            ]

            test done


        With 'mixed depth and deepest almost last', (done) -> 

            InjectorSupport.fn2modules(

                (mod0, mod2:class2, mod1:class1:function1, mod4) -> 

            ).should.eql [

                {module: 'mod0'}
                {
                    _nested: {

                        class2:    ['mod2', 'class2']
                        function1: ['mod1','class1','function1']
                        mod4:      ['mod4']  

                    }
                }
            ]

            test done


        With 'mixed depth and deepest last', (done) -> 

            InjectorSupport.fn2modules(

                (mod0, mod2:class2, mod4, mod1:class1:function1) -> 

            ).should.eql [

                {module: 'mod0'}
                {
                    _nested: {

                        class2:    ['mod2', 'class2']
                        mod4:      ['mod4']  
                        function1: ['mod1','class1','function1']
                        

                    }
                }
            ]

            test done
