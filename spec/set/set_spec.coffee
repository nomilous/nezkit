require('nez').realize 'Set', (Set, test, context, should) -> 

    context 'series()', (it) ->

        it 'throws on missing mandatory args', (done) -> 

            try 

                Set.series targets: []
                throw 'missing throw'

            catch error

                error.should.match /undefined opts\.function/
                test done


        it 'requires targets and args as arrays', (done) -> 

            try 

                Set.series targets: {}, function: 'action'
                throw 'missing throw'
                  
            catch error

                error.should.match /opts\.targets should be array/
                test done

        it 'requires a callback as arg1', (done) -> 

            try

                Set.series 

                    targets: []
                    function: 'action'

                throw 'missing throw'

            catch error

                error.should.match /undefined callback in set\.series/
                test done


        it 'calls back afterEach and afterAll'

        it 'calls back with the original calling context'