
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
      fs_stats: on

    tighter.decidePolicy = (file_info)-> 
      policy = 'pass'
      file_path = file_info.path
      stats = file_info.stats
      # console.log 'file_info.stats', file_info.stats
      # console.log 'ctime', file_info.stats.ctime
      return policy

    tighter.doTight (err)->
      console.log err if err 
      done()