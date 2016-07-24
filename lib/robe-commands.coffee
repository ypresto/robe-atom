module.exports =
class RobeCommands
  clientFactory: null

  constructor: (@clientFactory) ->

  railsRefresh: ->
    unless @clientFactory.isServerStarted()
      atom.notifications.addInfo('Robe server is not started.')
      return
    @clientFactory.retrieve().then (client) ->
      client?.railsRefresh()
        .then -> atom.notifications.addSuccess('Robe server refreshed rails environment successfully.')
        .catch -> atom.notifications.addWarning('Robe server failed to refresh rails environment.', dismissable: true)

  restartServer: ->
    @clientFactory.stop()
    @clientFactory.retrieve().then (client) ->
      return unless client?
      atom.notifications.addSuccess('Robe server started successfully.')

  registerToAtom: ->
    atom.commands.add 'atom-workspace',
      'robe:refresh-rails': => @railsRefresh()
      'robe:restart-server': => @restartServer()
