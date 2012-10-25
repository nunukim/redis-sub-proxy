assert = require 'assert'
_ = require "underscore"

proxy = require "../src/main.coffee"

date = new Date().toString()

module.exports =
  "module":
    topic: -> proxy
    "can be loaded": (t)->
      assert.instanceOf t, Object

  "createConnection":
    topic: -> proxy.createConnection()
    "makes new connection": (t)->
      assert.instanceOf t, proxy.Connection
    "can set":
      topic: (t)->
        t.set 'redis-proxy test-client set', date.toString(), @callback
        undefined
      "and replies 'OK'": (rep)->
        assert.equal rep, 'OK'

    "can set and get":
      topic: (t)->
        t.set 'redis-proxy test-client get', date.toString(), (err, rep)=>
          t.get 'redis-proxy test-client get', @callback
        undefined

      "and replies set value": (rep)->
        assert.equal rep, date

  "Connection":
    topic: -> proxy.createConnection()
    "can create client":
      topic: (connection)-> connection.createClient()
      "and it exists": (client)->
        assert.instanceOf client, proxy.Client
  "Client":
    topic: ()->
      @con = proxy.createConnection()
      #@con.on 'message', (ch, data)-> console.log ch, data
      @sub1 = @con.createClient()
      @sub1.subscribe 'test1', =>
        @sub2 = @con.createClient()
        @sub2.subscribe 'test2', @callback
      undefined

      @pub = proxy.createConnection()
    "can subscribe": ->
      assert.equal @con.map["test1"][@sub1._id], @sub1
    "published":
      topic: ->
        @sub1.on 'message', _.bind(@callback, null)
        @pub.publish 'dummy', "bbb"
        @pub.publish 'test1', "aaa"
        undefined

      "and get message": (ch, data)->
        assert.equal ch, "test1"
        assert.equal data, "aaa"

      #"and unsubscribe":
        #topic: ->
          #@sub1.unsubscribe 'test1', @callback
          #undefined
        
        #"undregistered": ->
          #assert.isEmpty @con.map["test1"]
