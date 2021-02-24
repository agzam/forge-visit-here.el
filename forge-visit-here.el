;;; forge-visit-here.el --- Browse Git Forge links locally -*- lexical-binding: t; -*-
;;
;; Author: Ag Ibragimov
;; URL: https://github.com/agzam/forge-visit-here.el
;; Created: Feb-2021
;; Keywords: vc, tools
;; License: GPL v3
;; Package-Requires: ((emacs "27") (magit "20210221.2138"))
;; Version: 1.0.0

;;; Commentary:

;; Tiny extension for Magit that can take a GitHub link like:
;; https://github.com/magit/forge/blob/master/lisp/forge-core.el#L23 and use
;; Magit to find that file locally, assuming you previously cloned the repo.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;;; Code:

(require 'magit)

;; Set `magit-repository-directories', so then it tries to find the directory
;; based on (magit-repos-alist)

(defun forge-visit-here (&optional uri)
  "Open given GitHub URI locally using magit-find-file."
  (interactive)
  (pcase-let* ((uri (or uri (current-kill 0)))
               ;; first try to retrieve initial parts from the URI
               (`(_ _ _ ,repo ,link-type ,rev) (remove "" (split-string uri "/")))
               ;; then try to grab file-path (which is right after the revision SHA/branch name),
               ;; along the line number (if present), which usually comes after "#L"
               (regexp (concat rev "/\\(\\(.*\\(#L\\)\\([0-9]+\\)\\)\\|\\(.*$\\)\\)"))
               (_ (string-match regexp uri))
               (path (replace-regexp-in-string "#L[0-9]+" "" (match-string 1 uri)))
               (line-number (string-to-number (or (match-string 4 uri) "")))
               ;; find the repo directory in magit-repos list, or prompt when not found
               (default-directory
                 (or (alist-get repo (magit-repos-alist) nil nil 'string-match)
                     (read-directory-name (format "Specify dir for '%s' repo: " repo))))
               (_ (when (not (or path rev))
                    (user-error "Could not parse GitHub link")))
               (buf (magit-find-file rev path)))
    (when (and buf (< 0 line-number))
      (with-no-warnings
        (goto-line line-number)))))

(provide 'forge-visit-here)

;;; forge-visit-here.el ends here
