// Generated by CoffeeScript 1.6.2
(function() {
  var EventEmitter, ImapConnection, MailListener, MailParser,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require("events").EventEmitter;

  MailParser = require("mailparser").MailParser;

  ImapConnection = require("imap").ImapConnection;

  MailListener = (function(_super) {
    var imap;

    __extends(MailListener, _super);

    function MailListener(options) {
      this._parseUnreadEmails = __bind(this._parseUnreadEmails, this);
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);      this.fetchUnreadOnStart = options.fetchUnreadOnStart;
      this.markSeen = options.markSeen;
      this.imap = new ImapConnection({
        username: options.username,
        password: options.password,
        host: options.host,
        port: options.port,
        secure: options.secure
      });
      this.mailbox = options.mailbox || "INBOX";
    }

    MailListener.prototype.start = function() {
      var _this = this;

      return this.imap.connect(function(err) {
        if (err) {
          return _this.emit("error", err);
        } else {
          _this.emit("server:connected");
          return _this.imap.openBox(_this.mailbox, false, function(err) {
            if (err) {
              return _this.emit("error", err);
            } else {
              if (_this.fetchUnreadOnStart) {
                _this._parseUnreadEmails();
              }
              return _this.imap.on("mail", function(id) {
                _this.emit("mail:arrived", id);
                return _this._parseUnreadEmails();
              });
            }
          });
        }
      });
    };

    MailListener.prototype.stop = function() {
      var _this = this;

      return this.imap.logout(function() {
        return _this.emit("server:disconnected");
      });
    };

    MailListener.prototype._parseUnreadEmails = function() {
      var _this = this;

      return this.imap.search(["UNSEEN"], function(err, searchResults) {
        var params;

        if (err) {
          return _this.emit("error", err);
        } else {
          if (Array.isArray(searchResults) && searchResults.length === 0) {
            return;
          }
          params = {};
          if (_this.markSeen) {
            params.markSeen = true;
          }
          return _this.imap.fetch(searchResults, params, {
            headers: {
              parse: true
            },
            body: true,
            cb: function(fetch) {
              return fetch.on("message", function(msg) {
                var parser;

                parser = new MailParser;
                parser.on("end", function(mail) {
                  mail.uid = msg.uid;
                  return _this.emit("mail:parsed", mail);
                });
                msg.on("data", function(data) {
                  return parser.write(data.toString());
                });
                return msg.on("end", function() {
                  return parser.end();
                });
              });
            }
          });
        }
      });
    };

    imap = MailListener.imap;

    return MailListener;

  })(EventEmitter);

  module.exports = MailListener;

}).call(this);
