require('nez').realize 'GitSeed', (GitSeed, test, context, should) -> 


    #
    # mock package plugin
    #

    Plugin = 

        Package: class MockPackage

            constructor: (properties) ->

                for key of properties

                    @[key] = properties[key]


            @search = (root, Plugin, callback) -> 

                callback null, [

                    new Plugin.Package property: 'REPO1'
                    new Plugin.Package property: 'REPO2'

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


    context 'GitSeed.clone()', (it) -> 

        it 'clones all repos in the .git-seed file and calls the package manager to install', (done, fs) -> 

            fs.lstatSync = -> isFile: -> true
            fs.readFileSync = -> """[

                {
                    "root": true,
                    "path": ".",
                    "origin": "git@github.com:nomilous/git-seed.git",
                    "branch": "refs/heads/develop",
                    "ref": "ROOT_REPO_REF"
                }

            ]"""

            Plugin.Package.prototype.clone   = (callback) -> callback null, null
            Plugin.Package.prototype.install = (callback) -> callback null, 'INSTALLED'

            gitSeed = new GitSeed '.', Plugin

            gitSeed.clone (error, result) -> 

                result.should.eql ['INSTALLED']
                test done


