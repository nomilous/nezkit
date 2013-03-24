require('nez').realize 'Injector', (Injector, test, context, should) -> 

    context 'Injector.loadServices()', (it) -> 

        it 'loads modules dynamically', (done) -> 

            try

                Injector.loadServices [ module: 'name' ], []

            catch error

                error.should.match /Cannot find module 'name'/
                test done


        it 'loads npm modules dynamically in addition to preDefined modules', (done) -> 

            Injector.loadServices( 

                [ 
                    {module: 'preDefined1'}
                    {module: 'preDefined2'}
                    {module: 'should'}
                    {module: 'nez'}
                ]
                ['preDefined1', 'preDefined2'] 

            ).should.eql [

                'preDefined1'
                'preDefined2'
                require 'should'
                require 'nez'

            ]

            test done


        it 'loads local modules when CamelCase', (done) -> 

            searchedCount = 0

            #
            # mock findModule
            #

            Injector.findModule = (config) -> 
                
                return "Fake#{config.module}"
                
            Injector.loadServices( 

                [ 
                    {module: 'LocalModule1'}
                    {module: 'should'}
                    {module: 'LocalModule2'}

                ], []

            ).should.eql [

                'FakeLocalModule1'
                require 'should'
                'FakeLocalModule2'

            ]

            test done


        it 'arranges _arg for the focussed injection', (done) -> 

            services = [
                {module: 'mod0'}
                {module: 'mod1'}
                {
                    _nested: {
                        class2: ['Mod2', 'class2']
                        class3: ['Mod3', 'class3']
                        Mod4:   ['Mod4']  
                    }
                }
            ]

            preDefined = ['mod0', 'mod1']

            #
            # mock findModule
            #

            Injector.findModule = (config) -> 
                
                switch config.module

                    when 'Mod2' then return class2: 'class2'
                    when 'Mod3' then return class3: 'class3'
                    when 'Mod4' then return 'Mod4'

            services = Injector.loadServices( services, preDefined )

            services.should.eql [
                'mod0'
                'mod1'
                { 
                    Mod2: 'class2'
                    Mod3: 'class3'
                    Mod4: 'Mod4' 
                }
            ]


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

            #
            # mock loadServices
            #

            Injector.loadServices = (injX, preX) -> 

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

            Injector.loadServices = (injX) -> 

                injX.length.should.equal 1
                injX[0].module.should.equal 'module'
                test done

            Injector.inject (module) -> 

