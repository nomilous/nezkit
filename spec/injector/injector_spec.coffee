require('nez').realize 'Injector', (Injector, test, context, should) -> 

    context 'Injector.inject()', (it) ->


        it 'is a function', (done) -> 

            Injector.inject.should.be.an.instanceof Function
            test done


        it 'injects a specified selection of objects', (done) -> 

            bozon = new (class Graviton)()

            loadedServices = false

            #
            # mock service loader
            #

            Injector.loadServices = (injectables, predefined) ->

                injectables.should.eql [
                    { name: 'pi' }
                    { name: 'graviton' }
                ]

                predefined.should.eql [
                    3.14159265359
                    bozon
                ]

                #
                # ensure service loader was called
                #

                loadedServices = true
                return predefined


            Injector.inject [3.14159265359, bozon], (pi, graviton) -> 

                loadedServices.should.equal true
                pi.should.equal 3.14159265359
                graviton.should.equal bozon
                test done



        it 'injects additional services per argument names', (done) -> 

            Injector.loadServices = (injX, preX) -> 

                injX[1].name.should.equal 'could'
                preX.push 'could'
                return preX

            Injector.inject [0], (zero, could) -> 

                could.should.equal 'could'
                test done




