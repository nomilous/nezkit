require('nez').realize 'InjectorSupport', (InjectorSupport, test, it, should) -> 

    it 'converts function arguments to module definitions', (done) ->

        InjectorSupport.fn2modules( 

            (humpty, dumpty) -> 

        ).should.eql [
        
            { module: 'humpty' }
            { module: 'dumpty' }

        ]

        test done

