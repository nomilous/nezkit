require('nez').realize 'Kit', (Kit, test, it, should) -> 

    it 'is defined', (done) -> 

        should.exist Kit
        test done

    it 'exports git', (done) ->

        Kit.git.should.equal require '../lib/git/git'
        test done

    it 'exports shell', (done) ->

        Kit.shell.should.equal require '../lib/shell/shell'
        test done

