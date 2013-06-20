{EventEmitter}   = require "events"
{MailParser}     = require "mailparser"
{ImapConnection} = require "imap"

# MailListener class. Can `emit` events in `node.js` fashion.
class MailListener extends EventEmitter

  constructor: (options) ->
    # set this option to `true` if you want to fetch unread emial immediately on lib start.
    @fetchUnreadOnStart = options.fetchUnreadOnStart
    @markSeen = options.markSeen
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
        @emit "error", err
      else
        @emit "server:connected"
        # 2. open mailbox
        @imap.openBox @mailbox, false, (err) =>
          if err
            @emit "error", err
          else
            if @fetchUnreadOnStart
              @_parseUnreadEmails()
            # 3. listen for new emails in the inbox
            @imap.on "mail", (id) =>
              @emit "mail:arrived", id
              # 4. find all unseen emails 
              @_parseUnreadEmails()
              
  # stop listener
  stop: =>
    @imap.logout =>
      @emit "server:disconnected"

  _parseUnreadEmails: =>
    @imap.search ["UNSEEN"], (err, searchResults) =>
      if err
        @emit "error", err
      else              
        if Array.isArray(searchResults) and searchResults.length == 0
          return
        # 5. fetch emails
        params = {}
        if @markSeen
          params.markSeen = true
        @imap.fetch searchResults, params, 
          headers:
            parse: true
          body: true  
          cb: (fetch) =>
            # 6. email was fetched. Parse it!   
            fetch.on "message", (msg) =>
              parser = new MailParser
              parser.on "end", (mail) =>
                mail.uid = msg.uid
                @emit "mail:parsed", mail
              msg.on "data", (data) -> parser.write data.toString()
              msg.on "end", ->
                parser.end()

  # imap
  imap = @imap

module.exports = MailListener