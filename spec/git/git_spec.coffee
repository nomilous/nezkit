require('nez').realize 'Git', (Git, test, it, should) -> 

    it 'exports git/repo', (done) ->

        Git.repo.should.equal require '../../lib/git/repo'
        test done
