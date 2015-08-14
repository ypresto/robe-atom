RobeClient = require './robe-client'

module.exports =
class RobeClientFactory
  runner: null
  client: null

  constructor: (@runner) ->

  retrieve: ->
    @runner.ensureStarted().then (port) =>
      unless @client?.getPort() is port
        @client = new RobeClient(port)
      return @client
