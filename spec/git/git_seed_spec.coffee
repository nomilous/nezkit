require('nez').realize 'GitSeed', (GitSeed, test, context, should) -> 


    #
    # mock package plugin
    #

    Plugin = 

        Package: class MockPackage

            constructor: (@property) -> 

            @search = (root, Plugin, callback) -> 

                callback null, [

                    new Plugin.Package 'REPO1'
                    new Plugin.Package 'REPO2'

                ]
            

        Shell: {}


    context 'GitSeed.init()', (it) ->

        it 'searches for git repos', (And, findit) -> 

            And 'saves the .git-seed file', (done, fs) ->

                fs.writeFileSync = (path, contents) -> 

                    path.should.equal 'PATH/.git-seed'
                    test done

                GitSeed.init 'PATH', Plugin



            And 'initializes the GitSeed constituent GitRepo(s) array', (done) ->

                GitSeed.prototype.save = ->

                    @array.should.eql [

                        { property: 'REPO1' }
                        { property: 'REPO2' }
                        
                    ]

                    test done
                    
                GitSeed.init 'PATH', Plugin

