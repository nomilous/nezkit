require('nez').realize 'Kit', (Kit, test, it, should) -> 

    it 'is defined', (done) -> 

        should.exist Kit
        test done


    for toolset in ['shell', 'git', 'npm', 'coffee', 'set', 'injector']

        #
        # a possibly inappropriate approach to testing?
        #

        it "exports #{toolset}", (done) ->

            Kit[toolset].should.equal require "../lib/#{toolset}/#{toolset}"
            test done
