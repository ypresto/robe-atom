RobeClient = require './robe-client'
RobeEditorUtil = require './robe-editor-util'

module.exports =
class RobeProvider
  selector: '.source.ruby'
  disableForSelector: '.source.ruby .comment' # TODO
  inclusionPriority: 10
  excludeLowerPriority: false
  clientFactory: null

  constructor: (@clientFactory) ->

  getSuggestions: ({editor, bufferPosition, prefix}) ->
    startPosition = [bufferPosition.row, 0]
    wholePrefix = editor.getTextInBufferRange([startPosition, bufferPosition])
    # resolve [] unless match?
    {moduleName, isInstanceMethod} = RobeEditorUtil.currentContext(editor, bufferPosition)
    constantPrefix = /(?:^|\s+)((?:[A-Z][A-Za-z0-9_]*|::)+)$/.exec(wholePrefix)?[1]
    if constantPrefix
      @clientFactory.retrieve().then (client) ->
        client.completeConst(constantPrefix, moduleName).then (constants) ->
          constants.map (constant) ->
            text: constant
            type: 'constant'
            replacementPrefix: constantPrefix
    else
      # TODO: revise regexp by robe.el's robe-call-context logic
      callTarget = /([a-zA-Z0-9_?!.:]+)\..*$/.exec(wholePrefix)?[1]
      callTarget = if callTarget is 'self' then '' else callTarget
      methodPrefix = if prefix is '.' then '' else prefix
      isInstance = not callTarget and isInstanceMethod
      @clientFactory.retrieve().then (client) =>
        # TODO: show arguments
        client.completeMethod(methodPrefix, callTarget, moduleName, isInstance).then (specArrays) =>
          specArrays.map((specArray) => @_parseMethodSpec(specArray)).map (spec) ->
            text: spec.methodName
            rightLabel: spec.module
            type: 'function'

  _parseMethodSpec: (specArray) ->
    [module, isInstanceMethod, methodName, methodParameters, file, line, column] = specArray
    {module, isInstanceMethod, methodName, methodParameters, file, line, column}
