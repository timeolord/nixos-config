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
         ;; (prog-mode . flyspell-prog-mode)
         (text-mode . flyspell-mode)
         (text-mode . auto-fill-mode))
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
  (set-frame-font "-TWR-UDEV Gothic NF-regular-normal-normal-*-16-*-*-*-d-0-iso10646-1" nil t)

  ;; Org-mode Settings
  (setq org-support-shift-select t)
  (setq fill-column 160)
  (setq org-pretty-entities t)
  (setq org-use-sub-superscripts '{})
  (setq org-export-with-sub-superscripts '{})
  (setq org-startup-with-inline-images t)
  (setq org-startup-with-latex-preview t)
  (setq org-startup-folded 'show2levels)
  (setq org-startup-indented t)
  :custom
  (completion-cycle-threshold nil)
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  ;; (text-mode-ispell-word-completion nil)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package markdown-mode
  :ensure t)

(use-package pdf-tools
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))
                                        ;(add-hook 'latex-mode-hook 'tex-open-pdf-and-watch)
  )

(use-package direnv
  :ensure t
  :config
  (direnv-mode))

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
  :hook (python-mode python-shell-mode))

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
         (markdown-mode . rainbow-delimiters-mode)
         (shell-mode . rainbow-delimiters-mode)))

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

(use-package vertico
  :ensure t
  :defer t
  :init
  (savehist-mode)
  (vertico-mode))

(use-package orderless
  :ensure t
  :defer t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :defer t
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package vterm
  :ensure t
  :config
  (setq vterm-shell (format "/etc/profiles/per-user/%s/bin/fish" (getenv "USER")))
  )

;; Example configuration for Consult
(use-package consult
  :defer t
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)
;; (use-package ivy
;;   :ensure t
;;   :config
;;   (ivy-mode 1)
;;   (setq ivy-height 15
;;         ivy-use-virtual-buffers t
;;         ivy-use-selectable-prompt t))

;; (use-package counsel
;;   :ensure t
;;   :after ivy
;;   :config
;;   (counsel-mode 1)
;;   :bind (:map ivy-minibuffer-map))

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
  (corfu-auto-prefix 1)
  (corfu-auto-delay 0.1)
  ;; (corfu-min-width 80)
  ;; (corfu-max-width corfu-min-width)       ; Always have the same width
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
