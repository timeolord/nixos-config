;; Keybinds
(global-set-key (kbd "M-;") nil)
(global-set-key (kbd "M-;") 'comment-line)
(global-set-key (kbd "C-x C-B") 'switch-to-buffer)
(global-set-key (kbd "C-x f") nil)
(global-set-key (kbd "C-x f") 'find-file)

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Autosaves and backups
(defvar backup-dir (expand-file-name "~/emacs/backups/"))
(defvar autosave-dir (expand-file-name "~/emacs/autosaves/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

;; Hide Window Frame and Full Screen and Maximize
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(undecorated . t))

(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)

(require 'use-package-ensure)
(setq use-package-always-ensure t)

(set-frame-parameter nil 'alpha-background 95) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 95)) ; For all new frames henceforth

;; Flycheck is the newer version of flymake and is needed to make lsp-mode not freak out.
;; (use-package flycheck
;;   :ensure t
;;   :defer t
;;   :hook ((prog-mode)
;; 	       (after-init . global-flycheck-mode)))

(use-package emacs
  :custom
  (completion-cycle-threshold nil)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

;; TODO: Learn how to use multiple cursors.
(use-package multiple-cursors
  :ensure t
  :defer t)

;; TODO: Learn how to use magit
(use-package magit
  :ensure t
  :defer t)

(use-package dirvish
  :ensure t
  :defer t)

(use-package electric-operator
  :ensure t
  :defer t
  :hook (python-mode))

(use-package nix-mode
  :ensure t
  :defer t
  :mode "\\.nix\\'")

(use-package smartparens
  :ensure t
  :defer t
  :hook (prog-mode text-mode markdown-mode python-shell-mode inferior-mode)
  :config
  (require 'smartparens-config))

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

;; We need something to manage the various projects we work on
;; and for common functionality like project-wide searching, fuzzy file finding etc.
;; (use-package projectile
;;   :init
;;   (projectile-mode t) ;; Enable this immediately
;;   :config
;;   (setq projectile-enable-caching t ;; Much better performance on large projects
;;         projectile-completion-system 'ivy)) ;; Ideally the minibuffer should aways look similar

;; Counsel and projectile should work together.
;; (use-package counsel-projectile
;;   :init
;;   (counsel-projectile-mode))

;; Company is the best Emacs completion system.
;; (use-package company
;;   :ensure t
;;   :defer t
;;   :bind (("C-." . company-complete))
;;   :custom
;;   (company-minimum-prefix-length 1)
;;   (company-idle-delay 0)
;;   (company-dabbrev-downcase nil "Don't downcase returned candidates.")
;;   (company-show-numbers t "Numbers are helpful.")
;;   (company-tooltip-limit 10 "The more the merrier.")
;;   :config
;;   (global-company-mode t)
;;   ;; use numbers 0-9 to select company completion candidates
;;   (let ((map company-active-map))
;;     (mapc (lambda (x) (define-key map (format "%d" x)
;;                                   `(lambda () (interactive) (company-complete-number ,x))))
;;           (number-sequence 0 9))))

;; Package for interacting with language servers
;; (use-package lsp-mode
;;   :ensure t
;;   :defer t
;;   :commands lsp
;;   :config
;;   (setq lsp-prefer-flymake nil))

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
  :hook (haskell-mode . eglot-ensure)
  :config
  (setq-default eglot-workspace-configuration
                '(:haskell (:plugin (:stan (:globalOn t))
                                    :formattingProvider "ormolu")))
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
;; (use-package flycheck-rust
;;   :ensure t
;;   :defer t
;;   :hook (flycheck-mode . flycheck-rust-setup))

;; Python Config
(use-package reformatter
  :ensure t
  :defer t)
(use-package ruff-format
  :ensure t
  :defer t
  :hook (python-mode . ruff-format-on-save-mode)
)

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
;; (use-package flycheck-haskell-ghc-cache-directory
;;   :ensure t
;;   :defer t
;;   :hook ((haskell-mode . flycheck-haskell-setup)))

;; Fish Config
(use-package fish-mode
  :ensure t
  :defer t)


;; Disable Scroll Bar
(scroll-bar-mode -1)

;; Disable Tool Bar
(tool-bar-mode -1)

;; Disable Menu Bar
(menu-bar-mode -1)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq blink-cursor-mode nil)

(setq-default indent-tabs-mode nil
              tab-width 2
              c-basic-offset 2)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)
