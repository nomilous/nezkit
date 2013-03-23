require('nez').realize 'GitTree', (GitTree, test, context, should, GitRepo) -> 

    context 'at init()', (it) ->

        it 'searches for git repos', (And, findit) -> 

            #
            # mock search
            #

            findit.find = (path) -> 

                path.should.equal 'PATH'

                on: (event, callback) ->

                    switch event

                        when 'directory'

                            #
                            # pretend to find two git repos
                            #

                            callback 'pretend/repo/.git/'
                            callback 'pretend/repo/node_modules/deeper/.git/'
                        
                        when 'end'
                            callback()

            #
            # GitRepos get initialized from found repo paths
            #

            GitRepo.init = (path, seq) -> 

                #
                # first found repo should have sequence 0
                # (it becomes the root repo)
                # 

                switch seq

                    when 0 then path.should.equal 'pretend/repo'
                    when 1 then path.should.equal 'pretend/repo/node_modules/deeper'

                return fakeRepo: path




            And 'saves the .nez_tree file', (done, fs) ->

                fs.writeFileSync = (path, contents) -> 

                    path.should.equal 'PATH/.nez_tree'
                    contents.should.match /fakeRepo/
                    test done

                GitTree.init 'PATH'



            And 'initializes the GitTree', (done) ->

                GitTree.prototype.save = ->

                    @array.should.eql [
                        { fakeRepo: 'pretend/repo' }
                        { fakeRepo: 'pretend/repo/node_modules/deeper' }
                    ]

                    test done

                    
                GitTree.init 'PATH'

            




