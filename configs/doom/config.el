;; (setq default-frame-alist '((undecorated . t)))
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Lucas Tadeu Marculino"
      user-mail-address "ltadeu6@pm.ne")

(setq vterm-shell "fish")
(setq doom-modeline-major-mode-icon t)

(after! orderless
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; (setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 17)
;;             doom-variable-pitch-font (font-spec :family "Fira Code Symbol" :size 15)
;;       doom-big-font (font-spec :family "FiraCode Nerd Font Mono" :size 24))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(after! org
  (require 'org-ref))
;; lambda
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))
(setq global-prettify-symbols-mode t)   ;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 18 :weight 'Light)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font Mono" :size 22)
      )

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-monokai-spectrum)
;; (setq doom-theme 'doom-city-lights)
(setq doom-theme 'doom-dracula)
;; deep
;; moonlight
;; grass
;; (setq doom-theme 'xresources)
(add-to-list 'default-frame-alist '(alpha-background . 90))
;; (after! org
;;   (use-package! org-ref
;; :config (progn
;;           (require 'org-ref-pdf)
;;           (require 'org-ref-bibtex)
;;           (require 'org-ref-url-utils))))
;;  (org-ref-define-citation-link "citeonline" ?o))

;; (setq reftex-default-bibliography '("~/Modelos/org-abntex2-utfpr/references.bib"))
;; (setq org-ref-default-bibliography '("~Modelos/org-abntex2-utfpr/references.bib"))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;; (setq org-directory "~/Documentos/org/"
;;       org-journal-dir "~/Documentos/org/journal/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; (setq org-agenda-include-diary t)
;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; (use-package! org-ref
;;   :after org
;;   :init
;;                                         ; code to run before loading org-ref
;;   ;; (setq org-latex-pdf-process
;;   ;;       '("pdflatex -interaction nonstopmode -output-directory %o %f"
;;   ;;         "bibtex %b"
;;   ;;         "pdflatex -interaction nonstopmode -output-directory %o %f"
;;   ;;         "pdflatex -interaction nonstopmode -output-directory %o %f"))
;;   ;; :config (progn
;;   ;;           (require 'org-ref-pdf)
;;   ;;           ;; (require 'org-ref-bibtex)
;;   ;;           (require 'org-ref-url-utils))
;;   )
(setq system-time-locale "C")
;;cc lsp server whith clangd

(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))


(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main"))

(after! pdf-tools
  (setq pdf-view-midnight-colors '("#f8f8f2" . "#272935")))

(setq +latex-viewers '(pdf-tools))

;; (setq +latex-viewers '(zathura))
;; (add-hook 'pdf-tools-enabled-hook 'pdf-view-midnight-minor-mode)
;; (add-hook 'pdf-tools-enabled-hook 'pdf-view-fit-width-to-window)

;; (after! projectile (setq projectile-project-root-files-bottom-up (remove
;;             ".git" projectile-project-root-files-bottom-up)))

;; (setq +format-on-save-enabled-modes '(not python-mode))

(after! dap-mode
  (setq dap-python-debugger 'debugpy))

(setq doom-themes-treemacs-theme "doom-dracula")

(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("abntex2"
                 "\\documentclass{abntex2}
\\usepackage[alf]{abntex2cite}
\\renewcommand{\\maketitlehookb}{}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; (assoc-delete-all "Open documentation" +doom-dashboard-menu-sections)
;; (assoc-delete-all "Reload last session" +doom-dashboard-menu-sections)
;; (assoc-delete-all "Jump to bookmark" +doom-dashboard-menu-sections)
;; (assoc-delete-all "Open org-agenda" +doom-dashboard-menu-sections)
;; (assoc-delete-all "Open private configuration" +doom-dashboard-menu-sections)
;; (assoc-delete-all "Recently opened files" +doom-dashboard-menu-sections)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)

(setq shell-file-name (executable-find "bash"))


;; (setq fancy-splash-image "~/.doom.d/doom.svg")


(setq httpd-port 1234)

(after! lsp-mode
  (setq lsp-semantic-tokens-enable t))
(setq tree-sitter-hl-use-font-lock-keywords t)
