describe 'mocha-phantomjs', ->

  expect = require('chai').expect
  spawn  = require('child_process').spawn

  htmlFile = (file) -> "file://#{process.cwd()}/test/#{file}.html"
  passRegExp   = (n) -> ///\u001b\[32m\s\s✓\u001b\[0m\u001b\[90m\spasses\s#{n}///
  skipRegExp   = (n) -> ///\u001b\[36m\s\s-\sskips\s#{n}\u001b\[0m///
  failRegExp   = (n) -> ///\u001b\[31m\s\s#{n}\)\sfails\s#{n}\u001b\[0m///
  passComplete = (n) -> ///\u001b\[0m\n\n\n\u001b\[92m\s\s✔\u001b\[0m\u001b\[32m\s#{n}\stests\scomplete///
  pendComplete = (n) -> ///\u001b\[36m\s+•\u001b\[0m\u001b\[36m\s#{n}\stests\spending///
  failComplete = (x,y) -> ///\u001b\[91m\s\s✖\u001b\[0m\u001b\[31m\s#{x}\sof\s#{y}\stests\sfailed///
  
  before ->
    @runner = (done, args, callback) ->
      stdout = ''
      stderr = ''
      phantomArgs = args.slice()
      phantomArgs.unshift "#{process.cwd()}/lib/mocha-phantomjs.coffee"
      phantomjs = spawn 'phantomjs', phantomArgs
      phantomjs.stdout.on 'data', (data) -> stdout = stdout.concat data.toString()
      phantomjs.stderr.on 'data', (data) -> stderr = stderr.concat data.toString()
      phantomjs.on 'exit', (code) -> 
        callback?(code, stdout, stderr)
        done?()

  it 'returns a failure code and shows usage when no args are given', (done) ->
    @runner done, [], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /usage/i

  it 'returns a failure code and notifies of bad url when given one', (done) ->
    @runner done, ['foo/bar.html'], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /failed to load the page/i
      expect(stdout).to.match /check the url/i
      expect(stdout).to.match /foo\/bar.html/i

  describe 'bdd-spec-passing', ->

    ###
    $ phantomjs lib/mocha-phantomjs.coffee test/bdd-spec-passing.html
    $ mocha -r chai/chai.js -u bdd -R spec --globals chai.expect test/lib/bdd-spec-passing.js
    ###

    before ->
      @args = [htmlFile('bdd-spec-passing')]

    it 'returns a passing code', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(code).to.equal 0

    it 'writes all output in color', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /BDD Spec Passing/
        expect(stdout).to.match passRegExp(1)
        expect(stdout).to.match passRegExp(2)
        expect(stdout).to.match passRegExp(3)
        expect(stdout).to.match skipRegExp(1)
        expect(stdout).to.match skipRegExp(2)
        expect(stdout).to.match skipRegExp(3)
        expect(stdout).to.match passComplete(6)
        expect(stdout).to.match pendComplete(3)

  describe 'bdd-spec-failing', ->
    
    ###
    $ phantomjs lib/mocha-phantomjs.coffee test/bdd-spec-failing.html
    $ mocha -r chai/chai.js -u bdd -R spec --globals chai.expect test/lib/bdd-spec-failing.js
    ###

    before ->
      @args = [htmlFile('bdd-spec-failing')]

    it 'returns a failing code equal to the number of mocha failures', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(code).to.equal 3

    it 'writes all output in color', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /BDD Spec Failing/
        expect(stdout).to.match passRegExp(1)
        expect(stdout).to.match passRegExp(2)
        expect(stdout).to.match passRegExp(3)
        expect(stdout).to.match failRegExp(1)
        expect(stdout).to.match failRegExp(2)
        expect(stdout).to.match failRegExp(3)
        expect(stdout).to.match failComplete(3,6)

    


