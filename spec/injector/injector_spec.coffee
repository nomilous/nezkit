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