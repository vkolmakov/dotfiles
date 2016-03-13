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

;;;; standard-settings
(delete-selection-mode 1)
(menu-bar-mode 0)
(show-paren-mode 1)
(global-hl-line-mode)
(global-subword-mode 1) ; Iterate over camelCasedWords
(electric-pair-mode)
(setq vc-follow-symlinks t) ; follow symlinks without asking

(setq backup-directory-alist `(("." . "~/emacs-backups")))
(toggle-truncate-lines 0)
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

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(diminish 'subword-mode)
(diminish 'auto-revert-mode)

;; ask before closing emacs
(global-set-key (kbd "C-x C-c")
                (lambda () (interactive)
                  (cond ((y-or-n-p "Close this session?")
                         (save-buffers-kill-terminal)))))

;; create a command to clear kill-ring
(defun my/clear-kill-ring ()
  "Clears out kill-ring contents"
  (interactive)
  (progn (setq kill-ring nil) (garbage-collect)))

;;;; core
(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))

(use-package flx
  :ensure t)

(use-package smex
  :ensure t)

(use-package ivy
  :init (progn
          (ivy-mode)
          (setq ivy-display-style 'fancy)
          (setq ivy-re-builders-alist
                '((t . ivy--regex-fuzzy)))
          (setq ivy-initial-inputs-alist nil))
  :bind (:map ivy-minibuffer-map
              ("C-j" . ivy-immediate-done))
  :diminish ivy-mode)

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("M-y" . counsel-yank-pop)
         ("C-c g" . counsel-git-grep)
         ("C-h b" . counsel-descbinds)
         ("C-h f" . counsel-describe-function)
         ("C-c k" . counsel-ag)))

;;;; org-mode
(use-package org
  :mode (("\\.org$" . org-mode))
  :init (global-set-key (kbd "C-c a") 'org-agenda)
  :config (progn
            (org-indent-mode 1)
            (setq org-src-fontify-natively t)
            (setq org-agenda-files (list "~/org/agenda/work.org"
                                         "~/org/agenda/school.org"
                                         "~/org/agenda/personal.org"))))

;;;; general-utils
(use-package company
  :ensure t
  :defer t
  :diminish company-mode
  :init (progn
          (global-company-mode)
          (define-key company-active-map (kbd "C-n") 'company-select-next)
          (define-key company-active-map (kbd "C-p") 'company-select-previous)
          (setq company-minimum-prefix-length 2)
          (add-to-list 'company-backends 'company-css t)
          (add-to-list 'company-backends 'company-files t)))

(use-package magit
  :ensure t
  :defer t
  :bind (("<f11>" . magit-log-all)
         ("<f12>" . magit-status)))

(use-package ibuffer
  :ensure t
  :bind ("C-x C-b" . ibuffer))

(use-package dired+
  :ensure t
  :defer t
  :init (progn (if (executable-find "gls")
                   (progn
                     (setq insert-directory-program "gls")
                     (setq dired-listing-switches "-lFaGh1v --group-directories-first")))
               (diredp-toggle-find-file-reuse-dir 1)
               (add-to-list 'dired-omit-extensions ".DS_Store")
               (customize-set-variable 'diredp-hide-details-initially-flag nil)))

(use-package undo-tree
  :ensure t
  :defer t
  :diminish undo-tree-mode
  :config (global-undo-tree-mode)
  :bind ("M-/" . undo-tree-visualize))

(use-package comment-dwim-2
  :ensure t
  :defer t
  :bind ("M-;" . comment-dwim-2))

(use-package expand-region
  :ensure t
  :defer t
  :bind (("M-=" . er/expand-region)
         ("M--" . er/contract-region)))

(use-package avy
  :ensure t
  :bind ("M-a" . avy-goto-char))

(use-package visual-regexp-steroids
  :ensure t
  :defer t
  :bind ("C-c r" . vr/select-query-replace))

(use-package projectile
  :ensure t
  :defer t
  :init (progn
          (projectile-global-mode)
          (setq projectile-completion-system 'ivy)))

(use-package ace-window
  :ensure t
  :defer t
  :bind ("C-x o" . ace-window))

(use-package simpleclip
  :ensure t
  :bind (("C-x C-w" . simpleclip-copy)
         ("C-x C-y" . simpleclip-paste)))

(use-package multiple-cursors
  :ensure t
  :defer t
  :bind (("M-n" . mc/mark-next-like-this)
         ("M-m" . mc/mark-previous-like-this)))

;;;; python
(use-package elpy
  :ensure t
  :init (add-hook 'python-mode-hook (lambda ()
                                      (elpy-mode))))

;;; web-stuff
(use-package web-mode
  :ensure t
  :defer t
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
          (setq web-mode-enable-auto-pairing t)
          (setq web-mode-enable-current-element-highlight t)
          (setq-default indent-tabs-mode nil)
          (setq web-mode-markup-indent-offset 4)
          (setq web-mode-css-indent-offset 4)
          (setq web-mode-code-indent-offset 4)))

(use-package emmet-mode
  :ensure t
  :defer t
  :init (add-hook 'web-mode-hook 'emmet-mode))

(use-package json-mode
  :ensure t
  :config (add-to-list 'auto-mode-alist '("\\.json?\\'" . json-mode)))

;;;; javascript
(use-package js2-mode
  :ensure t
  :defer t
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
          (setq js2-global-externs '("module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON"))
          (setq js2-idle-timer-delay 0.1)))

(use-package tern
  :ensure t
  :init (progn
          (add-hook 'js-mode-hook (lambda () (tern-mode t)))))

(use-package company-tern
  :ensure t
  :init (progn
          (add-to-list 'company-backends 'company-tern)))

(use-package nodejs-repl
  :ensure t)

;;;; lisp
(use-package paredit
  :ensure t)

(use-package rainbow-delimiters
  :ensure t)

(use-package slime
  :ensure t
  :defer t
  :init (progn
          (load (expand-file-name "~/quicklisp/slime-helper.el"))
          (slime-setup '(slime-fancy slime-company))
          (setq inferior-lisp-program "sbcl")
	  (setq slime-protocol-version 'ignore)

          (define-key slime-repl-mode-map (kbd "DEL") nil)
          (define-key slime-repl-mode-map (kbd "M-RET") 'slime-repl-newline-and-indent)

          (defun my/lisp-hook ()
            (rainbow-delimiters-mode 1)
            (paredit-mode 1)
            (eldoc-mode 1)
            (setq eldoc-idle-delay 0.3)
            (diminish 'eldoc-mode))

          (add-hook 'slime-repl-mode-hook 'my/lisp-hook)
          (add-hook 'lisp-mode-hook 'my/lisp-hook)))

(add-hook 'emacs-lisp-mode-hook (lambda ()
                                  (diminish 'eldoc-mode)
                                  (paredit-mode 1)
                                  (setq eldoc-idle-delay 0.3)
                                  (eldoc-mode 1)))

(use-package slime-company
  :ensure t)

;;;; looks
(defmacro my/set-theme (tname)
  "Install and set theme using use-package"
  (let ((theme-name tname)
        (package-name (funcall (lambda ()
                                 (intern (concat
                                          (symbol-name tname)
                                          "-"
                                          (symbol-name 'theme)))))))
    `(use-package ,package-name
       :ensure t
       :config (load-theme ',theme-name t))))

(my/set-theme material)
;; (load-theme 'material-light t)

(defun my/shorten-dir (dir-str)
  "Given a directory keep the only the last two items"
  (let ((dirs (reverse (split-string dir-str "/"))))
    (cond ((and (equal (car dirs) "")
                (equal (cadr dirs) ""))
           "/")
          ((and (equal (car dirs) "")
                (or (equal (cadr dirs) user-login-name)
                    (equal (cadr dirs) "~")))
           "~")
          (t (cadr dirs)))))

(setq mode-line-format
      (setq default-mode-line-format
            (list '("-"
                    (:eval (if (buffer-modified-p) "M" "-"))
                    (:eval (if buffer-read-only    "R" "-"))
                    " "
                    mode-line-buffer-identification
                    " "
                    mode-line-position
                    "\tat:"
                    (:eval (my/shorten-dir default-directory))
                    " "
                    vc-mode
                    " "
                    mode-line-modes))))

(use-package golden-ratio
  :ensure t
  :bind ("M-o" . golden-ratio))
