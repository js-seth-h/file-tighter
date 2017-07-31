
Tighter = require '../src'




describe 'tighter', ()->

  touch  = require 'touch'
  touch.sync './log/20170101-test.txt'
  touch.sync './log/20170102-test.txt'
  touch.sync './log/20170103-test.txt'
  touch.sync './log/20170104-test.txt'
  touch.sync './log/20170105-test.txt'
  touch.sync './log/20170106-test.txt'
  touch.sync './log/20170107-test.txt'
  touch.sync './log/20170108-test.txt'
  touch.sync './log/20170109-test.txt'
  touch.sync './log/20170110-test.txt'
  touch.sync './log/20170111-test.txt'
  touch.sync './log/20170112-test.txt'
  it 'dev', (done)-> 
    tighter = new Tighter
      target :  ['./log/*', './log/*.txt']

    tighter.doTight (err)->
      console.log err if err 
      done()