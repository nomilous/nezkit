Git     = require '../git/git_support'
GitRepo = require '../git/git_repo'

module.exports = class NodeModule extends GitRepo

    @init: (workDir, seq, manager) -> 

        return new NodeModule

            root:    seq == 0
            path:    workDir
            origin:  Git.showOrigin workDir
            branch:  Git.showBranch workDir
            ref:     Git.showRef workDir
            manager: manager

