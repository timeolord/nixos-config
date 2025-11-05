(require 'package)

;; Keybinds
(global-set-key (kbd "M-;") nil)
(global-set-key (kbd "M-;") 'comment-line)
(global-set-key (kbd "C-x C-B") 'switch-to-buffer)

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(defvar backup-dir (expand-file-name "~/emacs/backups/"))
(defvar autosave-dir (expand-file-name "~/emacs/autosaves/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

;; Hide Window Frame and Full Screen and Maximize
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(undecorated . t))

;; Nice macro for updating lists in place.
(defmacro append-to-list (target suffix)
  "Append SUFFIX to TARGET in place."
  `(setq ,target (append ,target ,suffix)))

;; Set up emacs package archives with 'package
(append-to-list package-archives
                '(("gnu" . "https://elpa.gnu.org/packages/")
		  ("melpa" . "http://melpa.org/packages/") ;; Main package archive
                  ("melpa-stable" . "http://stable.melpa.org/packages/") ;; Some packages might only do stable releases?
                  ("org-elpa" . "https://orgmode.org/elpa/"))) ;; Org packages, I don't use org but seems like a harmless default

(package-initialize)

;; Ensure use-package is present. From here on out, all packages are loaded
;; with use-package, a macro for importing and installing packages. Also, refresh the package archive on load so we can pull the latest packages.
;; (unless (package-installed-p 'use-package)
;;   (package-refresh-contents)
;;   (package-install 'use-package))

;; (require 'use-package)
;; (require 'use-package-ensure)
;; (setq
;;  use-package-always-ensure t ;; Makes sure to download new packages if they aren't already downloaded
;;  )
 
(use-package smartparens
  :ensure t
  :defer t
  :hook (prog-mode text-mode markdown-mode)
  :config
  (require 'smartparens-config))

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook (prog-mode text-mode markdown-mode))

;; Slurp environment variables from the shell.
;(use-package exec-path-from-shell
;  :config
;  (exec-path-from-shell-initialize))

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
  :init
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
(use-package company
  :ensure t
  :defer t
  :bind (("C-." . company-complete))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0) ;; I always want completion, give it to me asap
  (company-dabbrev-downcase nil "Don't downcase returned candidates.")
  (company-show-numbers t "Numbers are helpful.")
  (company-tooltip-limit 10 "The more the merrier.")
  :config
  (global-company-mode t) ;; We want completion everywhere
  ;; use numbers 0-9 to select company completion candidates
  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x)
                        `(lambda () (interactive) (company-complete-number ,x))))
          (number-sequence 0 9))))

;; Flycheck is the newer version of flymake and is needed to make lsp-mode not freak out.
(use-package flycheck
  :ensure t
  :defer t
  :hook ((prog-mode)
	 (after-init . global-flycheck-mode))
  ;(add-hook 'prog-mode-hook 'flycheck-mode) ;; always lint my code
  ;(add-hook 'after-init-hook #'global-flycheck-mode)
  )

;; Package for interacting with language servers
(use-package lsp-mode
  :ensure t
  :defer t
  :commands lsp
  :config
  (setq lsp-prefer-flymake nil)) ;; Flymake is outdated

;; Rust Config
(use-package rust-mode
  :ensure t
  :defer t)
(use-package flycheck-rust
  :ensure t
  :defer t
  :hook (flycheck-mode . flycheck-rust-setup)
  ;(with-eval-after-load 'rust-mode
  ;  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))'
  )

;; Python Config
(use-package reformatter
  :ensure t
  :defer t)
(use-package ruff-format
  :ensure t
  :defer t
  :hook (python-mode . ruff-format-on-save-mode)
  :config
  (python-mode . (lambda ()
        (setq indent-tabs-mode nil)
        (setq tab-width 4)
        (setq python-indent-offset 4))))
;(add-hook 'python-mode-hook 'ruff-format-on-save-mode)
;(add-hook 'python-mode-hook
;      )
;; Haskell Config
(use-package haskell-mode
  :ensure t
  :defer t
  :bind ((:map haskell-mode-map ("C-c C-c" . haskell-compile))
	 (:map haskell-cabal-mode-map ("C-c C-c" . haskell-compile)))
  :hook ((haskell-mode . turn-on-haskell-doc-mode)
	 (haskell-mode . turn-on-haskell-indentation))
  :config
  ;(define-key haskell-mode-map (kbd "C-c C-c") 'haskell-compile)
  ;(define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-compile)
  (add-to-list 'completion-ignored-extensions ".hi"))

;; (add-hook 'haskell-mode-hook
;;           (lambda ()
;;             (set (make-local-variable 'company-backends)
;;                  (append '((company-capf company-dabbrev-code))
;;                          company-backends))))
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)

;; hslint on the command line only likes this indentation mode;
;; alternatives commented out below.
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;; Ignore compiled Haskell files in filename completions

;; Disable Scroll Bar
(scroll-bar-mode -1)

;; Disable Tool Bar
(tool-bar-mode -1)

;; Disable Menu Bar
(menu-bar-mode -1)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq blink-cursor-mode nil)

;; Autosave every 10 inputs
;;(setq auto-save-interval 20)

(setq-default indent-tabs-mode nil
  tab-width 2
  c-basic-offset 2)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)



