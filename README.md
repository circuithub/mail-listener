# Overview

Mail listener library for node.js. Get notification when new email arrived to inbox. Uses IMAP protocol.

We are using these libraries: [node-imap](https://github.com/mscdex/node-imap), [mailparser](https://github.com/andris9/mailparser).

Heavily inspired by [this gist](https://gist.github.com/1226809).

## Use

Install

`npm install mail-listener`


JavaScript Code:


```javascript

var MailListener = require("mail-listener");

var mailListener = new MailListener({
  username: "imap-username",
  password: "imap-password",
  host: "imap-host",
  port: 993, // imap port
  secure: true, // use secure connection
  mailbox: "INBOX", // mailbox to monitor
  markSeen: true, // all fetched email willbe marked as seen and not fetched next time
  fetchUnreadOnStart: true // use it only if you want to get all unread email on lib start. Default is `false`
});

mailListener.start();

mailListener.on("server:connected", function(){
  console.log("imapConnected");
});
  
mailListener.on("mail:arrived", function(id){
  console.log("new mail arrived with id:" + id);
});

mailListener.on("mail:parsed", function(mail){
  // do something with mail object including attachments
  console.log("emailParsed", mail.attachments);
  // mail processing code goes here
});

// it's possible to access imap object from node-imap library for performing additional actions. E.x.
mailListener.imap.move(:msguids, :mailboxes, function(){}) 

```

CoffeeScript Code:


``` coffee

MailListener = require "mail-listener"

mailListener = new MailListener
  username: "imap-username"
  password: "imap-password"
  host: "imap-host"
  port: 993 # imap port
  secure: true # use secure connection
  mailbox: "INBOX" # mailbox to monitor
  markSeen: true # all fetched email willbe marked as seen and not fetched next time
  fetchUnreadOnStart: true # use it only if you want to get all unread email on lib start. Default is `false`


 # start listener. You can stop it calling `stop method`
mailListener.start()

# subscribe to server connected event
mailListener.on "server:connected", ->
  console.log "imap connected"

# subscribe to error events
mailListener.on "error", (err) ->
  console.log "error happened", err

# mail arrived and was parsed by parser 
mailListener.on "mail:parsed", (mail) ->
  # do something with mail object including attachments
  console.log "parsed email with attachment", mail.attachments
  ## mail processing code goes here

## it's possible to access imap object from node-imap library for performing additional actions. E.x.
mailListener.imap.move :msguids, :mailboxes, ->
```

That's easy!


## Contributions

Mail-listener is ready to use in your project. However if you need any feature tell us or fork project and implement it by yourself.

We appreciate feedback!

## License

(The MIT License)

Copyright (c) 2011-2013 CircuitHub., https://circuithub.com/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
