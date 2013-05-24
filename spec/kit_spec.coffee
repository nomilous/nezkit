require('nez').realize 'Kit', (Kit, test, it, should) -> 

    it 'is defined', (done) -> 

        should.exist Kit
        test done


    for toolset in ['coffee']

        #
        # a possibly inappropriate approach to testing?
        #

        it "exports #{toolset}", (done) ->

            Kit[toolset].should.equal require "../lib/#{toolset}/#{toolset}"
            test done

    it 'exports the (git) seed', (done) -> 

        Kit.seed.should.equal require '../lib/git/git_seed'
        test done

