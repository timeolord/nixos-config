(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(defun tex-open-pdf-and-watch ()
  (interactive)
  (split-and-follow-vertically)
  (find-file (concat (file-name-sans-extension buffer-file-name) ".pdf"))
  (async-shell-command "latex-watch.sh"))

(use-package emacs
  :hook ((prog-mode . display-line-numbers-mode)
         (prog-mode . flyspell-prog-mode)
         (text-mode . flyspell-mode))
  :bind (("C-x C-B" . nil)
	       ("C-x C-B" . 'switch-to-buffer)
         ("C-x f" . nil)
	       ("C-x f" . 'find-file)
         ("C-x 2" . nil)
         ("C-x 2" . 'split-and-follow-horizontally)
         ("C-x 3" . nil)
         ("C-x 3" . 'split-and-follow-vertically))
  :config
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)

  (setq inhibit-startup-screen t)
  (setq inhibit-splash-screen t)

  ;; Auto-saves and backups
  (defvar backup-dir (expand-file-name "~/emacs/backups/"))
  (defvar autosave-dir (expand-file-name "~/emacs/autosaves/"))
  (setq backup-directory-alist (list (cons ".*" backup-dir)))
  (setq auto-save-list-file-prefix autosave-dir)
  (setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

  ;; Hide Window Frame and Full Screen and Maximize
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(undecorated . t))

  (set-frame-parameter nil 'alpha-background 95) ; For current frame
  (add-to-list 'default-frame-alist '(alpha-background . 95)) ; For all new frames
  
  (require 'use-package-ensure)
  (setq use-package-always-ensure t)

  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (global-auto-revert-mode t)
  
  (defalias 'yes-or-no-p 'y-or-n-p)

  (setq blink-cursor-mode nil)

  (setq-default indent-tabs-mode nil
                tab-width 2
                c-basic-offset 2)
  (set-frame-font "JetBrainsMono 12" nil t)
  :custom
  (completion-cycle-threshold nil)
  ;; (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package markdown-mode
  :ensure t)

(use-package pdf-tools
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))
                                        ;(add-hook 'latex-mode-hook 'tex-open-pdf-and-watch)
  )

;; TODO: Learn how to use multiple cursors.
(use-package multiple-cursors
  :ensure t
  :defer t)

;; TODO: Learn how to use magit
(use-package magit
  :ensure t
  :defer t)

(use-package treemacs
  :ensure t
  :bind (("M-0" . treemacs-select-window)
         ("C-x t t" . treemacs))
  :defer t
  :config
  (treemacs-filewatch-mode t)
  (treemacs-project-follow-mode t)
  (treemacs-indent-guide-mode t)
  (setq treemacs-is-never-other-window t))

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package all-the-icons
  :ensure t)

(use-package treemacs-all-the-icons
  :ensure t
  :after (treemacs all-the-icons)
  :config
  (treemacs-load-theme "all-the-icons"))

(use-package electric-operator
  :ensure t
  :defer t
  :hook (python-mode python-inferior-mode))

(use-package nix-mode
  :ensure t
  :defer t)

(use-package smartparens
  :ensure t
  :defer t
  :hook (prog-mode text-mode markdown-mode python-shell-mode python-inferior-mode)
  :config
  (require 'smartparens-config)
  (setq smartparens-global-mode t))

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook ((prog-mode . rainbow-delimiters-mode)
         (text-mode . rainbow-delimiters-mode)
         (markdown-mode . rainbow-delimiters-mode)))

(use-package solaire-mode
  :ensure t
  :config
  (solaire-global-mode +1))

(use-package doom-modeline
  :ensure t
  :config
  (doom-modeline-mode 1))

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one))

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-height 15
        ivy-use-virtual-buffers t
        ivy-use-selectable-prompt t))

(use-package counsel
  :ensure t
  :after ivy
  :config
  (counsel-mode 1)
  :bind (:map ivy-minibuffer-map))

(use-package corfu
  :ensure t
  :bind ((:map corfu-map ("C-n" . corfu-next))
	 (:map corfu-map ("C-p" . corfu-previous))
	 (:map corfu-map ("<escape>" . corfu-quit))
	 (:map corfu-map ("<return>" . corfu-insert))
	 (:map corfu-map ("M-d" . corfu-show-documentation))
	 (:map corfu-map ("M-l" . corfu-show-location))
	 )
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)        ; Only use `corfu' when calling `completion-at-point' or `indent-for-tab-command'
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-min-width 80)
  (corfu-max-width corfu-min-width)       ; Always have the same width
  (corfu-count 14)
  (corfu-scroll-margin 4)
  (corfu-cycle nil))
(use-package eglot
  :ensure t
  :bind (("C-c a" . eglot)
         ("C-c w" . eglot-code-action)
         ("C-c x" . eglot-format))
  :hook ((haskell-mode . eglot-ensure)
         (python-mode. eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
  (setq-default eglot-workspace-configuration
                '(:haskell (:plugin (:stan (:globalOn t)) :formattingProvider "ormolu")))
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))

(use-package eglot-booster
  :ensure t
	:after eglot
	:config	(eglot-booster-mode))

;; Rust Config
(use-package rust-mode
  :ensure t
  :defer t)

;; Python Config
(use-package reformatter
  :ensure t
  :defer t)
(use-package ruff-format
  :ensure t
  :defer t
  :hook (python-mode . ruff-format-on-save-mode)
)

;; Zig Config
(use-package zig-mode
  :ensure t
  :defer t)

;; Haskell Config
(use-package haskell-mode
  :ensure t
  :defer t
  :bind ((:map haskell-mode-map ("C-c C-c" . haskell-compile))
	       (:map haskell-cabal-mode-map ("C-c C-c" . haskell-compile)))
  :hook ((haskell-mode . turn-on-haskell-doc-mode)
	       (haskell-mode . turn-on-haskell-indentation))
  :config
  (add-to-list 'completion-ignored-extensions ".hi"))

;; Fish Config
(use-package fish-mode
  :ensure t
  :defer t)
