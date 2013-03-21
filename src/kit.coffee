module.exports = kit = 

    #
    # for interactions with the `shell`
    #

    shell: require './shell/shell'


    #
    # for interactions with `git`
    #

    git: require './git/git'


    #
    # for interactions with npm
    #

    npm: require './npm/npm'


    #
    # for interactions with the coffee script compiler
    #

    coffee: require './coffee/coffee'


    #
    # for interactions with a set of `objects`
    #

    set: require './set/set'


    #
    # for runtime injection
    #

    injector: require './injector/injector'

