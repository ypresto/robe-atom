RobeClient = require './robe-client'

module.exports =
class RobeProvider
  selector: '.source.ruby'
  disableForSelector: '.source.ruby .comment' # TODO
  inclusionPriority: 10
  excludeLowerPriority: false
  runner: null
  client: null

  constructor: (@runner) ->

  _prepareClient: ->
    @runner.ensureStarted().then (port) =>
      return @client if @client?.getPort() is port
      @client = new RobeClient(port)

  getSuggestions: ({editor, bufferPosition, prefix}) ->
    startPosition = [bufferPosition.row, 0]
    wholePrefix = editor.getTextInBufferRange([startPosition, bufferPosition])
    # resolve [] unless match?
    {moduleName, isInstanceMethod} = @_currentContext(editor, bufferPosition)
    constantPrefix = /(?:^|\s+)((?:[A-Z][A-Za-z0-9_]*|::)+)$/.exec(wholePrefix)?[1]
    if constantPrefix
      @_prepareClient().then (client) ->
        client.completeConst(constantPrefix, moduleName).then (constants) ->
          constants.map (constant) ->
            text: constant
            type: 'constant'
            replacementPrefix: constantPrefix
    else
      # TODO: revise regexp by robe.el's robe-call-context logic
      callTarget = /([a-zA-Z0-9_?!.:]+)\..*$/.exec(wholePrefix)?[1]
      callTarget = if callTarget is 'self' then '' else callTarget
      methodPrefix = if prefix or '.' then '' else prefix
      isInstance = not callTarget and isInstanceMethod
      @_prepareClient().then (client) =>
        # TODO: show arguments
        client.completeMethod(methodPrefix, callTarget, moduleName, isInstance).then (specArrays) =>
          specArrays.map((specArray) => @_parseMethodSpec(specArray)).map (spec) ->
            text: spec.methodName
            rightLabel: spec.module
            type: 'function'

  # Inspired by ruby-mode.el's ruby-add-log-current-method
  _currentContext: (editor, bufferPosition) ->
    modules = []
    isClassMethod = false
    methodName = null
    lastIndentLevel = Infinity
    # TODO: detect semicolon styled keywords, e.g. `class Hoge; def aaa; p 'fuga'; end; end`
    # TODO: ignore keywords appeared in heredoc
    regexp = /^([\t ]*)(?:(class|module|def)[\t ]+(<<[\t ]+)?((?:[a-zA-Z0-9_=?!]|::|\.)+)|(end))(?:\n|\W)/g
    editor.backwardsScanInBufferRange regexp, [[0, 0], bufferPosition], ({match}) ->
      [indent, type, eigen, name, end] = match.slice(1)
      return unless indent.length < lastIndentLevel
      lastIndentLevel = indent.length
      return if end # just want to detect indentation
      if type is 'def'
        segments = name.split('.')
        if segments.length > 0 and /[A-Z].*/.test(segments[0])
          # constant, e.g. `def Hoge.fuga`
          modules.unshift segments[0]
          isClassMethod = true
        else
          isClassMethod = segments[0] is 'self'
        methodName = segments[segments.length - 1] # XXX AAA.hoge.fuga ..?
      else if name is 'self'
        isClassMethod = true if eigen # class << self
      else
        modules.unshift name
    moduleName = modules.join('::')
    isInstanceMethod = not isClassMethod and !!methodName
    {moduleName, isInstanceMethod, methodName}

  _parseMethodSpec: (specArray) ->
    [module, isInstanceMethod, methodName, methodParameters, file, line, column] = specArray
    {module, isInstanceMethod, methodName, methodParameters, file, line, column}
