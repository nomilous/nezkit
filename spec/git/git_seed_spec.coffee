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


    context 'GitSeed.clone()', (it, fs) -> 

        fs.lstatSync = -> isFile: -> true
        fs.readFileSync = -> """[

            {
                "root": true,
                "path": ".",
                "origin": "git@github.com:nomilous/git-seed.git",
                "branch": "refs/heads/develop",
                "ref": "ROOT_REPO_REF",
                "manager": "npm"
            }

        ]"""

        Plugin.Package.prototype.clone   = (callback) -> callback null, null
        Plugin.Package.prototype.install = (callback) -> callback null, 'INSTALLED'


        it 'clones all repos in the .git-seed file and calls the package manager to install', (done) -> 

            gitSeed = new GitSeed '.', Plugin

            gitSeed.clone (error, result) -> 

                result.should.eql ['INSTALLED']
                test done


    context 'GitSeed.pull()', (it, fs) -> 

        fs.lstatSync = -> isFile: -> true
        fs.readFileSync = -> """[

            {
                "root": true,
                "path": ".",
                "origin": "git@github.com:nomilous/git-seed.git",
                "branch": "refs/heads/develop",
                "ref": "ROOT_REPO_REF",
                "manager": "npm"
            },
            {
                "root": false,
                "path": ".",
                "origin": "git@github.com:nomilous/git-seed-npm.git",
                "branch": "refs/heads/develop",
                "ref": "a09a5433e140d6962471a77b541b33857a5473f0",
                "manager": "npm"
            }

        ]"""

        Plugin.Package.prototype.install = (callback) -> callback null, 'INSTALLED'


        it 'pulls only the root repo if list is not specified', (done) -> 

            paths = []

            Plugin.Package.prototype.pull = (callback) -> 

                paths.push @path
                callback null, null


            gitSeed = new GitSeed '.', Plugin

            gitSeed.pull null, (error, result) -> 

            paths.length.should.equal 1
            paths[0].should.equal '.'
            test done


