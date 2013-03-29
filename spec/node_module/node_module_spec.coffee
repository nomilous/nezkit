require('nez').realize 'NodeModule', (NodeModule, test, it, should, GitRepo) -> 

    it 'extends GitRepo to include module manager', (done) ->

        node_module = NodeModule.init '.', 0, 'npm'
        node_module.origin.should.equal 'git@github.com:nomilous/nezkit.git'
        node_module.manager.should.equal 'npm'
        test done
