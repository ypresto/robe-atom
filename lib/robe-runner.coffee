{BufferedProcess, File} = require 'atom'
path = require 'path'

module.exports =
class RobeRunner
  currentPromise: null
  process: null
  isDestroyed: false
  robePath: null
  launchTimeout: 15000

  # returns port
  ensureStarted: ->
    return Promise.reject 'Already destroyed.' if @isDestroyed
    return @currentPromise if @currentPromise
    @currentPromise = new Promise (resolve, reject) =>
      # TODO: launch timeout
      started = false
      timerId = null
      @_createArgs().then ({command, args, options}) =>
        console.log('Starting robe...')
        stdout = (lines) ->
          console.log "Got stdout from robe process: '#{lines}'."
          return if started
          for line in lines.split('\n')
            match = line.match /^"robe on ([1-9][0-9]*)"$/
            continue unless match?
            port = match[1]
            started = true
            clearTimeout(timerId)
            resolve(port)
            break
        stderr = (lines) ->
          console.warn "Got stderr from robe process: '#{lines}'."
        exit = (code) ->
          message = "Robe process exited with code #{code}."
          if started
            console.log message
            return
          clearTimeout(timerId)
          atom.notifications.addError message, dismissable: true
          reject(new Error(message))
        @process = new BufferedProcess {command, args, options, stdout, stderr, exit}
        launchTimeout = @launchTimeout
        timerId = setTimeout ->
          message = "Robe launch timedout after waiting #{launchTimeout} msecs, was wating for '\"robe on\"'."
          atom.notifications.addError message, dismissable: true
          reject(new Error(message))
        , launchTimeout
        @process.onWillThrowError ({error, handle}) ->
          clearTimeout(timerId)
          reject(error)
    .catch (reason) =>
      @stop()
      throw reason

  stop: ->
    @currentPromise = null
    @process?.kill()
    @process = null

  destroy: ->
    isDestroyed = true
    @stop()

  setRobePath: (@robePath) ->
    @stop()

  setLaunchTimeout: (@launchTimeout) ->

  _createArgs: ->
    packagePath = atom.packages.getActivePackage('robe').path
    launcherPath = path.join(packagePath, 'bin', 'robe_launcher.rb')
    projectPath = atom.project.getPaths()[0] # TODO: multiple paths
    options = cwd: projectPath
    @_determineCommand(projectPath).then (commandLine) =>
      console.log("Using '#{commandLine}' to start robe for '#{projectPath}'. robePath: #{@robePath}")
      commandArgs = commandLine.split(' ')
      command = commandArgs[0]
      args = commandArgs[1..].concat(launcherPath, @robePath)
      {command, args, options}

  _determineCommand: (projectPath) ->
    # https://github.com/nonsequitur/inf-ruby/blob/451aa1d858b3447fff6c247ea5744e7c920d291c/inf-ruby.el#L623
    gemLockFile = new File(path.join(projectPath, 'Gemfile.lock'))
    gemLockFile.exists()
    .then (isExists) =>
      return 'none' unless isExists
      gemLockFile.read()
        .then (content) => @_determineRails(projectPath, content)
        .then (isRails) -> if isRails then 'rails' else 'bundler'
    .then (type) ->
      switch type
        when 'rails'    then 'bundle exec rails runner'
        when 'bundler'  then 'bundle exec'
        when 'none'     then 'ruby -Ilib'

  _determineRails: (projectPath, content) ->
    return false unless !!content?.match /\srailties\s/
    configApplicationFile = new File(path.join(projectPath, 'config', 'application.rb'))
    configApplicationFile.exists().then (isExists) ->
      return '' unless isExists
      configApplicationFile.read()
    .then (content) ->
      !!content.match /(\s|^)Rails::Application(\s|$)/
