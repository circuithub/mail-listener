util             = require "util"
{EventEmitter}   = require "events"
{MailParser}     = require "mailparser"
{ImapConnection} = require "imap"


class MailListener extends EventEmitter

  constructor: (options) ->
    @imap = new ImapConnection
      username: options.username
      password: options.password
      host: options.host
      port: options.port
      secure: options.secure
    @imap.connect (err) =>
      if err
        util.log "error connecting to mail server #{error}"
        @emit "error", err
      else
        util.log "successfully connected to mail server"
        @emit "server:connected"
        @imap.openBox "INBOX", false, (err) =>
          if err
            util.log "error opening mail box #{error}"
            @emit "error", err
          else
            util.log "successfully opened mail box"            
            @imap.on "mail", (id) =>
              @util "new mail arrived"
              @emit "mail:arrived"              
              @imap.search ["UNSEEN"], (err, searchResults) =>
                if err
                  util.log "error searching unseen emails #{error}"
                  @emit "error", err
                else              
                  util.log "found #{searchResults.length} emails"
                  fetch = @imap.fetch searchResults,
                    markSeen: true
                    request:
                      headers: false#['from', 'to', 'subject', 'date']
                      body: "full"
                  fetch.on "message", (msg) =>
                    parser = new MailParser
                    msg.on "data", (data) -> parser.write data.toString()
                    parser.on "end", (mail) ->
                      util.log "parsed mail", util.inspect mail, false, 5
                      @emit "mail:parsed", mail 
                    msg.on "end", ->
                      util.log "fetched message: ", util.inspect(msg, false, 5)
                      parser.end()

module.exports = MailListener       