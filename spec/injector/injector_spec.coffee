require('nez').realize 'Injector', (Injector, test, context, should) -> 

    context 'Injector.inject()', (it) ->

        it 'is a function', (done) -> 

            Injector.inject.should.be.an.instanceof Function
            test done
