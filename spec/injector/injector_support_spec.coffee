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


        With 'all having uniform depth', (done) -> 

            InjectorSupport.fn2modules(

                (mod1:class1, mod2:class2, mod3:class3) -> 

            ).should.eql [

                { _nested: [ 'mod1', 'mod2', 'mod3' ] }

            ]

            test done
