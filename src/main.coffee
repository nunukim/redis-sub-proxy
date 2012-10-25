net = require 'net'
EventEmitter = require('events').EventEmitter

redis = require "redis"
_ = require "underscore"

exports = module.exports =
  createConnection: (port, host, options)->
    port ?= 6379
    host ?= "127.0.0.1"

    net_client = net.createConnection(port, host)
    redis_client = new exports.Connection net_client, options

    redis_client.port = port
    redis_client.host = host
    redis_client

  Connection: class Connection extends redis.RedisClient
    constructor: ->
      super
      @map = {}

      @on 'message', (channel, data)->
        return unless cmap = @map[channel]
        for _id, client of cmap
          client?.emit 'message', channel, data

    createClient: ->
      new exports.Client(@)

    subscribeClient: (client, channel, cb)->
      cmap = @map[channel] ?= {}
      if _.isEmpty cmap
        @subscribe channel, cb
      return false if cmap[client._id]?
      cmap[client._id] = client
      return true

    unsubscribeCliet: (client, channel, cb)->
      cmap = @map[channel]
      return false unless cmap?[client._id]?
      delete cmap[client._id]
      if _.isEmpty cmap
        @unsubscribe channel, cb
      else
        process.nextTick cb
      return true
        
  Client: class Client extends EventEmitter
    constructor: (@connection)->
      @_id = _.uniqueId 'sub'
    subscribe: (channel, cb)->
      @connection.subscribeClient this, channel, cb
    unsubscribe: (channel, cb)->
      @connection.subscribeClient this, channel, cb
