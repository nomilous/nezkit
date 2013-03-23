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
                    { module: 'pi' }
                    { module: 'graviton' }
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

                injX[1].module.should.equal 'could'
                preX.push 'would'
                return preX

            Injector.inject [0], (zero, could) -> 

                could.should.equal 'would'
                test done


        it 'supports injection without predefined list', (done) -> 

            Injector.loadServices = (injX) -> 

                injX.length.should.equal 1
                injX[0].module.should.equal 'module'
                test done

            Injector.inject (module) -> 



        it 'supports injection using the argument scope heirarchy enabled by coffee-script', (done) -> 

            # 
            #  coffee> console.log '\n\n%s\n\n', require('coffee-script').compile ' (module:class:function:asArgName) -> '
            #  
            #  
            #  (function() {
            #  
            #    (function(_arg) {
            #      var asArgName;
            #      asArgname = _arg.module["class"]["function"];
            #    });
            #  
            #  }).call(this);
            #  
            #  

            Injector.loadServices = (injectables) -> 

                injectables.should.eql { module: 'africa' }
                return [animal: impala: prance: -> 'graceful']


            Injector.inject (africa:animal:impala:prance) -> 

                prance().should.equal 'graceful'
                test done

            



