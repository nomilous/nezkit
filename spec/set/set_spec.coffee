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

        it 'requires a callback as arg2', (done) -> 

            try

                Set.series 

                    targets: []
                    function: 'action'

                throw 'missing throw'

            catch error

                error.should.match /undefined callback in set\.series/
                test done


        it 'calls back afterEach and afterAll', (done) -> 

            seq = 0
            aSetOfThings = [] 

            for num in [1..500]

                aSetOfThings.push new (

                    class Thing

                        constructor: (@seq) -> 

                        action: (arg1, arg2, callback) ->

                            callback null, "#{@constructor.name} with #{@seq * arg1 * arg2}"

                )( seq++ )


            eachCalledCount = 0

            Set.series

                targets: aSetOfThings

                args: [2, 0.5]

                afterEach: (errir, result) -> 

                    result.should.equal "Thing with #{eachCalledCount++}"

                function: 'action', (error, result) ->

                    result[result.length - 1].should.equal 'Thing with 499'
                    eachCalledCount.should.equal 500
                    test done



        it 'calls back with the original calling context'