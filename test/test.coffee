vows = require "vows"

vows
  .describe("Client")
  .addBatch( require './client_test' )
  .export(module)

