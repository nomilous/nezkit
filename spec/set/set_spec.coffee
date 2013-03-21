require('nez').realize 'Set', (Set, test, context, should) -> 

    context 'series()', (it) ->

        it 'throws on missing mandatory args', (done) -> 

            try 

                Set.series targets: [], args: []
                throw 'missing throw'

            catch error

                error.should.match /missing opts\.function/
                test done


        it 'requires targets and args as arrays', (done) -> 

            try 

                Set.series targets: [], function: 'action', args: {}
                throw 'missing throw'
                  
            catch error

                error.should.match /opts\.targets should be array/
                test done

    