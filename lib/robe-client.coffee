$ = require 'jquery'

module.exports =
class RobeClient
  BASE_URL = 'http://localhost'
  port: null

  constructor: (@port) ->

  getPort: -> @port

  classLocations: (name, mod) ->
    @_callPromise('class_locations', [name, mod])
  modules: ->
    @_callPromise('modules', [])
  targets: (obj) ->
    @_callPromise('targets', [obj])
  findMethod: (mod, inst, sym) ->
    @_callPromise('find_method', [mod, inst, sym])
  findMethodOwner: (mod, inst, sym) ->
    @_callPromise('find_method_owner', [mod, inst, sym])
  methodSpec: (method) ->
    @_callPromise('method_spec', [method])
  methodOwnerAndInst: (owner) ->
    @_callPromise('method_owner_and_inst', [owner])
  docFor: (mod, type, sym) ->
    @_callPromise('doc_for', [mod, type, sym])
  methodTargets: (name, target, mod, instance, superc, conservative) ->
    @_callPromise('method_targets', [name, target, mod, instance, superc, conservative])
  # * `prefix` A {String} of user input for completion.
  # * `target` A {String} for the call target of current completing string.
  # * `mod` A {String} for the module name of current context.
  # * `instance` A {Boolean} indicates whether completing instance method call or not.
  completeMethod: (prefix, target, mod, instance) ->
    @_callPromise('complete_method', [prefix, target, mod, instance])
  completeConst: (prefix, mod) ->
    @_callPromise('complete_const', [prefix, mod])
  completeConstInModule: (tail, base) ->
    @_callPromise('complete_const_in_module', [tail, base])
  railsRefresh: ->
    @_callPromise('rails_refresh', [])
  ping: ->
    @_callPromise('ping', [])

  _callPromise: (name, args) ->
    escapedArgs = args.map((arg) => @_formatArg(arg)).map((arg) -> encodeURIComponent(arg))
    url = [BASE_URL + ":#{@port}", encodeURIComponent(name)].concat(escapedArgs).join('/')
    new Promise (resolve, reject) ->
      $.ajax
        url: url
        type: 'GET'
        # dataType: 'json'
        processData: false
        error: (jqXHR, textStatus, errorThrown) ->
          console.error errorThrown
          reject(textStatus)
        success: (data, textStatus, jqXHR) ->
          resolve(data)

  _formatArg: (arg) ->
    return 'yes' if arg is true
    return '-' if arg is false or not arg?
    arg
