(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(require 'bind-key)
(require 'diminish)

(defun my/add-to-hooks (func hooks)
  (mapc (lambda (hook)
          (add-hook hook func))
        hooks))

;;;; standard-settings
(delete-selection-mode 1)
(menu-bar-mode 0)
(show-paren-mode 1)
(tool-bar-mode 0)
(global-subword-mode 1) ; Iterate over camelCasedWords
(electric-pair-mode)
(setq vc-follow-symlinks t) ; follow symlinks without asking

(setq visible-bell nil)
(setq ring-bell-function 'ignore)

(setq backup-dir "~/emacs-backups")
(setq backup-directory-alist `((".*" . ,backup-dir)))
(setq auto-save-file-name-transforms `((".*" ,backup-dir t)))

(setq inhibit-startup-message nil)
(setq inhibit-startup-message t)
;; fix scrolling
(setq-default redisplay-dont-pause t
              scroll-margin 1
              scroll-step 1
              scroll-conservatively 10000
              scroll-preserve-screen-position 1
              scroll-up-aggressively 0.01
              scroll-down-aggressively 0.01)

;; Use spaces by default
(setq-default indent-tabs-mode nil)

(fset 'yes-or-no-p 'y-or-n-p)

;; better keybinds for pane splits and moving around
(bind-keys*
 ("C-x -" . split-window-below)
 ("C-x |" . split-window-right)
 ("C-S-n" . (lambda ()
                  (interactive)
                  (ignore-errors (next-line 5))))
 ("C-S-p" . (lambda ()
                  (interactive)
                  (ignore-errors (previous-line 5)))))

;; save buffer on biffer switch
;; http://stackoverflow.com/questions/1413837/emacs-auto-save-on-switch-buffer
(defadvice switch-to-buffer (before save-buffer-now activate)
  (when buffer-file-name (save-buffer)))
(defadvice other-window (before other-window-now activate)
  (when buffer-file-name (save-buffer)))
(defadvice other-frame (before other-frame-now activate)
  (when buffer-file-name (save-buffer)))
(defadvice ace-window (before other-frame-now activate)
  (when buffer-file-name (save-buffer)))

(diminish 'subword-mode)
(diminish 'auto-revert-mode)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;;;; core
(use-package swiper
  :ensure t
  :bind* ("C-s" . swiper))

(use-package flx
  :ensure t)

(use-package smex
  :ensure t)

(use-package ivy
  :init
  (ivy-mode)
  (setq ivy-display-style 'fancy)
  (setq ivy-initial-inputs-alist nil)
  :bind (:map ivy-minibuffer-map
              ("C-j" . ivy-immediate-done))
  :diminish ivy-mode)

(use-package counsel
  :ensure t
  :bind*
  (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   ("C-c g" . counsel-ag)
   ("C-h b" . counsel-descbinds)
   ("C-h f" . counsel-describe-function)))

(use-package ibuffer
  :ensure t
  :bind* ("C-x C-b" . ibuffer))

(use-package ansi-term
  :init
  (let ((preferred-shell "/usr/local/bin/zsh"))
    (if (file-executable-p preferred-shell)
        (setq explicit-shell-file-name preferred-shell))))

(use-package dired+
  :ensure t
  :defer t
  :init
  (if (executable-find "gls")
      (progn
        (setq insert-directory-program "gls")
        (setq dired-listing-switches "-lFaGh1v --group-directories-first")))
  (diredp-toggle-find-file-reuse-dir 1)
  (add-to-list 'dired-omit-extensions ".DS_Store")
  (customize-set-variable 'diredp-hide-details-initially-flag nil))

(use-package undo-tree
  :ensure t
  :defer t
  :diminish undo-tree-mode
  :init (global-undo-tree-mode)
  :bind* ("M-/" . undo-tree-visualize))

(use-package expand-region
  :ensure t
  :defer t
  :bind*
  (("M-=" . er/expand-region)
   ("M--" . er/contract-region)))

(use-package avy
  :ensure t)

(use-package visual-regexp-steroids
  :ensure t
  :defer t
  :bind ("C-x r r" . vr/query-replace))

(use-package projectile
  :ensure t
  :defer t
  :init
  (projectile-global-mode)
  (setq projectile-completion-system 'ivy))

(use-package exec-path-from-shell
  :ensure t
  :init
  (exec-path-from-shell-initialize))

(use-package multiple-cursors
  :ensure t
  :defer t
  :bind*
  ("M-n" . mc/mark-next-like-this)
  ("M-p" . mc/mark-previous-like-this))

(use-package company
  :ensure t
  :defer t
  :diminish company-mode
  :init (global-company-mode)
  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)))

(use-package magit
  :ensure t
  :defer t
  :bind*
  (("<f11>" . magit-log-all)
   ("<f12>" . magit-status)))

(use-package git-gutter
  :ensure t
  :diminish git-gutter-mode
  :init (global-git-gutter-mode t))

(use-package ws-butler
  :ensure t
  :diminish ws-butler-mode
  :init
  (ws-butler-global-mode))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :init (which-key-mode)
  :config (setq which-key-idle-delay 1.5))

;; borrowed from http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (file-executable-p eslint)
      (setq-local flycheck-javascript-eslint-executable eslint)
      (setq-local flycheck-eslint root))))


(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :init
  (my/add-to-hooks 'flycheck-mode '(js-mode-hook
                                    emacs-lisp-mode))
  (add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)
  (setq flycheck-disabled-checkers '(javascript-jshint))
  (setq flycheck-checkers '(javascript-eslint)))

;; MODES

;; web
(use-package web-mode
  :ensure t
  :config
  (setq-default indent-tabs-mode nil)
  (let ((default-offset 2)
        (default-padding 0))
    (setq web-mode-markup-indent-offset default-offset)
    (setq web-mode-css-indent-offset default-offset)
    (setq web-mode-code-indent-offset default-offset)
    (setq web-mode-script-padding default-padding)
    (setq web-mode-style-padding default-padding)
    (setq web-mode-block-padding default-padding))
  :mode ("\\.html?\\'"
         "\\.vue?\\'"))

(use-package emmet-mode
  :ensure t
  :defer t
  :init (my/add-to-hooks 'emmet-mode '(web-mode-hook
                                       html-mode-hook
                                       vue-mode-hook
                                       js-mode-hook)))

;; js
(defun my/set-js-indent (&optional indent)
  (interactive "P")
  (let ((js-indent (if (not indent)
                       (string-to-int (read-from-minibuffer "Set to: "))
                       indent)))
    (setq js-indent-level js-indent)
    (setq js2-indent-level js-indent)
    (setq js2-basic-offset js-indent)
    (setq sgml-basic-offset js-indent)))

(use-package js2-mode
  :ensure t
  :init
  (my/set-js-indent 2)
  :mode
  ("\\.js?\\'" . js2-jsx-mode))


;; elisp
(use-package paredit
  :ensure t
  :init (add-hook 'emacs-lisp-mode-hook 'paredit-mode))

(use-package rainbow-delimiters
  :ensure t
  :init (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode))

;; elixir
(use-package elixir-mode
  :ensure t)

(use-package alchemist
  :ensure t
  :init (add-hook 'elixir-mode 'alchemist-mode))

;; haskell
(use-package haskell-mode
  :init (add-hook 'haskell-mode-hook #'intero-mode)
  :ensure t)

(use-package intero
  :ensure t)

;; rest
(use-package markdown-mode
  :ensure t
  :init (add-hook 'markdown-mode-hook #'flyspell-mode)
  :config
  (progn
    ;; stolen from spacemacs
    (require 'org-table)
    (defun cleanup-org-tables ()
      (save-excursion
        (goto-char (point-min))
        (while (search-forward "-+-" nil t) (replace-match "-|-"))))
    (add-hook 'markdown-mode-hook 'orgtbl-mode)
    (add-hook 'markdown-mode-hook
              (lambda()
                (add-hook 'after-save-hook 'cleanup-org-tables  nil 'make-it-local))))
  :mode "\\.md?\\'")

(use-package auctex
  :defer t
  :ensure t)

(use-package latex-preview-pane
  :ensure t
  :config (setq shell-escape-mode "-shell-escape"))

;; LOOKS
;; theme
(use-package arjen-grey-theme
  :ensure t
  :init
  (load-theme 'arjen-grey t))

(defun my/set-font-height (height)
  (set-face-attribute 'default nil :font "Source Code Pro" :height height))

(setq my/default-font-height 130)
(setq my/live-coding-font-height 200)

(my/set-font-height my/default-font-height)
(defun my/toggle-live-coding ()
  (interactive)
  (let ((default-height my/default-font-height)
        (live-coding-height my/live-coding-font-height)
        (current-height (face-attribute 'default :height)))
    (if (>= current-height live-coding-height)
        (my/set-font-height default-height)
      (my/set-font-height live-coding-height))))

