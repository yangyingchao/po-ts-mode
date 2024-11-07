;;; po-ts-mode.el --- tree-sitter support for PO  -*- lexical-binding: t; -*-

;; Copyright (C) 2022-2024 Free Software Foundation, Inc.

;; Author     : Theodor Thornhill <theo@thornhill.no>
;; Maintainer : Theodor Thornhill <theo@thornhill.no>
;; Created    : November 2022
;; Keywords   : po languages tree-sitter

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;

;;; Code:

(require 'treesit)
(require 'rx)

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-induce-sparse-tree "treesit.c")
(declare-function treesit-node-start "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-node-child-by-field-name "treesit.c")


(defcustom po-ts-mode-indent-offset 2
  "Number of spaces for each indentation step in `po-ts-mode'."
  :version "29.1"
  :type 'integer
  :safe 'integerp
  :group 'po)

(defvar po-ts-mode--syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?_  "_"     table)
    (modify-syntax-entry ?\\ "\\"    table)
    (modify-syntax-entry ?+  "."     table)
    (modify-syntax-entry ?-  "."     table)
    (modify-syntax-entry ?=  "."     table)
    (modify-syntax-entry ?%  "."     table)
    (modify-syntax-entry ?<  "."     table)
    (modify-syntax-entry ?>  "."     table)
    (modify-syntax-entry ?&  "."     table)
    (modify-syntax-entry ?|  "."     table)
    (modify-syntax-entry ?\' "\""    table)
    (modify-syntax-entry ?\240 "."   table)
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?*  ". 23"   table)
    (modify-syntax-entry ?\n "> b"  table)
    (modify-syntax-entry ?\^m "> b" table)
    table)
  "Syntax table for `po-ts-mode'.")

(defvar po-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'po
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'po
   :feature 'keyword
   '([(msgid) (msgstr)] @font-lock-keyword-face)

   :language 'po
   :feature 'string
   :override t
   '([(string) (string_fragment)] @font-lock-string-face)

   :language 'po
   :feature 'escape-sequence
   :override t
   '((escape_sequence) @font-lock-escape-face)

   :language 'po
   :feature 'pair
   :override t ; Needed for overriding string face on keys.
   '((reference "#:" (_) @font-lock-property-use-face))

   :language 'po
   :feature 'error
   :override t
   '((ERROR) @font-lock-warning-face))
  "Font-lock settings for PO.")

;;;###autoload
(define-derived-mode po-ts-mode fundamental-mode "PO[ts]"
  "Major mode for editing PO, powered by tree-sitter."
  :group 'po
  :syntax-table po-ts-mode--syntax-table

  (unless (treesit-ready-p 'po)
    (error "Tree-sitter for PO isn't available"))

  (treesit-parser-create 'po)

  ;; Comments.
  (setq-local comment-start "#")
  (setq-local comment-start-skip "\\(?://+\\|/\\*+\\)\\s *")
  (setq-local comment-end "")

  (setq-local treesit-thing-settings `((po (sentence "pair"))))

  ;; Font-lock.
  (setq-local treesit-font-lock-settings po-ts-mode--font-lock-settings)
  (setq-local font-lock-defaults nil)
  (setq-local treesit-font-lock-feature-list
    '((comment constant keyword number pair string escape-sequence)
      (bracket delimiter error)))

  (treesit-major-mode-setup))

(if (treesit-ready-p 'po)
    (add-to-list 'auto-mode-alist
                 '("\\.po\\'" . po-ts-mode)))

(provide 'po-ts-mode)

;;; po-ts-mode.el ends here
