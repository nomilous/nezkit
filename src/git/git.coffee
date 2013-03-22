Shell     = require '../shell/shell'
colors    = require 'colors'
waterfall = require('async').waterfall

module.exports = git = 

    #
    # exports 
    #

    repo: require './git_repo'
    tree: require './git_tree'
    
