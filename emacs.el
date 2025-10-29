(require 'package)

;; Hide Window Frame and Full Screen and Maximize
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(undecorated . t))

;; Nice macro for updating lists in place.
(defmacro append-to-list (target suffix)
  "Append SUFFIX to TARGET in place."
  `(setq ,target (append ,target ,suffix)))

;; Set up emacs package archives with 'package
(append-to-list package-archives
                '(("melpa" . "http://melpa.org/packages/") ;; Main package archive
                  ("melpa-stable" . "http://stable.melpa.org/packages/") ;; Some packages might only do stable releases?
                  ("org-elpa" . "https://orgmode.org/elpa/"))) ;; Org packages, I don't use org but seems like a harmless default

(package-initialize)

;; Ensure use-package is present. From here on out, all packages are loaded
;; with use-package, a macro for importing and installing packages. Also, refresh the package archive on load so we can pull the latest packages.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq
 use-package-always-ensure t ;; Makes sure to download new packages if they aren't already downloaded
 use-package-verbose t) ;; Package install logging. Packages break, it's nice to know why.

;; EXWM Setup
;;(use-package exwm
;;  :config
;;  (setq exwm-workspace-number 5)
;;  (require 'exwm)
  ;;(require 'exwm-config)
  ;; Update buffer name by window
  ;; (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

  ;; (require 'exwm-randr)
  ;; (exwm-randr-enable)
  ;; (start-process-shell-command "xrandr" nil "xrandr --output Virtual-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal")

;;  (require 'exwm-systemtray)
;;  (exwm-systemtray-enable)
;;(exwm-enable))

(use-package vterm
  :ensure t)

;; Slurp environment variables from the shell.
;; a.k.a. The Most Asked Question On r/emacs
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package doom-themes
  :init
  (load-theme 'doom-one))

;; (set-frame-parameter nil 'alpha-background 70) ; For current frame
;; (add-to-list 'default-frame-alist '(alpha-background . 70)) ; For all new frames henceforth

(use-package ivy
  :init
  (ivy-mode 1)
  (setq ivy-height 15
        ivy-use-virtual-buffers t
        ivy-use-selectable-prompt t))

(use-package counsel
  :after ivy
  :init
  (counsel-mode 1)
  :bind (:map ivy-minibuffer-map))

;; We need something to manage the various projects we work on
;; and for common functionality like project-wide searching, fuzzy file finding etc.
(use-package projectile
  :init
  (projectile-mode t) ;; Enable this immediately
  :config
  (setq projectile-enable-caching t ;; Much better performance on large projects
        projectile-completion-system 'ivy)) ;; Ideally the minibuffer should aways look similar

;; Counsel and projectile should work together.
(use-package counsel-projectile
  :init
  (counsel-projectile-mode))

;; Company is the best Emacs completion system.
(use-package company
  :bind (("C-." . company-complete))
  :custom
  (company-idle-delay 0) ;; I always want completion, give it to me asap
  (company-dabbrev-downcase nil "Don't downcase returned candidates.")
  (company-show-numbers t "Numbers are helpful.")
  (company-tooltip-limit 10 "The more the merrier.")
  :config
  (global-company-mode) ;; We want completion everywhere

  ;; use numbers 0-9 to select company completion candidates
  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x)
                        `(lambda () (interactive) (company-complete-number ,x))))
          (number-sequence 0 9))))

;; Flycheck is the newer version of flymake and is needed to make lsp-mode not freak out.
(use-package flycheck
  :config
  (add-hook 'prog-mode-hook 'flycheck-mode) ;; always lint my code
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; Package for interacting with language servers
(use-package lsp-mode
  :commands lsp
  :config
  (setq lsp-prefer-flymake nil)) ;; Flymake is outdated

;; Rust Config
(use-package rust-mode)
(use-package flycheck-rust)
(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))'

;; Python Config
;(use-package elpy
;  :ensure t
;  :init
;  (elpy-enable))
(use-package reformatter)
(use-package ruff-format)
(add-hook 'python-mode-hook 'ruff-format-on-save-mode)
(add-hook 'python-mode-hook
      (lambda ()
        (setq indent-tabs-mode nil)
        (setq tab-width 4)
        (setq python-indent-offset 4)))



;; Disable Scroll Bar
(scroll-bar-mode -1)

;; Disable Tool Bar
(tool-bar-mode -1)

;; Disable Menu Bar
(menu-bar-mode -1)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq blink-cursor-mode nil)

;; Autosave every 10 inputs
(setq auto-save-interval 20)

(setq-default indent-tabs-mode nil
  tab-width 2
  c-basic-offset 2)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)



