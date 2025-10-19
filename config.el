;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-solarized-light)
(setq doom-font "Hack-18")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Jupyter
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (julia . t)
   (python . t)
   (jupyter . t)))

(setq org-babel-default-header-args:jupyter-python '((:async . "yes")
                                                     (:session . "py")))

(use-package! org
  :init
  (defun display-ansi-colors ()
    "Fixes kernel output in emacs-jupyter"
    (ansi-color-apply-on-region (point-min) (point-max))
    (setq org-image-actual-width 600))
  :hook
  (org-mode . (lambda () (add-hook! 'org-babel-after-execute-hook #'(lambda () (run-with-timer 0.2 nil #'display-ansi-colors))))))

;; IPython repl
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt --InteractiveShell.display_page=True")

;; hack for which-key
(use-package! which-key :ensure t :config (setq which-key-use-C-h-commands t) )

;; Word wrap
;; (setq +word-wrap-fill-style 'auto)
;; (setq fill-column 200)


;; LaTeX stuff
(map! :map cdlatex-mode-map :i "TAB" #'cdlatex-tab)
(setq TeX-master nil)

;; citar
(after! citar
  (setq! citar-bibliography '("~/bib/references.bib"))
  (setq! citar-library-paths '("~/bib/library/files"))
  (setq! citar-notes-paths '("~/bib/notes")))

(setq reftex-default-bibliography "~/bib/references.bib")

;;biblio
(setq biblio-download-directory "~/bib/library/files")

;;performance hacks
(setq max-lisp-eval-depth 13000)

;;start full-screened
(add-to-list 'initial-frame-alist '(fullscreen . maximized))


;; get org to shut up
(after! org
  (defun +org-src--drop-org-capf ()
    (setq-local completion-at-point-functions
                (remq #'org-completion-at-point
                      completion-at-point-functions)))
  (add-hook 'org-src-mode-hook #'+org-src--drop-org-capf))

(after! org
  (advice-add 'org-element-at-point :around
              (lambda (orig &rest args)
                (when (derived-mode-p 'org-mode)
                  (apply orig args)))))
