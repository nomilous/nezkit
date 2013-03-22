require('nez').realize 'Set', (Set, test, context, should) -> 

    context 'series()', (it) ->

        it 'throws on missing mandatory args', (done) -> 

            try 

                Set.series targets: []
                throw 'missing throw'

            catch error

                error.should.match /undefined opts\.action/
                test done


        it 'requires targets and args as arrays', (done) -> 

            try 

                Set.series targets: {}, action: 'action'
                throw 'missing throw'
                  
            catch error

                error.should.match /opts\.targets should be array/
                test done

        it 'requires a callback as arg2', (done) -> 

            try

                Set.series 

                    targets: []
                    action: 'action'

                throw 'missing throw'

            catch error

                error.should.match /undefined callback in set\.series/
                test done


        it 'calls back afterEach and afterAll', (done) -> 

            seq = 0
            aSetOfThings = [] 

            for num in [1..500]

                aSetOfThings.push new (

                    class SomeKindOfThing

                        constructor: (@seq) -> 

                        functionName: (arg1, arg2, arg3, callback) ->

                            arg3.push @seq * arg2

                            callback null, "#{@constructor.name} with #{@seq * arg1 * arg2}"

                )( seq++ )


            eachCalledCount = 0
            arg1 = 2
            arg2 = 0.5
            arg3 = []

            Set.series

                targets: aSetOfThings

                afterEach: (error, result) -> 

                    result.should.equal "SomeKindOfThing with #{eachCalledCount++}"

                action: 'functionName', [arg1, arg2, arg3], (error, result) ->

                    result[result.length - 1].should.equal 'SomeKindOfThing with 499'
                    eachCalledCount.should.equal 500
                    arg3[499].should.equal 499 / 2
                    test done



        it 'calls back with the original calling context', (done) ->

            @callbackContext = 'this'

            Set.series

                targets: [

                    { doSomething: (callback) -> callback null, 'ONE' }
                    { doSomething: (callback) -> callback null, 'TWO' }
                    new (
                        class Thing 
                            doSomething: (cb) -> 
                                cb null, 'THING__3'
                    )()

                ]

                action: 'doSomething', (err, res) ->

                    res.should.eql ['ONE', 'TWO', 'THING__3']
                    @callbackContext.should.equal 'this'
                    test done


        it 'calls back with error', (done) -> 

            x = new Error 'ERROR'

            Set.series

                targets: [ fn: (cb) -> cb x ]

                action: 'fn', (error, results) -> 

                    error.should.equal x
                    test done


        it 'stops execution of the series upon error', (done) ->

            secondActionRan = false
            calledAfterEach = false

            Set.series

                targets: [ 

                    { fn: (cb) -> cb new Error 'first action failed' }
                    { fn: (cb) -> 
                        secondActionRan = true 
                        cb null, 'ok' 
                    } 

                ]

                afterEach: (error, result) -> 

                    error.should.match /first action failed/
                    calledAfterEach = true


                action: 'fn', (error, results) -> 

                    error.should.match /first action failed/
                    secondActionRan.should.equal false
                    calledAfterEach.should.equal true
                    test done


        it 'can optionally be configured to traverse the series in reverse'
        it 'will default to terminating the series on error an populate the error into the callback'
        it 'can optionally be configured complete the series and populate all the errors into the callback as an array'




            #console.log do:ne()
            # # Set.series
            # #     targets: []
            #     console.log actions:
            #         function1: 
            #             args: ['arg1', 'arg2']
            #             callback: ->
            #         function2: 
            #             args: []
            #             callback: ->
                
