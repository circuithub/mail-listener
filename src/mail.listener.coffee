{EventEmitter}   = require "events"
{MailParser}     = require "mailparser"
Imap = require "imap"

# MailListener class. Can `emit` events in `node.js` fashion.
class MailListener extends EventEmitter

  constructor: (options) ->
    # set this option to `true` if you want to fetch unread emial immediately on lib start.
    @fetchUnreadOnStart = options.fetchUnreadOnStart
    @markSeen = options.markSeen
    # TODO add validation for required parameters
    @imap = new Imap
      user: options.username
      password: options.password
      host: options.host
      port: options.port
      tls: options.secure
    @mailbox = options.mailbox || "INBOX"

  # start listener
  start: => 
    # 1. connect to imap server  
    @imap.once 'ready', (err) =>
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
    @imap.connect()
              
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
        if @markSeen
          markSeen = true
        
        fetch = @imap.fetch(searchResults, { bodies: '', markSeen: markSeen })
        # 6. email was fetched. Parse it!   
        fetch.on "message", (msg, id) =>
          parser = new MailParser
          parser.on "end", (mail) =>
            mail.uid = id
            @emit "mail:parsed", mail
          msg.on "body", (stream, info) => 
            buffer = '';
            stream.on "data", (chunk) =>
              buffer += chunk
            stream.once "end", ->
              parser.write buffer
          msg.on "end", ->
            parser.end()

  # imap
  imap = @imap

module.exports = MailListener