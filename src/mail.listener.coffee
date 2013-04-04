util             = require "util"
{EventEmitter}   = require "events"
{MailParser}     = require "mailparser"
{ImapConnection} = require "imap"

# MailListener class. Can `emit` events in `node.js` fashion.
class MailListener extends EventEmitter

  constructor: (options) ->
    # set this option to `true` if you want to fetch unread emial immediately on lib start.
    @fetchUnreadOnStart = options.fetchUnreadOnStart
    # TODO add validation for required parameters
    @imap = new ImapConnection
      username: options.username
      password: options.password
      host: options.host
      port: options.port
      secure: options.secure
    @mailbox = options.mailbox || "INBOX"

  # start listener
  start: => 
    # 1. connect to imap server  
    @imap.connect (err) =>
      if err
        util.log "connect to mail server: error #{err}"
        @emit "error", err
      else
        util.log "connect to mail server: success"
        @emit "server:connected"
        # 2. open mailbox
        @imap.openBox @mailbox, false, (err) =>
          if err
            util.log "open mail box '#{@mailbox}': error #{err}"
            @emit "error", err
          else
            if @fetchUnreadOnStart
              @_parseUnreadEmails()
            util.log "open mail box '#{@mailbox}': success"
            # 3. listen for new emails in the inbox
            @imap.on "mail", (id) =>
              util.log "new mail arrived with id #{id}"
              @emit "mail:arrived", id
              # 4. find all unseen emails 
              @_parseUnreadEmaisl()
              
  # stop listener
  stop: =>
    @imap.logout =>
      @emit "server:disconnected"

  _parseUnreadEmails: =>
    @imap.search ["UNSEEN"], (err, searchResults) =>
      if err
        util.log "error searching unseen emails #{err}"
        @emit "error", err
      else              
        util.log "found #{searchResults.length} emails"
        # 5. fetch emails
        @imap.fetch searchResults, 
          headers:
            parse: false
          body: true  
          cb: (fetch) =>
            # 6. email was fetched. Parse it!   
            fetch.on "message", (msg) =>
              parser = new MailParser
              parser.on "end", (mail) =>
                util.log "parsed mail" + util.inspect mail, false, 5
                @emit "mail:parsed", mail
              msg.on "data", (data) -> parser.write data.toString()
              msg.on "end", ->
                util.log "fetched message: " + util.inspect(msg, false, 5)
                parser.end()

module.exports = MailListener