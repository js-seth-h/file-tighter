_ = require 'lodash'
glob = require 'glob'
{ficent} = require 'ficent'

path = require 'path'
fs = require 'fs' 
zlib = require 'zlib'
 
###
  new FileTighter
    target: '*.log' or  ["*.log", '*.txt'] - glob pattern, single or array 
    fs_stats: false
    getDecision: (file_info)-> # 각 파일에 대하여 처리 방침을 결정    
      file_path = file_info.path
      fs_stats = file_info.stats
### 
class FileTighter 
  constructor: (@opt)-> 
    if not Array.isArray @opt.target
      @opt.target = [@opt.target]

  decidePolicy: (file_info)->
    return "pass"
  policy:
    pass: (file_info, done)-> done()
    unlink: (file_info, done)->
      fs.unlink file_info.path, done
    zip: (file_info, done)->
      gzip = zlib.createGzip()
      inp = fs.createReadStream file_info.path
      out = fs.createWriteStream file_info.path + '.zip'
      out.on 'error', (err)-> 
        # console.log('zip', 'error', err)
        done()
      out.on 'finish', ()-> 
        # console.log('zip', 'done')
        fs.unlink file_info.path, ()->
          done()
      inp.pipe(gzip).pipe(out)

  doTight: (callback)->
    self = this
    opt = @opt
    # console.log 'doTight', opt

    file_infos = null
    
    (ficent [
      (_toss)->
        # console.log 'opt.target=', opt.target
        args_list = _.map opt.target, (t)-> [t, {nodir: true}]
        # console.log 'args_list=', args_list
        ficent.par(glob) args_list, _toss.toItems 'glob_results'
      (_toss)->
        {glob_results} = _toss.items()
        files = _.uniq _.flatten glob_results
        file_infos = _.map files, (f)-> status = 
          path: f   
        _toss null
      (_toss)->
        return _toss null unless opt.fs_stats
        _stat = (file_info, _toss)->
          fs.stat file_info.path, (err, stats)->
            file_info.stats = stats
            _toss null
        args_list = _.map file_infos, (t)-> [t]
        ficent.ser(_stat) args_list, _toss
      (_toss)->
        _decision = (file_info, _toss)->
          # console.log 'call _decision =', file_info
          file_info.policy = self.decidePolicy file_info
          _toss null 
        args_list = _.map file_infos, (t)-> [t]
        ficent.ser(_decision) args_list, _toss
      (_toss)->      
        _do_policy = (file_info, _toss)->
          # console.log 'file_info=', file_info
          self.policy[file_info.policy] file_info, _toss
        args_list = _.map file_infos, (t)-> [t]
        ficent.ser(_do_policy) args_list, _toss 
    ]) callback


 

module.exports = exports = FileTighter