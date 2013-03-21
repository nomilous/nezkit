require('nez').realize 'Kit', (Kit, test, it, should) -> 

    it 'is defined', (done) -> 

        should.exist Kit
        test done
