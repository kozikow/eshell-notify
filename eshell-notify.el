;;; eshell-notify.el --- notifications about completed eshell commands

;; Copyright (C) 2014  Robert Kozikowski

;; Author: Robert Kozikowski <r.kozikowski@gmail.com>
;; Keywords: eshell, lisp

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This file hooks into eshell mode to provide system notifications
;; about finished commands that took longer than
;; eshell-notify-minimum-threshold-seconds .
;; I use notify.el to send a system notifcation and buffer name for message
;; body. What I typically do is I have buffer named related to the command it
;; is doing - for example eshell-compilation , eshell-tests or
;; eshell-mapreduce
;;
;; By default notify.el have minimum 5 seconds delay between messages.
;; If you want to disable it (I did) run (setq notify-delay '(0 0 0))
;;; Code:

(defvar eshell-notify-buffer-to-time-hash-list
  (make-hash-table :test 'equal)
  "A hash table collecting start time of last eshell command for each buffer.
Hash key is a name of a buffer. Hash value is a result of float-time at the 
start of the last eshell command in that buffer")

(defvar eshell-notify-minimum-threshold-seconds 10)

(defvar eshell-notify-message-title "Command finished")

(defun eshell-notify-get-message-body (buffer elapsed)
  (format
   "Command in buffer %s finished after %.f seconds."
   buffer
   elapsed
   ))

(defun eshell-maybe-notify ()
  "Function that checks if time elapsed from last command is higher than
   eshell-notify-minimum-threshold-seconds and if yes posts a notification
   to the operating system with current buffer name"
  (setq elapsed-time (-
     (float-time)
     (gethash (buffer-name) eshell-notify-buffer-to-time-hash-list (float-time))
     ))
  (if (> elapsed-time eshell-notify-minimum-threshold-seconds)
      (notify
       eshell-notify-message-title
       (eshell-notify-get-message-body (buffer-name) elapsed-time))
    )
)

(defun eshell-record-last-command-time ()
  "Records time of last eshell command ran in given buffer"
  (puthash
   (buffer-name)
   (float-time)
   eshell-notify-buffer-to-time-hash-list))

;;;###autoload

(add-hook 'eshell-pre-command-hook 'eshell-record-last-command-time)
(add-hook 'eshell-post-command-hook 'eshell-maybe-notify)

;;; eshell-notify.el ends here
