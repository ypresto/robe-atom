RobeProvider = require './robe-provider'
RobeRunner = require './robe-runner'
{CompositeDisposable} = require 'atom'

module.exports = Robe =
  config:
    robePath:
      description: 'Please `git clone https://github.com/dgutov/robe.git` first.'
      type: 'string'
      default: '~/github/robe'
    port:
      description: 'Launch robe server on this port.'
      type: 'integer'
      default: 24969
      minimum: 1
      maximum: 65535
    launchTimeout:
      description:
        'Wait for specified msecs before robe server launches. ' +
        'You might want longer value if you use large number of gems.'
      type: 'integer'
      default: 15000

  runner: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @runner = new RobeRunner
    @subscriptions.add atom.config.observe 'robe.robePath', (robePath) =>
      @runner.setRobePath(robePath)
    @subscriptions.add atom.config.observe 'robe.port', (port) =>
      @runner.setPort(port)
    @subscriptions.add atom.config.observe 'robe.launchTimeout', (launchTimeout) =>
      @runner.setLaunchTimeout(launchTimeout)

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @runner.destroy()
    @runner = null

  serialize: ->

  getProvider: ->
    new RobeProvider(@runner)
