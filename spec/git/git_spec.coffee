require('nez').realize 'Git', (Git, test, it, should) -> 

    it 'exports git/git_repo', (done) ->

        Git.repo.should.equal require '../../lib/git/git_repo'
        test done

    it 'exports git/git_seed', (done) ->

        Git.seed.should.equal require '../../lib/git/git_seed'
        test done
