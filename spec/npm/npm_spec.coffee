require('nez').realize 'Npm', (Npm, test, context, GitSeed) -> 

    context 'install()', (it) -> 

        it 'installs npm modules for each GitRepo in the GitSeed', (done) -> 

            root = '.'
            GitSeed.prototype.constructor = -> console.log 'stub'
            seed = new GitSeed root


            test done
