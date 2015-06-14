RobeProvider = require './robe-provider'
{CompositeDisposable} = require 'atom'

module.exports = Robe =

  activate: (state) ->

  deactivate: ->

  serialize: ->

  getProvider: ->
    new RobeProvider()
