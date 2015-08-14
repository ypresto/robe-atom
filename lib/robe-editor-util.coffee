module.exports =
class RobeEditorUtil
  # Inspired by ruby-mode.el's ruby-add-log-current-method
  @currentContext: (editor, bufferPosition) ->
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
