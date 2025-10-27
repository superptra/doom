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
(setq doom-theme 'doom-dracula)
(if (featurep :system 'macos)
    (setq doom-font "Menlo-22")
    (setq doom-font "Hack-18"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                Corfu                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(after! corfu
  (setq corfu-auto nil
        +corfu-want-tab-prefer-expand-snippets t
        +corfu-want-tab-prefer-navigating-snippets t
        +corfu-want-tab-prefer-navigating-org-tables t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;               Jupyter               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Jupyter
(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (julia . t)
     (latex . t)
     (python . t)
     (jupyter . t))))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                 Org                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! org
  (setq! org-highlight-latex-and-related '(native)))
(after! org
  (setq! org-agenda-todo-list-sublevels 'nil)) ; not sure about this

;; (after! org
;;   (setq org-todo-keywords '((sequence "TODO(t)" "NEXT(N)" "PROJ(p)" "LOOP(r)" "STRT(s)" "WAIT(w)" "HOLD(h)" "IDEA(i)"
;;            "|" "DONE(d)" "KILL(k)")
;;        (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")
;;               (sequence "|" "OKAY(o)" "YES(y)" "NO(n)"))))
(after! org
  (setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "STRT(s)"
           "|" "DONE(d)")
       (sequence "[ ](T)" "[-](S)" "|" "[X](D)")
              (sequence "WAIT(w)" "HOLD(h)" "MAYBE(m)" "|" "KILL(k)")
              (sequence "PROJ(p)" "LOOP(r)" "|"))))
(after! org
  (add-to-list 'org-todo-keyword-faces '("NEXT" . +org-todo-active)))

(after! org
  (setq org-md-headline-style 'setext))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                Python               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; IPython repl
(after! python
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --simple-prompt --InteractiveShell.display_page=True"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                LaTeX                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; LaTeX stuff
(map! :map cdlatex-mode-map :i "TAB" #'cdlatex-tab)
(after! tex
  (setq-default TeX-master nil))

;; citar
(after! citar
  (setq citar-bibliography "~/bib/references.bib"
        citar-library-paths "~/bib/library/files"
        citar-notes-paths "~/bib/notes"))

(after! reftex
  (setq reftex-default-bibliography "~/bib/references.bib"))

;;biblio
(use-package! biblio
  :custom
  (biblio-download-directory "~/bib/library/files"))


(map! :map cdlatex-mode-map
        :i "TAB" #'cdlatex-tab)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                 Misc                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;performance hacks
(setq max-lisp-eval-depth 13000)

;;start full-screened
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; hack for which-key
(after! which-key :ensure t :config (setq which-key-use-C-h-commands t) )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                Godot                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; godot
(setq treesit-extra-load-path '("~/repos/tree-sitter-gdscript/src/"))
(setq gdscript-godot-executable "/home/pixie/.bin/Godot_v4.5-stable_mono_linux_x86_64/Godot_v4.5-stable_mono_linux.x86_64")

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((gdscript-mode gdscript-ts-mode) . ("localhost" 6008))))
