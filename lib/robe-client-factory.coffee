RobeClient = require './robe-client'

module.exports =
class RobeClientFactory
  runner: null
  client: null

  isServerStarted: -> @runner.isStarted()

  constructor: (@runner) ->

  # returns null if client is not available
  retrieve: ->
    return Promise.resolve(null) if @runner.hasError()
    @runner.ensureStarted()
      .then (port) =>
        unless @client?.getPort() is port
          @client = new RobeClient(port)
        @client
      .catch (reason) -> null

  stop: ->
    @runner.stop()
