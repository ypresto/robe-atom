RobeProvider = require './robe-provider'
RobeRunner = require './robe-runner'
RobeClientFactory = require './robe-client-factory'
RobeCommands = require './robe-commands'
{CompositeDisposable} = require 'atom'

module.exports = Robe =
  config:
    robePath:
      description: 'Please `git clone https://github.com/dgutov/robe.git` first.'
      type: 'string'
      default: '~/github/robe'
    launchTimeout:
      description:
        'Wait for specified msecs before robe server launches. ' +
        'You might want longer value if you use large number of gems.'
      type: 'integer'
      default: 15000

  subscriptions: null
  runner: null
  clientFactory: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @runner = new RobeRunner
    @subscriptions.add atom.config.observe 'robe.robePath', (robePath) =>
      console.log("robePath: #{robePath}")
      @runner.setRobePath(robePath)
    @subscriptions.add atom.config.observe 'robe.launchTimeout', (launchTimeout) =>
      console.log("launchTimeout: #{launchTimeout}")
      @runner.setLaunchTimeout(launchTimeout)
    @clientFactory = new RobeClientFactory(@runner)
    @commands = new RobeCommands(@clientFactory)
    @subscriptions.add @commands.registerToAtom()

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @clientFactory = null
    @runner.destroy()
    @runner = null

  serialize: ->

  getProvider: ->
    new RobeProvider(@clientFactory)
