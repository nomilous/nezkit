require('nez').realize 'InjectorSupport', (InjectorSupport, test, it, should) -> 

    it 'converts function arguments to module definitions', (done) ->

        InjectorSupport.fn2modules( 

            (humpty, dumpty) -> 

        ).should.eql [
        
            { module: 'humpty' }
            { module: 'dumpty' }

        ]

        test done

    it 'supports args with hierarchy', (done) -> 

        InjectorSupport.fn2modules(

            (module1, module2:class2, module3:class3, module4:class4) -> 

        ).should.eql [

            { module: 'module1' }
            { _nested: ['module2', 'module3', 'module4'] }

        ]

        test done
