require('nez').realize 'GitSeed', (GitSeed, test, context, should, findit, fs) -> 

    #
    # mock deferral
    #

    deferral = 

        resolve: -> 
        reject:  -> 
        notify: ->


    deferral.notify.info = 
        good: ->
        bad: -> 

    #
    # mock package plugin
    #

    Plugin = 

        Package: class MockPackage

            constructor: (properties) ->

                for key of properties

                    @[key] = properties[key]


            @search = (root, Plugin, deferral, callback) -> 

                callback null, [

                    new Plugin.Package property: 'REPO1'
                    new Plugin.Package property: 'REPO2'

                ]
            

        Shell: {}


    context 'GitSeed.init()', (it) ->

        it 'searches for git repos', (And) -> 

            And 'saves the .git-seed file', (done) ->

                fs.writeFileSync = (path, contents) -> 

                    path.should.equal 'PATH/.git-seed'
                    test done

                GitSeed.init 'PATH', Plugin, deferral


            And 'initializes the GitSeed constituent GitRepo(s) array', (done) ->

                GitSeed.prototype.save = ->

                    @array.should.eql [

                        { property: 'REPO1' }
                        { property: 'REPO2' }
                        
                    ]

                    test done
                    
                GitSeed.init 'PATH', Plugin, deferral


    context 'GitSeed.status()', (it) -> 

        inputRepoArray = [
            { path: '.' }
            { path: './node_modules/submod'}
        ]
        GitSeed.prototype.load = -> return inputRepoArray

        
        it 'calls getStatus on the Package plugin for every repo in the seed file', (done) -> 

            actsOnRepoArray = [] 

            seed = new GitSeed '.', {

                #
                # mock package plugin
                #

                Package: 

                    getStatus: (repo, defer, callback) -> 

                        actsOnRepoArray.push repo
                        callback null, {}

            }, deferral

            seed.status -> 
            
                actsOnRepoArray.should.eql inputRepoArray
                test done





    # context 'GitSeed.clone()', (it) -> 

    #     fs.lstatSync = -> isFile: -> true
    #     fs.readFileSync = -> """[

    #         {
    #             "root": true,
    #             "path": ".",
    #             "origin": "git@github.com:nomilous/git-seed.git",
    #             "branch": "refs/heads/develop",
    #             "ref": "ROOT_REPO_REF",
    #             "manager": "npm"
    #         },
    #         {
    #             "root": false,
    #             "path": "./node_modules/git-seed-npm",
    #             "origin": "git@github.com:nomilous/git-seed-npm.git",
    #             "branch": "refs/heads/master",
    #             "ref": "a09a5433e140d6962471a77b541b33857a5473f0",
    #             "manager": "npm"
    #         },
    #         {
    #             "root": false,
    #             "path": "./node_modules/git-seed-npm/node_modules/git-seed-core",
    #             "origin": "git@github.com:nomilous/git-seed-core.git",
    #             "branch": "refs/heads/master",
    #             "ref": "c69ec4b7a687f3a3dd695bf4f50e2d3d5c6c624f",
    #             "manager": "npm"
    #         }


    #     ]"""

    #     cloned = []
    #     Plugin.Package.prototype.clone   = (callback) -> cloned.push @path

    #     it 'clones all repos in the .git-seed file in order', (done) -> 

    #         gitSeed = new GitSeed '.', Plugin, deferral

    #         gitSeed.clone (error, result) -> 

    #             cloned.should.eql [

    #                 '.'
    #                 './node_modules/git-seed-npm'
    #                 './node_modules/git-seed-npm/node_modules/git-seed-core'
                    
    #             ]

    #             # result.should.eql [ 

    #             #     'INSTALLED @ .'
    #             #     'INSTALLED @ ./node_modules/git-seed-npm'
    #             #     'INSTALLED @ ./node_modules/git-seed-npm/node_modules/git-seed-core'

    #             # ]

    #             test done


    # context 'GitSeed.pull()', (it) -> 

    #     fs.lstatSync = -> isFile: -> true
    #     fs.readFileSync = -> """[

    #         {
    #             "root": true,
    #             "path": ".",
    #             "origin": "git@github.com:nomilous/git-seed.git",
    #             "branch": "refs/heads/develop",
    #             "ref": "ROOT_REPO_REF",
    #             "manager": "npm"
    #         },
    #         {
    #             "root": false,
    #             "path": "./node_modules/git-seed-npm",
    #             "origin": "git@github.com:nomilous/git-seed-npm.git",
    #             "branch": "refs/heads/master",
    #             "ref": "a09a5433e140d6962471a77b541b33857a5473f0",
    #             "manager": "npm"
    #         },
    #         {
    #             "root": false,
    #             "path": "./node_modules/git-seed-npm/node_modules/git-seed-core",
    #             "origin": "git@github.com:nomilous/git-seed-core.git",
    #             "branch": "refs/heads/master",
    #             "ref": "c69ec4b7a687f3a3dd695bf4f50e2d3d5c6c624f",
    #             "manager": "npm"
    #         }


    #     ]"""

    #     Plugin.Package.prototype.install = (callback) -> callback null, 'INSTALLED'


    #     it 'pulls only the root repo if seed is not specified', (done) -> 

    #         paths = []

    #         Plugin.Package.prototype.pull = (callback) -> 

    #             paths.push @path
    #             callback null, null


    #         gitSeed = new GitSeed '.', Plugin, deferral

    #         gitSeed.pull null, (error, result) -> 

    #         paths.length.should.equal 1
    #         paths[0].should.equal '.'
    #         test done


    #     it 'pulls all but the root it seed is specified', (done) -> 

    #         paths = []

    #         Plugin.Package.prototype.pull = (callback) -> 

    #             paths.push @path
    #             callback null, null


    #         gitSeed = new GitSeed '.', Plugin, deferral

    #         gitSeed.pull gitSeed, (error, result) -> 

    #         paths.length.should.equal 2
    #         paths[0].should.equal './node_modules/git-seed-npm'
    #         paths[1].should.equal './node_modules/git-seed-npm/node_modules/git-seed-core'
    #         test done


