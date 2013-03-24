require('nez').realize 'Injector', (Injector, test, context, should, InjectorSupport) -> 

    context 'INTEGRATIONS', (it) -> 

        it 'injects npm modules, or their functions and subcomponents', (done) -> 

            Injector.inject (findit, async:waterfall) -> 

                findit.should.equal require 'findit'
                waterfall.should.equal require('async').waterfall
                test done


        it 'can to that in the opposite order', (done) -> 

            Injector.inject (findit:find, async) -> 

                find.should.equal require('findit').find
                async.should.equal require 'async'
                test done


        it 'can inject positionally as specified', (done) -> 

            Injector.inject [ should, should ], (could, would) -> 

                (should == would == could).should.equal true is not false
                test done 


        it 'can do some fairly interesting things', (done) -> 

            Injector.inject [ 
                -> # some()
                -> # fairly()
                -> # interesting()
                -> # things()
                -> # can()
                (good) -> test good

            ], (some, fairly, interesting, things, can, be) -> 

                some fairly interesting things can be done


        it 'can inject local modules by using CamelCase', (done) -> 

            Injector.inject (GitRepo) -> 

                GitRepo.should.equal require '../../lib/git/git_repo'
                test done


        it 'can inject local module subcomponents', (done) -> 

            Injector.inject (Set:series, GitSeed) ->

                series.should.equal require('../../lib/set/set').series
                GitSeed.should.equal require '../../lib/git/git_seed'
                test done


        it 'can inject a mixture of services', (done) -> 

            Injector.inject [should], (does, Set:series, GitSeed) ->

                does.not.exist()
                series.should.equal require('../../lib/set/set').series
                GitSeed.should.equal require '../../lib/git/git_seed'
                test done


    context 'Injector.inject()', (it) ->


        it 'is a function', (done) -> 

            Injector.inject.should.be.an.instanceof Function
            test done


        it 'injects a specified selection of objects', (done) -> 

            bozon = new (class Graviton)()

            loadedServices = false

            #
            # mock loadServices
            #

            InjectorSupport.loadServices = (injectables, predefined) ->

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

            #
            # mock loadServices
            #

            InjectorSupport.loadServices = (injX, preX) -> 

                injX[1].module.should.equal 'could'
                preX.push 'would'
                return preX

            Injector.inject [0], (zero, could) -> 

                could.should.equal 'would'
                test done


        it 'supports injection without predefined list', (done) -> 

            #
            # mock loadServices
            #

            InjectorSupport.loadServices = (injX) -> 

                injX.length.should.equal 1
                injX[0].module.should.equal 'module'
                test done

            Injector.inject (module) -> 

