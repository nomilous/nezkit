require('nez').realize 'Git', (Git, test, it, should) -> 

    it 'exports git/git_repo', (done) ->

        Git.repo.should.equal require '../../lib/git/git_repo'
        test done

    it 'exports git/git_tree', (done) ->

        Git.tree.should.equal require '../../lib/git/git_tree'
        test done
