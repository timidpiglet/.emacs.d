;; * Core
;; :PROPERTIES:
;; :ID:       d68434bf-be6a-471f-ab65-e151f4f1c111
;; :END:

;; ** Package Management
;; :PROPERTIES:
;; :ID: 0397db22-91be-4311-beef-aeda4cd3a7f3
;; :END:

;; The purpose of this headline is to set up the package manager and install all of
;; my packages so the rest of the file can assume the packages are already
;; installed.

;; *** preliminary requirements
;; :PROPERTIES:
;; :ID:       315cd01c-7339-460d-85bd-fc3f09d89dfc
;; :END:

(require 'seq)
(require 'cl-lib)

;; *** directory where packages will be installed
;; :PROPERTIES:
;; :ID:       5e5d2a12-1270-402d-a8c2-d24207755335
;; :END:

(defvar VOID-PACKAGES-DIR (concat user-emacs-directory ".local/packages/"))

;; *** straight.el
;; :PROPERTIES:
;; :ID: a086d616-b90d-4826-b61f-93eb0b7efc8e
;; :END:

;; [[straight][straight.el]] is a package manager that strives to make emacs configurations
;; completely reproducable.

;; **** variables
;; :PROPERTIES:
;; :ID:       9dff9894-667c-4e74-9624-8aee533f8f70
;; :END:

(setq straight-base-dir VOID-PACKAGES-DIR)
(setq straight-use-package-version 'straight)
(setq straight-use-package-by-default t)
(setq straight-enable-package-integration t)
(setq straight-disable-autoloads nil)
(setq straight-cache-autoloads t)
(setq straight-check-for-modifications nil)
(setq straight-enable-package-integration nil)
(setq straight-recipes-emacsmirror-use-mirror t)

;; **** bootstrap code
;; :PROPERTIES:
;; :ID: 7816be80-4db8-4219-b7d1-9a6b1ea96035
;; :END:

;; This code initializes straight if it's not already installed.

(defun straight:initialize ()
  "Initialize `straight.el'."
  (defvar bootstrap-version)
  (let* ((url "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el")
         (bootstrap-file (concat VOID-PACKAGES-DIR "straight/repos/straight.el/bootstrap.el"))
         (bootstrap-version 5))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously url 'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage)))

;; **** utility functions
;; :PROPERTIES:
;; :ID:       3ed810d4-2f5a-4ba8-95c4-dfb5ca0a2165
;; :END:

;; Straight is very minimal. It lacks utility functions.

;; ***** package homepage
;; :PROPERTIES:
;; :ID:       0edcf34d-a368-4e86-9365-1402f23befbb
;; :END:

;; This function gets me the homepage of a package.

(defun straight:get-package-homepage (package)
  "Return the homepage for recipe.
Assumes vc is git which is fine because straight only uses git right now."
  (let* ((recipe (straight-recipes-retrieve package straight-recipe-repositories))
         (repo (plist-get (cdr recipe) :repo))
         (host (plist-get (cdr recipe) :host)))
    (straight-vc-git--encode-url repo host)))

(defun straight/goto-homepage ()
  (interactive)
  (browse-url (straight:get-package-homepage (symbol-at-point))))

;; **** straight-install-fn
;; :PROPERTIES:
;; :ID:       e63813c4-f321-4544-94f3-96b46cd38cf4
;; :END:

;; =straight= actually has two sources of truth: the recipes you specify in your init
;; file and the lockfile. The lockfile is a file that contains an alist of packages
;; and their commit (or revision). To actually reproduce the state of your emacs
;; configuration after you install your packages, you call [[helpfn:straight-thaw-versions][straight-thaw-versions]].
;; I would prefer having only one souce of truth--the recipes; and only one place
;; where that controls the setup of my files--my init file.

(defun straight:install-fn (recipe)
  "Function that."
  (straight-use-package recipe)
  ;; After installing, set the package to the correct commit.
  ;; (when (straight--repository-is-available-p recipe)
  ;;   (when-let (commit (plist-get :commit recipe))
  ;;     (unless (straight-vc-commit-present-p recipe commit)
  ;;       (straight-vc-fetch-from-remote recipe))
  ;;     (straight-vc-check-out-commit recipe commit)))
  )

;; *** package installation
;; :PROPERTIES:
;; :ID:       5ca4b13a-14ab-4e7a-ab27-aab08b4f4994
;; :END:

;; This headline is about actually installing all of the packages I use. I do this
;; by searching through my org file for heading properties that correspond to emacs
;; packages. Then, I convert their properties.

;; **** get package list based on my org file
;; :PROPERTIES:
;; :ID:       fc52bcb2-034e-48cf-b9eb-7ea7aace66a3
;; :END:

;; I wrote this file such that the configure of each package has a headline that
;; contains the recipe of that package as org properties. This way I don't have to
;; maintain a separate file of recipes and each recipe is closely tied to the
;; configuration of each package. Additionally, this signals to the reader that
;; this is indeed an emacs package. And finally, this allows me to install all my
;; packages all at once at the start of my config.

;; ***** property regexp
;; :PROPERTIES:
;; :ID:       a23d43d4-3e20-4a55-85e6-4a036ca6a33e
;; :END:

;; To avoid loading org mode, I snatched the property drawer regexp from its source
;; code and use it to get the package recipes in my org file. I modified it so that
;; the keys between the property block delimiters were in their own group. This
;; makes it easier to access them.

(setq void-property-drawer-regexp
      (rx (seq bol
               ";; :PROPERTIES:"
               "\n"
               (group (*? bol ";; :" (one-or-more (not (syntax whitespace)))
                          (1+ "\s")
                          (one-or-more nonl)
                          "\n"))
               ";; :END:")))

;; ***** convert a string to a property list
;; :PROPERTIES:
;; :ID:       fa5a9b8e-fd68-4f8e-9a7a-15a0d28f012d
;; :END:

;; When I read the property lists from my org file, they'll be strings. This
;; function will convert them to a plist which is what =straight-use-package= needs
;; as an argument.

(defun void-property-string-to-plist (string)
  "Convert a property list string into a plist."
  (seq-map-indexed (lambda (elt i)
                     (if (cl-evenp i)
                         (intern (downcase elt))
                       (car (read-from-string elt))))
                   (split-string string (rx (or ";; " "\n" (seq eow ":" (1+ white)))) t)))

;; ***** convert property list to proper straight format
;; :PROPERTIES:
;; :ID:       ef287f62-ac81-428d-9fdd-f06665048dc5
;; :END:

(defun void-property-string-to-recipe (string)
  (let ((plist (void-property-string-to-plist string)))
    (cons (intern (plist-get plist :package))
          plist)))

;; ***** get recipes
;; :PROPERTIES:
;; :ID:       8a7408f7-9a04-4b11-8313-ee0cf854452d
;; :END:

;; A straight recipe is represented as a plist in lisp. And in this config I signal
;; a heading corresponds to a package by putting the keys and values of the package
;; recipe as properties of the headline. That way, my main org file can be
;; completely reproducible as one file.

(defun void-get-package-recipes ()
  "Return a list of recipes from org file."
  (let ((recipes nil)
        (elfile (concat user-emacs-directory "init.el"))
        (regexp void-property-drawer-regexp))
    (with-temp-buffer
      (insert-file-contents-literally elfile)
      (goto-char (point-min))
      (while (re-search-forward regexp nil t)
        (let ((match (match-string-no-properties 1)))
          (when (and match (string-match-p "PACKAGE" match))
            (push (void-property-string-to-recipe match) recipes)))))
    recipes))

;; **** install packages
;; :PROPERTIES:
;; :ID:       6a346ca2-fa00-4339-b343-e594fe6125e6
;; :END:

;; This is where I actually install all of my packages in one go. To save time
;; installing packages, I try to access.

(defvar void-package-recipes (void-get-package-recipes)
  "Package recipes.")

(defvar void-package-load-paths
  (let ((old-load-path load-path)
        (load-path load-path))
    (straight:initialize)
    (mapc #'straight:install-fn void-package-recipes)
    (mapc #'require '(dash s ht anaphora))
    ;; (mapc #'require void-essential-packages)
    (cl-set-difference load-path old-load-path))
  "Package load-paths.")

(setq load-path (append void-package-load-paths load-path))

;; *** essential libraries
;; :PROPERTIES:
;; :ID:       18602d49-dcc3-47c3-8579-62f7a7b7a83a
;; :END:

;; **** shut-up
;; :PROPERTIES:
;; :ID:       71681f9f-2760-4cee-95a0-4aeb71191a42
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "cask/shut-up"
;; :PACKAGE:  "shut-up"
;; :LOCAL-REPO: "shut-up"
;; :COMMIT:   "081d6b01e3ba0e60326558e545c4019219e046ce"
;; :END:

(require 'shut-up)
(defalias 'shut-up! 'shut-up)

;; **** general
;; :PROPERTIES:
;; :ID: 706f35fc-f840-4a51-998f-abcd54c5d314
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "noctuid/general.el"
;; :PACKAGE:  "general"
;; :LOCAL-REPO: "general.el"
;; :COMMIT:   "a0b17d207badf462311b2eef7c065b884462cb7c"
;; :END:

;; There are numerous keybinding functions in Emacs; and they all look a little
;; different: there's [[helpfn:global-set-key][global-set-key]], [[helpfn:local-set-key][local-set-key]], [[helpfn:define-key][define-key]] and the list goes
;; on. And with [[https://github.com/emacs-evil/evil.git][evil]] which [[id:73366b3e-7438-4abf-a661-ed1553b1b8df][I use]] , there's also [[helpfn:evil-global-set-key][evil-global-set-key]] and
;; [[helpfn:evil-define-key][evil-define-key]]. It would be nice to have one keybinding function that can
;; handle all bindings. [[https://github.com/noctuid/general.el.git][general]] provides such a function ([[helpfn:general-define-key][general-define-key]]).

;; ***** general
;; :PROPERTIES:
;; :ID: f1ad5258-17cb-4424-a161-b856ee6dc5ab
;; :END:

(require 'general)

;; ***** unbind keys
;; :PROPERTIES:
;; :ID:       ffff6e7c-35c7-45e2-b2ad-6bca21bf8c1d
;; :END:

(general-auto-unbind-keys)

;; ***** prefix bindings
;; :PROPERTIES:
;; :ID: b0b5b51c-155e-46fc-a80a-0d45a32440ba
;; :END:

;; A popular strategy to mitigate the mental load of remembering many keybindings
;; is to bind them in a tree-like fashion (see [[https://github.com/syl20bnr/spacemacs][spacemacs]]).

;; ***** leader Keys
;; :PROPERTIES:
;; :ID: 143211d6-b868-4ffb-a5d0-25a77dee401f
;; :END:

(defvar void-leader-key "SPC"
  "The evil leader prefix key.")

(defvar void-leader-alt-key "M-SPC"
  "The leader prefix key used for Insert and Emacs states.")

;; ***** localleader keys
;; :PROPERTIES:
;; :ID: 45941bcb-209f-4aa3-829a-dee4e3ef2464
;; :END:

(defvar void-localleader-key "SPC m"
  "The localleader prefix key for major-mode specific commands.")

(defvar void-localleader-alt-key "C-SPC m"
  "The localleader prefix key for major-mode specific commands.")

(defvar void-localleader-short-key ","
  "A shorter alternative `void-localleader-key'.")

(defvar void-localleader-short-alt-key "M-,"
  "A short non-normal  `void-localleader-key'.")

;; ***** definers
;; :PROPERTIES:
;; :ID: 6444d218-1627-48bd-9b5c-7bfffb17d912
;; :END:

;; As I've mentioned =general= uses the function =general-define-key= as a generic
;; do-all key binder. Sometimes though we have keys that we want to bind with
;; specific arguments to =general-define-key= pretty often. A typical example of
;; this is binding =leader= or =localleader= keys like [[https://github.com/syl20bnr/spacemacs][spacemacs]].

(general-create-definer define-leader-key!
  :prefix void-leader-key
  :non-normal-prefix void-leader-alt-key
  :keymaps 'override
  :states '(normal motion insert emacs))

;; ***** localleader
;; :PROPERTIES:
;; :ID:       e4770eae-adf5-4216-9016-5ec4bc465e03
;; :END:

;; There's pros and cons to the =SPC m= binding. The main pro is that it's
;; consistent with =SPC=. With the leader and the localleader, this means that you
;; can reach any binding from just =SPC=. This means that you can discover all
;; bindings from just one root binding. This is a nice property to have. On the
;; other hand, bindings can get a bit long. That one extra character can really
;; make a difference. That's why.

(defmacro define-localleader-key! (&rest args)
  (declare (indent defun))
  (let ((shared-args '(:keymaps 'override :states '(normal motion insert emacs))))
    `(progn (general-def
              ,@args
              ,@shared-args
              :prefix void-localleader-key
              :non-normal-prefix void-localleader-alt-key)
            (general-def
              ,@args
              ,@shared-args
              :prefix void-localleader-short-key
              :non-normal-prefix void-localleader-short-alt-key))))

;; **** dash
;; :PROPERTIES:
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("dash.el" "dash.texi" "dash-pkg.el")
;; :HOST:     github
;; :REPO:     "magnars/dash.el"
;; :PACKAGE:  "dash"
;; :LOCAL-REPO: "dash.el"
;; :COMMIT:   "0f238a9a466879ee96e5db0482019453718f342d"
;; :END:

;; Dash is an excellent functional list manipulation library. If I did not use it
;; as a dependency, I'd end up rewriting many of its functions.

;; :PROPERTIES:
;; :ID:       7d37ae8b-d319-4077-ae7a-aa463d8ec68d
;; :END:

;; **** load
;; :PROPERTIES:
;; :ID:       4be107b5-b756-4372-9f74-655bda941b75
;; :END:

(require 'dash)
(require 'dash-functional)

;; ***** set font lock
;; :PROPERTIES:
;; :ID:       ed2dd8e0-1084-4ac9-8f4c-41a7002261ef
;; :END:

'(void-add-hook 'emacs-lisp-mode-hook #'dash-enable-font-lock nil nil t)

;; **** s
;; :PROPERTIES:
;; :ID: 4b82deb0-bbe1-452c-8b60-ef734efb86d8
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("s.el" "s-pkg.el")
;; :HOST:     github
;; :REPO:     "magnars/s.el"
;; :PACKAGE:  "s"
;; :LOCAL-REPO: "s.el"
;; :COMMIT:   "43ba8b563bee3426cead0e6d4ddc09398e1a349d"
;; :END:

(require 's)

;; **** ht
;; :PROPERTIES:
;; :ID:       dc6ceb3b-8946-4649-8164-38bc5e4d2ab5
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("ht.el" "ht-pkg.el")
;; :HOST:     github
;; :REPO:     "Wilfred/ht.el"
;; :PACKAGE:  "ht"
;; :LOCAL-REPO: "ht.el"
;; :COMMIT:   "fff8c43f0e03d5b98deb9f988522b839ce2ca253"
;; :END:

;; =ht= is a library for working with hash tables.

(require 'ht)

;; **** anaphora
;; :PROPERTIES:
;; :ID:       1c47bd8a-15f1-4b1c-9574-23547d27d968
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "rolandwalker/anaphora"
;; :PACKAGE:  "anaphora"
;; :LOCAL-REPO: "anaphora"
;; :END:

(require 'anaphora)

;; ** Library
;; :PROPERTIES:
;; :ID: 3e9e5e7a-9f9b-4e92-b569-b5e8ba93820f
;; :END:

;; This headline contains all the the helper functions and macros I defined for
;; customizing emacs.

;; *** message logging
;; :PROPERTIES:
;; :ID:       4d4f4b4a-4fc3-47fe-bed7-acc8e8103933
;; :END:

;; Its not uncommon for the *Messages* buffer to become full of messages.

;; **** debug-p
;; :PROPERTIES:
;; :ID: b9e28d90-cdbe-412f-8ed8-1b8b97c1ab07
;; :END:

;; [[helpvar:void-debug-p][void-debug]] is snatched from [[https://github.com/hlissner/doom-emacs][Doom's]] [[https://github.com/hlissner/doom-emacs/blob/develop/core/core.el][doom-debug-mode]]. The point of this variable
;; is to serve as an indicator of whether the current Void instance is run for
;; debugging. When Void is set up for debugging it prints out many messages about
;; what its doing via [[hfn:void-log][void-log]].

(defvar void-debug-p (or (getenv "DEBUG") init-file-debug)
  "When non-nil print debug messages.
The --debug-init flag and setting the DEBUG envar will enable this at startup.")

;; **** logging
;; :PROPERTIES:
;; :ID: 84ded5f7-382e-4f59-af9e-ccb157ef5c42
;; :END:

;; The purpose of ~void-log~ is to distinguish regular messages from messages that
;; pertain specifically to Void, and to help debug Void functionality. When Void is
;; =void-debug= is non-nil, void-specific messages are logged in the =*messages*=
;; buffer.

(defun void-log (format-string &rest args)
  "Log to *Messages* if `void-debug-p' is on.
Does not interrupt the minibuffer if it is in use, but still log to *Messages*.
Accept the same arguments as `message'."
  (when void-debug-p
    (let ((inhibit-message (active-minibuffer-window)))
      (when void-debug-p
        (apply #'message (concat (propertize "VOID " 'face 'font-lock-comment-face)
                                 format-string)
               args)))))

;; *** macro writing tools
;; :PROPERTIES:
;; :ID:       ea5d3295-d8f9-4f3a-a1f6-25811696aa29
;; :END:

;; **** get keywords arguments in macro
;; :PROPERTIES:
;; :ID:       dc7a63e6-041b-4855-b206-6d72ef732de1
;; :END:

;; Following past examples (such as), I initially opted for allowing keyword
;; arguments in the "function args" part of defun-like macros. This is fine when
;; there's only one keyword argument, but any more and it starts to get crowded. It
;; doesn't help that emacs functions tend towards longer names due to a lack of
;; namespaces. Therefore, I support keyword args in the function body.

(defun void--keyword-macro-args (body)
  "Return list of (docstring KEYWORD-ARGS BODY)."
  (list (when (stringp (car body)) (pop body))
        (--unfold (when (keywordp (car it))
                    (cons (cons (pop body) (pop body))
                          body))
                  body)
        body))

;; **** format macro
;; :PROPERTIES:
;; :ID:       c2f43f84-e400-45ed-9e96-7b8d38133810
;; :END:

;; The purpose of this macro is to fascillitate the creating of cut paste keywords
;; so often used in macros. Let me explain. Often you want a macro to be a
;; "front-end" so-to-speak for defining functions and variables that usually follow
;; a naming scheme. In the macro body we end up with many ~(intern (format
;; "foo-%s-baz" var))~ forms. This macro allows you to write this as ~foo-<var>-baz~
;; instead.

;; ***** convert a keyword into its equivalent
;; :PROPERTIES:
;; :ID:       aa083f01-a4de-4ce8-bbcc-7f493adad227
;; :END:

(defun void--anaphoric-format (symbol)
  "Return the form that will replace."
  (if-let ((regexp VOID-ANAPHORIC-SYMBOL-REGEXP)
           (string (and (symbolp symbol) (symbol-name symbol)))
           (symbols (--map (nth 1 it) (s-match-strings-all regexp string)))
           (format-string (s-replace-regexp regexp "%s" string)))
      `(,'\, (intern (format ,format-string ,@(-map #'intern symbols))))
    symbol))

;; ***** defmacro!
;; :PROPERTIES:
;; :ID:       7cd61cb8-22be-460d-b4f4-da6c82435958
;; :END:

(defmacro defmacro! (name args &rest body)
  "Like `defmacro' but allows for anaphoric formatting."
  (-let [(docstring _ body) (void--keyword-macro-args body)]
    `(defmacro ,name ,args
       ,docstring
       ,@(-tree-map #'void--anaphoric-format body))))

;; **** symbols
;; :PROPERTIES:
;; :ID: 2cdf8ab1-4e59-4128-a8a4-e5519ca0f4bf
;; :END:

;; Conversion between symbols, keywords, and strings are prevalent in
;; macro-writing.

;; ***** symbol intern
;; :PROPERTIES:
;; :ID: 659e8389-84c5-4ac4-a9ba-7dd40599191d
;; :END:

(defun void-symbol-intern (&rest args)
  "Return ARGS as a symbol."
  (declare (pure t) (side-effect-free t))
  (intern (apply #'void-to-string args)))

;; ***** keyword intern
;; :PROPERTIES:
;; :ID: f2668044-13b2-46e7-bf84-fcf998591e37
;; :END:

(defun void-keyword-intern (&rest args)
  "Return ARGS as a keyword."
  (declare (pure t) (side-effect-free t))
  (apply #'void-symbol-intern ":" args))

;; ***** keyword name
;; :PROPERTIES:
;; :ID: fb867938-d62b-42fc-bf07-092f10b64f22
;; :END:

(defun void-keyword-name (keyword)
  "Return the name of the KEYWORD without the prepended `:'."
  (declare (pure t) (side-effect-free t))
  (substring-no-properties (void-to-string keyword) 1))

;; ***** convert to string
;; :PROPERTIES:
;; :ID: 4ef52875-4ce6-4940-8b7e-13c96bedcb3d
;; :END:

(defun void-to-string (&rest args)
  "Return ARGS as a string."
  (declare (pure t) (side-effect-free t))
  (with-output-to-string
    (dolist (a args) (princ a))))

;; **** wrap-form
;; :PROPERTIES:
;; :ID:       48e48c0f-7bb3-45c9-b4af-2da0ce84b64e
;; :END:

;; When writing macros in lisp it is not uncommon to need to write a macro that can
;; nest a form within some number of other forms (for an example, see [[id][after!]]). This
;; macro makes this problem much easier.

(defun void-wrap-form (wrappers form)
  "Wrap FORM with each wrapper in WRAPPERS.
WRAPPERS are a list of forms to wrap around FORM."
  (declare (pure t) (side-effect-free t))
  (setq wrappers (reverse wrappers))
  (if (consp wrappers)
      (void-wrap-form (cdr wrappers)
                      (append (car wrappers)
                              (list form)))
    form))

;; **** anaphora
;; :PROPERTIES:
;; :ID:       9938b1e1-6c6e-4a45-a85e-1a7f2d0bf6df
;; :END:

;; Anaphora refers to the ability to refer to. I have decided it is best to use
;; =<>= to denote the symbol referred to by anaphoric macros because it is easy to
;; type (assuming parentheses completion), because such a symbol uncommon in lisp.
;; A key advantage to this is that there is a consistent "syntax" for anaphoric
;; variables as opposed to using =it=. A consequence of this is that you have more
;; flexibility to name variables. Additionally, I like that it looks like a slot or
;; placeholder.

;; https://en.wikipedia.org/wiki/Anaphoric_macro

;; ***** anaphoric symbol regexp
;; :PROPERTIES:
;; :ID:       40c97bd5-dab1-44df-86f7-90274d5a8ea0
;; :END:

(defconst VOID-ANAPHORIC-SYMBOL-REGEXP
  (eval-when-compile (rx "<" (group (1+ (not (any white ">" "<")))) ">"))
  "Regular expression that matches an anaphoric symbol.")

;; ***** anaphoric symbol
;; :PROPERTIES:
;; :ID:       db8169ba-1630-42fe-9ab7-e29c110a18c3
;; :END:

(defun void-anaphoric-symbol-p (obj)
  "Return non-nil if OBJ is an anaphoric symbol."
  (and (symbolp obj)
       (string-match-p VOID-ANAPHORIC-SYMBOL-REGEXP (symbol-name obj))))

;; ***** true anaphora name
;; :PROPERTIES:
;; :ID:       2833cd75-9c85-4c0e-9523-4489d387150a
;; :END:

(defun void-anaphoric-true-symbol (symbol)
  "Return the symbol that corresponds to the anaphoric symbol."
  (save-match-data
    (string-match VOID-ANAPHORIC-SYMBOL-REGEXP (symbol-name symbol))
    (intern (match-string 1 (symbol-name symbol)))))

;; ***** body symbols
;; :PROPERTIES:
;; :ID:       2bae458e-404a-48e7-b57e-ce7f543f6e6d
;; :END:

(defun void-anaphoric-symbols (body)
  "Return all the anaphoric symbols in body."
  (->> (-flatten body)
       (-filter #'void-anaphoric-symbol-p)
       (-uniq)))

;; ***** all anaphoric symbols in obj
;; :PROPERTIES:
;; :ID:       e0c0eb8c-52b3-4411-ab0b-06255490dacf
;; :END:

(defun void-anaphoric-symbols-in-obj (obj)
  "Return a list of anaphoric symbols in OBJ."
  (s-match-strings-all VOID-ANAPHORIC-SYMBOL-REGEXP (void-to-string obj)))

;; **** with-symbols!
;; :PROPERTIES:
;; :ID:       0ba70f30-f1a8-4a5d-acf9-07db9931bd54
;; :END:

(defmacro with-symbols! (names &rest body)
  "Bind each variable in NAMES to a unique symbol and evaluate BODY."
  (declare (indent defun))
  `(let ,(-map (lambda (symbol) `(,symbol (make-symbol ,(symbol-name symbol)))) names)
     ,@body))

;; **** once-only!
;; :PROPERTIES:
;; :ID:       23c10e2a-6ccc-42dc-a898-29ab39a1f79c
;; :END:

(defmacro once-only! (bindings &rest body)
  "Rebind symbols according to BINDINGS and evaluate BODY.

Each of BINDINGS must be either a symbol naming the variable to be
rebound or of the form:

  (SYMBOL INITFORM)

where INITFORM is guaranteed to be evaluated only once.

Bare symbols in BINDINGS are equivalent to:

  (SYMBOL SYMBOL)"
  (declare (indent defun))
  (let* ((bind-fn (lambda (bind)
                    (if (consp bind)
                        (cons (car bind) (cadr bind))
                      (cons bind bind))))
         (names-and-forms (-map bind-fn bindings))
         (names (-map #'car names-and-forms))
         (forms (-map #'cdr names-and-forms))
         (symbols (--map (make-symbol (symbol-name it)) names)))
    `(with-symbols! ,symbols
       (list 'let
             (-zip-with #'list (list ,@symbols) (list ,@forms))
             ,(cl-list* 'let
                        (-zip-with #'list names symbols)
                        body)))))

;; *** hooks
;; :PROPERTIES:
;; :ID:       a9fb6a01-ded5-405c-83ba-c401dbc06400
;; :END:

;; One of the most common ways to customize Emacs is via [[info:elisp#Hooks][hooks]]. Hooks are variables
;; containing functions (also referred to as hooks). The functions in hooks are run
;; after certain events, such as starting and quitting emacs. Their purpose is to
;; fascillitate customization of what happens before or after particular events.

;; In this headline, I strive to establish a common naming convention for
;; Void-defined hooks, so I can clearly distinguish them from pre-defined hooks.

;; **** hook-p
;; :PROPERTIES:
;; :ID:       1995a309-e1d3-40e5-b6b1-fbcd81dda0bb
;; :END:

(defun void-hook-p (fn)
  "Return non-nil if FN is a Void hook."
  (s-matches-p "\\`[^[:space:]]+&[^[:space:]]+\\'"
               (symbol-name fn)))

;; **** hook variable
;; :PROPERTIES:
;; :ID:       77f45347-3688-438d-8674-39e6d476a2d1
;; :END:

;; A useful consequence of the hook naming convention is I can determine precisely
;; which hook variable a function resides in based on looking at the name
;; (=emacs-startup-hook&do-something= would be a hook in =emacs-starup-hook= for
;; example). This proves to be useful for [[id:8506fa78-c781-4ca8-bd58-169cce23a504][expire advice]].

(defun void-hook-var (hook-fn)
  "Return the hook variable HOOK-FN is in.
HOOK-FN is a function named with Void naming conventions."
  (->> (symbol-name hook-fn)
       (s-match (rx (group (1+ anything)) "&"))
       (nth 1)
       (intern)))

;; **** hook name
;; :PROPERTIES:
;; :ID:       6b14ea72-b8ef-493d-82e2-962f889736a2
;; :END:

;; This function is to help produce names that abide by hook naming conventions.

(defun void-hook-name (var hook)
  "Return a hook name that meets Void naming conventions."
  (funcall (-partial #'void-symbol-intern var '&)
           (or (->> (symbol-name hook)
                    (s-match "void--\\([^[:space:]]+\\)-hook")
                    (nth 1))
               hook)))

;; **** hook action
;; :PROPERTIES:
;; :ID:       fa705f26-31f0-43c3-80a6-6741e74ab0ea
;; :END:

(defun void-hook-action (hook)
  "Return the action for hook."
  (->> (symbol-name hook)
       (s-match (rx "&" (group (1+ (not (any "&" white)))) eos))
       (nth 1)))

;; **** adding hooks
;; :PROPERTIES:
;; :ID:       882bc5d2-a0e2-4ea7-b9d2-ab64b3407f82
;; :END:

;; ***** internal helper
;; :PROPERTIES:
;; :ID:       aaf7ab9a-0648-4f1b-b30e-85ce0acac602
;; :END:

;; Add a hook that follow naming conventions. When adding a hook, if it is a void
;; function, change it to a hook.

(defun void--add-hook (var hook &optional depth local expire-fn)
  (let* ((new-hook (void-hook-name var hook))
         (hook-log (void-symbol-intern new-hook '@ 'log-on-debug)))
    (defalias new-hook hook)
    (add-hook var new-hook depth local)
    (fset hook-log
          `(lambda (&rest _)
             (alet ,(void-hook-action new-hook)
               (void-log "& %s -> %s" ',var it))))
    (advice-add new-hook :before hook-log)
    (when expire-fn
      (->> (void-expire-advice hook expire-fn t)
           (advice-add new-hook :around)))))

;; ***** adding hooks
;; :PROPERTIES:
;; :ID:       10dcca8f-7dd0-45da-a413-43608c098b10
;; :END:

(defun void-add-hook (vars hooks &optional depth local expire-fn)
  "Alias HOOK to match Void naming conventions and add it to VAR."
  (dolist (var (-list vars))
    (dolist (hook (-list hooks))
      (void--add-hook var hook depth local expire-fn))))

;; **** removing hooks
;; :PROPERTIES:
;; :ID:       99708d72-a8d4-42ba-b6ae-ba692fbafec8
;; :END:

(defun void-remove-hook (hook)
  "Remove a void hook."
  (remove-hook (void-hook-var hook) hook))

;; **** defhook!
;; :PROPERTIES:
;; :ID:       4daf2baf-ea7f-41f5-9f86-63168089149a
;; :END:

;; =defhook= provides a declarative way declare hook functions. It uses a familiar
;; defun-like syntax.

(defmacro defhook! (name args &rest body)
  "Define a hook function and attatch it to HOOK and HOOKS.
DEPTH and LOCAL are the same as in `add-hook'. BODY is the body of the hook
function.

\(NAME (HOOK &REST HOOKS &OPTIONAL DEPTH LOCAL) &rest BODY)"
  (declare (doc-string 3))
  (-let* ((hooks (-take-while (-not #'keywordp) args))
          (local (plist-get hooks :local))
          (depth (or (plist-get hooks :append) (plist-get hooks :depth)))
          ((docstring _ body) (void--keyword-macro-args body))
          (hook-name (void-symbol-intern 'void-- name '-hook)))
    `(progn
       ,@(-map (lambda (hook)
                 `(aprog1 (defun ,hook-name (&rest _) ,docstring ,@body)
                    (void-add-hook ',hook it ,depth ,local)))
               hooks))))

;; *** advice
;; :PROPERTIES:
;; :ID:       19b9021d-f310-485b-9258-4df19423c082
;; :END:

;; [[info:elisp#Advising Functions][Advising]] is one of the most powerful ways to customize emacs's behavior. In this
;; headline I provide a macro to concisely define functions that are specifically
;; intended to advise other functions and to ensure that these functions are named
;; properly. All user-defined advising functions should have the format
;; =TARGET@ACTION=, where =TARGET= is the function being advised and =ACTION= is the
;; action the advise is performing. This naming scheme is inspired and taken from
;; the one introduced by [[helpfn:define-advice][define-advice]].

;; **** advice-p
;; :PROPERTIES:
;; :ID:       0a84d983-39ad-48d1-af9d-b43589d63bcf
;; :END:

;; This function should be used to distinguish advices I add to functions over
;; advices that have been added by Emacs or other packages.

(defun void-advice-p (fn)
  "Return non-nil if FN is a void advice."
  (s-matches-p (rx (1+ (not white)) "@" (1+ (not white)))
               (symbol-name fn)))

;; **** advised function
;; :PROPERTIES:
;; :ID:       f893fbe8-592b-409e-8de7-6060e936456f
;; :END:

;; It's easy to find which functions are advising a given function using
;; [[helpfn:advice-mapc][advice-mapc]]. However, it's not as easy to go the other way around--to determine
;; what which function a given advice is advising. Another complicaiton is that
;; it's possible for a given advice to advise multiple functions. With the naming
;; system I provide, doing this is trivial.

(defun void-advised-fn (fn)
  "Return the function advised by FN.
ADVICE is an advice of the form \"advisee@advisor\", where this function returns
\"advisee\"."
  (->> (symbol-name advice)
       (s-match (rx (group (1+ (not white))) "@" (1+ (not white))))
       (nth 1)
       (intern)))

;; **** advice name
;; :PROPERTIES:
;; :ID:       03416f82-ced7-42a0-843b-6975903f0b38
;; :END:

(defun void-advice-name (fn advice)
  "Return advice name that meets Void naming conventions.
Advice name is of the form FN@ADVICE."
  (funcall (-partial #'void-symbol-intern fn '@)
           (or (->> (symbol-name advice)
                    (s-match "void--\\([^[:space:]]+\\)-advice")
                    (nth 1))
               advice)))

;; **** adding advice
;; :PROPERTIES:
;; :ID:       3ab8947c-15f0-4fb7-bd75-f0baabc20ec1
;; :END:

;; Since adding an advice to multiple functions is done frequently.

;; ***** helper
;; :PROPERTIES:
;; :ID:       4750f4dc-053b-4062-bd6c-aeeed6cdbcd9
;; :END:

;; Often, I advise functions with other existing functions (such as =#'ignore=)
;; instead of defining my own advices. To maintain consistency with the naming
;; convention I created [[helpfn:void-add-advice][void-add-advice]]. It will create an advice with an
;; appropriate name to target.

(defun void--add-advice (target where advice &optional props expire-fn)
  "Advise TARGETS with Void ADVICES."
  (let* ((new-advice (void-advice-name target advice))
         (log-advice (void-symbol-intern new-advice '@ 'log-on-debug)))
    (defalias new-advice advice)
    (advice-add target where new-advice props)
    (fset log-advice
          `(lambda (&rest _)
             (alet ,(void-advice-action new-advice)
               (void-log "@ %s -%s-> %s" #',target ,where it))))
    (advice-add new-advice :before log-advice)
    (when expire-fn
      (->> (void-expire-advice target expire-fn)
           (advice-add new-advice :around)))))

;; ***** adding advice
;; :PROPERTIES:
;; :ID:       1298ea9d-870c-45da-9424-9cf8c66f7403
;; :END:

(defun void-add-advice (symbols where advices &optional props expire-fn)
  "Advise TARGETS with Void ADVICES."
  (dolist (symbol (-list symbols))
    (dolist (advice (-list advices))
      (void--add-advice symbol where advice props expire-fn))))

;; ***** interactively
;; :PROPERTIES:
;; :ID:       f9c9bf89-56ca-43c5-816d-88311e9b9bad
;; :END:

(defun void/add-advice ()
  ""
  (interactive)
  (completing-read )
  )

;; **** remove advice
;; :PROPERTIES:
;; :ID:       3d13ea95-44aa-4261-8480-5ae9701d533d
;; :END:

;; Since we can get the advisee from the advise name, or remove advice only needs
;; one argument--the advice to remove.

(defun void-remove-advice (advice)
  "Remove advice."
  (advice-remove (void-advised-fn advice) advice))

;; **** advice action
;; :PROPERTIES:
;; :ID:       f15279e9-cd0c-4a74-bc74-389d14a4b82a
;; :END:

(defun void-advice-action (advice)
  "Return the action for advice."
  (->> (symbol-name advice)
       (s-match (rx "@" (group (1+ (not (any "@" white)))) eos))
       (nth 1)))

;; **** expire advice
;; :PROPERTIES:
;; :ID:       8506fa78-c781-4ca8-bd58-169cce23a504
;; :END:

;; Often there are functions you want to advise just once. For example, loading a
;; feature just before a function that needs it is called. Although it's harmless,
;; you don't want to keep reloading the feature everytime the function is called.
;; The way I handle this situation is by creating a function that generates an
;; =expire-advice=. When an =expire-advice= it will.

;; Note that this function returns must be evaluated with lexical binding to work.

(defun void-expire-advice (fn &optional expire-fn unbind)
  "Return an advice that causes FN to expire when EXPIRE-FN returns true.
FN is a function. EXPIRE-FN is a function that returns true when FN
should expire."
  (let ((expire-advice (void-advice-name fn 'expire))
        (expire-fn (or expire-fn (lambda () t))))
    (fset expire-advice
          (lambda (orig-fn &rest args)
            (aprog1 (apply orig-fn args)
              (when (funcall expire-fn)
                (when (void-advice-p fn)
                  (advice-remove (void-advisee fn) fn))
                (when (void-hook-p target)
                  (remove-hook (void-hook-var FN)))
                (advice-remove target expire-advice)
                (fmakunbound expire-advice)
                (void-log "%s has expired." target)
                (when unbind
                  (fmakunbound target))))))
    expire-advice))

;; **** defadvice!
;; :PROPERTIES:
;; :ID:       1e0f3a27-a7d8-4e28-a359-f42ed7a16033
;; :END:

;; This section pertains to [[helpfn:defadvice!][defadvice!]], a replacement for [[helpfn:define-advice][define-advice]] that
;; provides a declarative way to define advices. This should be used for one-time
;; advices that.

;; ***** define-advice!
;; :PROPERTIES:
;; :ID:       cc161eaf-a8fb-4e24-853f-a76a49c28dcf
;; :END:

;; The only difference between this and [[helpfn:define-advice][define-advice]] is that =NAME= and =SYMBOL= are
;; switched. In my opinion, the unique part of the function name being first is
;; more consistent with =defun=.

(defmacro define-advice! (name args &rest body)
  "A wrapper around `define-advice'.
The only difference is that this switches the order the arguments have to be
passed in.

\(fn ACTION (WHERE &optional ADVICE-ARGS TARGET &rest TARGETS) &rest BODY)"
  (declare (indent 2) (doc-string 3) (debug (sexp sexp body)))
  (unless (listp args)
    (signal 'wrong-type-argument (list #'listp args)))
  (-let (((where lambda-args fn props) args)
         (advice-name (intern (format "void--%s-advice" name))))
    `(aprog1 (defun ,name ,lambda-args ,@body)
       (void-add-advice #',fn ,where it ,props))))

;; ***** anaphoric defadvice!
;; :PROPERTIES:
;; :ID:       98b2ce63-da31-4f7a-b776-1ee1747b5d57
;; :END:

;; =anaphoric-define-advice!= lets you omit the =lambda-args=. If you do omit the
;; arguments and you want to use them, you can do so via [[id:9938b1e1-6c6e-4a45-a85e-1a7f2d0bf6df][anaphoric variables]].

;; Note that [[helpfn:help-function-arglist][help-function-arglist]] returns =t= when it fails to get the function
;; arguments.

(defmacro anaphoric-define-advice! (name args &rest body)
  "A variant of `define-advice!'.
Unlike `define-advice!', this macro does not take an arglist as an argument.
Instead, arguments are accessed via anaphoric variables.

\(fn ACTION (WHERE TARGET &rest TARGETS) &rest BODY)"
  (-let* (((where target . other-args) args)
          (advice-args (if (eq where :around)
                           '(<orig-fn> &rest <args>)
                         '(&rest <args>))))
    `(define-advice! ,name (,where ,advice-args ,target ,@other-args)
       (ignore <args>)
       (cl-progv (->> (alet (help-function-arglist #',target t)
                        ;; kind of a hack...
                        (if (eq t it) nil it))
                      (--remove (s-starts-with-p "@" (symbol-name it)))
                      (--map (intern (format "<%s>" (symbol-name it)))))
           <args>
         ,@body))))

;; ***** defadvice!
;; :PROPERTIES:
;; :ID:       d8773e00-1abe-4b03-82f0-07b47e93ccb4
;; :END:

;; This macro takes care of allowing multiple advices and deciding between whether
;; to use =defadvice!= or =anaphoric-defadvice!=.

(defmacro defadvice! (name args &rest body)
  "Define and advice.

\(fn ACTION (WHERE &optional ARGS-LIST TARGET &rest TARGETS) &rest BODY)"
  (-let* ((symbols-only (lambda (it) (and (symbolp it) (not (keywordp it)))))
          ((before fns after) (-partition-by symbols-only args))
          (advice-macro (if (listp (nth 1 args))
                            'define-advice!
                          'anaphoric-define-advice!)))
    `(progn
       ,@(--map `(,advice-macro ,name (,@before ,it ,@after) ,@body)
                fns))))

;; **** generic advices
;; :PROPERTIES:
;; :ID:       d5743200-e27c-4702-833b-6690613cadb5
;; :END:

;; There are some advices that I tend to use over and over again which do not lend
;; themselves to =defadvice!= which is designed for the one-time declaration of an
;; advice. For these advices, I define them explicitly and use =void-add-advice= to
;; add them.

;; ***** boost gc-cons-threshold
;; :PROPERTIES:
;; :ID:       41e763bd-215f-4176-95c1-f41261864671
;; :END:

(defun void--boost-gargbage-collection-advice (orign-fn &rest args)
  "Boost garbage collection for the duration of ORIGN-FN."
  (let ((gc-cons-threshold VOID-GC-CONS-THRESHOLD-MAX)
        (gc-cons-percentage VOID-GC-CONS-PERCENTAGE-MAX))
    (apply orign-fn args)))

;; ***** use =void-log= instead of =message=
;; :PROPERTIES:
;; :ID:       adab4d98-ac13-4916-8349-99aa014d8f5c
;; :END:

;; Packages like [[][]] come with their own output.

(defun void--use-void-log (orign-fn &rest args)
  (noflet ((message (&rest args) (void-log args)))
          (apply orign-fn args)))

;; *** set!

;; Some variables in emacs have [[][custom setters]]. I don't want to have to figure out
;; which ones do and do not have these setters. This macro sets the custom setter
;; of there is any.
;;
;; There's also the issue of global versus buffer-local variables. In general, when
;; I set a variable I want it enabled globally. When there comes a case in which I
;; don't want that I'll use [[helpfn:setq][setq]].
;;
;; For this reason I use =set!= as a replacement for =setq=.
;;
;; [[https://opensource.com/article/20/3/variables-emacs][This articla]] provides
;; a brilliant synopsis of emacs variables.

(defmacro set! (sym val)
  "Account for."
  `(funcall (or (get ',sym 'custom-set) 'setq-default) ',sym ,val))

;; *** eval-after-load!
;; :PROPERTIES:
;; :ID:       8d831084-539b-4072-a86a-b55afb09bf02
;; :END:

;; If an =eval-after-load= block contains an error and it is triggered by a
;; feature, the error will keep raised everytime you load that feature.
;; Furthermore, this could interfere with the loading of other things. So I catch
;; the error and print it out.

(defmacro eval-after-load! (feature &rest body)
  "A wrapper around `eval-after-load!' with error catching."
  (declare (indent defun))
  `(eval-after-load ',feature
     '(with-no-warnings
        (condition-case error
            (progn ,@body)
          (error
           (message "Error in `eval-after-load': %S" error))))))

;; *** after!
;; :PROPERTIES:
;; :ID: b31cd42d-cc57-492d-afae-d7d5e353e931
;; :END:

;; The reason that we check for the feature is to prevent [[hvar:eval-after-load][eval-after-load]] from polluting the
;; [[hvar:after-load-list][after-load-list]]. =eval-after-load= adds an entry to =after-load-list= whether or not it has
;; been loaded.

;; We intentionally avoid with-eval-after-load to prevent eager macro expansion
;; from pulling (or failing to pull) in autoloaded macros/features.

(defmacro after! (features &rest body)
  "Wrapper around `with-eval-after-load'."
  (declare (indent defun) (debug t))
  (cond ((eq 'or features)
         (macroexp-progn
          (--map `(after! ,it ,@body) (cdr features))))
        ((eq 'and features)
         (void-wrap-form (--map `(after! ,it) (cdr features))
                         (macroexp-progn body)))
        ((listp features)
         `(after! ,(cons 'and features) ,@body))
        ((symbolp features)
         `(if (featurep ',features)
              ,(macroexp-progn body)
            (eval-after-load! ,features ,@body)))
        (t (error "Invalid argument."))))

;; *** keyfreq
;; :PROPERTIES:
;; :ID:       626b35f7-eef1-4a75-b2dc-8600c1ac47b7
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "dacap/keyfreq"
;; :PACKAGE:  "keyfreq"
;; :LOCAL-REPO: "keyfreq"
;; :COMMIT:   "e5fe9d585ce882f1ba9afa5d894eaa82c79be4f4"
;; :END:

(void-add-hook 'emacs-startup-hook #'keyfreq-mode)

;; *** system-packages
;; :PROPERTIES:
;; :ID:       74bd0e5a-f6b0-48eb-a91e-3932eae23516
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     gitlab
;; :REPO:     "jabranham/system-packages"
;; :PACKAGE:  "system-packages"
;; :LOCAL-REPO: "system-packages"
;; :COMMIT:   "92c58d98bc7282df9fd6f24436a105f5f518cde9"
;; :END:

;; **** settings
;; :PROPERTIES:
;; :ID:       e43a8862-4e3a-4050-a15e-d39fd25dfccb
;; :END:

(set! system-packages-noconfirm t)

;; **** popup
;; :PROPERTIES:
;; :ID:       69631be9-ce8f-4f65-b112-229bf1722621
;; :END:

(push '("\\*system-packages"
        (display-buffer-at-bottom)
        (window-height . 0.5))
      display-buffer-alist)

;; **** use yay for arch
;; :PROPERTIES:
;; :ID:       2fc48e66-83f3-4e35-8b2c-ef9113cb9b45
;; :END:

;; If we're in arch and we have yay intalled, use that.
(after! system-packages
  (when (and (eq system-packages-package-manager 'pacman)
             (system-packages-package-installed-p "yay"))
    (alet (alist-get 'pacman system-packages-supported-package-managers)
      (push `(yay
              ;; yay doesn't want sudo passed in (I believe it uses a fakeroot environment)
              (default-sudo . nil)
              ,@(-map (-lambda ((action . command))
                        (cons action (s-replace "pacman" "yay" command)))
                      (cdr it)))
            system-packages-supported-package-managers))
    (set! system-packages-package-manager 'yay)))

;; *** idle-require
;; :PROPERTIES:
;; :ID:       0d619336-e852-4c6a-89a8-38ccbb71a077
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "nschum/idle-require.el"
;; :PACKAGE:  "idle-require"
;; :LOCAL-REPO: "idle-require.el"
;; :COMMIT:   "33592bb098223b4432d7a35a1d65ab83f47c1ec1"
;; :END:

;; Idle require is a tool for loading autoload functions, files or features during
;; idle time. The way to use this is to idle-require many small packages that
;; individually don't take too much time. This helps ensure that in emacs loading
;; of big packages like org-mode is snappy.

;; **** init
;; :PROPERTIES:
;; :ID:       43d2350f-f7c4-43d3-9612-f78ccdf9d649
;; :END:

(require 'idle-require)
(void-add-hook 'emacs-startup-hook #'idle-require-mode)

;; **** settings
;; :PROPERTIES:
;; :ID:       d16db762-9c50-4b00-9f2d-b4b5d15855cf
;; :END:

;; When emacs goes idle for [[helpvar:idle-require-idle-delay][idle-require-idle-delay]] seconds, the features will
;; start loading. [[helpvar:idle-require-load-break][idle-require-load-break]] is the break between features idle
;; require loads.

(set! idle-require-load-break 2)
(set! idle-require-idle-delay 10)

;; **** make idle require use void-log
;; :PROPERTIES:
;; :ID:       109011ee-ab24-4f3e-867f-21d6f6f534a8
;; :END:

;; =idle-require= messages us to tell us when a package is being idle required and
;; when it has finished idle-requiring packages. I don't want to see the message
;; unless I'm debugging.

(void-add-advice #'idle-require-load-next :around #'void--use-void-log)

;; **** increase gc-cons-threshold during idle loading
;; :PROPERTIES:
;; :ID:       275c3488-8192-476c-97b8-6c6643f54d2e
;; :END:

;; Since we're evaluating a good amount of lisp expressions, we should boost
;; garbage collection during this time.

(void-add-advice #'idle-require-load-next :around #'void--boost-garbage-collection)

;; *** org-ml
;; :PROPERTIES:
;; :ID:       8bac9361-2c29-4e17-b6e2-10ec679a5e24
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "ndwarshuis/org-ml"
;; :PACKAGE:  "org-ml"
;; :LOCAL-REPO: "org-ml"
;; :COMMIT:   "93e13bfc74e0c68d3c12a9d1405f91ce86a3d331"
;; :END:

;; [[https://github.com/ndwarshuis/org-ml.git][org ml]] is a functional library for programmatically generating org mode
;; structures. It was built for.

;; *** ts
;; :PROPERTIES:
;; :ID:       64d19467-a878-449c-8402-88892c25ac9a
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :repo:     "alphapapa/ts.el"
;; :package:  "ts"
;; :local-repo: "ts.el"
;; :COMMIT:   "df48734ef046547c1aa0de0f4c07d11964ef1f7f"
;; :END:

;; =ts= is a time package.

;; *** with-os!
;; :PROPERTIES:
;; :ID: 1a645745-11ce-4cfb-8c5f-63470f0a61c3
;; :END:

;; Emacs is for the most part operating system agnostic. Packages written in elisp
;; should work across operating systems. Nevertheless, there are a handful of
;; settings that should favors particular operating systems over others.

(defmacro with-os! (os &rest body)
  "If OS is current system's operating system, execute body.
OS can be either `mac', `linux' or `windows'(unquoted)."
  (declare (indent defun))
  (when (funcall (cond ((eq :not (car-safe os)) (-not #'member))
                       (t #'member))
                 (pcase system-type
                   (`darwin 'mac)
                   (`gnu/linux 'linux)
                   (`(cygwin windows-nt ms-dos) 'windows)
                   (_ nil))
                 (-list os))
    `(progn ,@body)))

;; *** macros
;; :PROPERTIES:
;; :ID:       f27aa611-a2bd-4b76-85ce-72feb1e9f19f
;; :END:

;; **** ignore!
;; :PROPERTIES:
;; :ID: 0597956f-d40c-4c2b-9adf-5ece8c5b38de
;; :END:

(defmacro ignore! (&rest _)
  "Do nothing and return nil."
  nil)

;; **** list mutation
;; :PROPERTIES:
;; :ID:       d9f77404-5c29-4305-ae53-e409e1b06b99
;; :END:

;; ***** append!
;; :PROPERTIES:
;; :ID: f314672c-f9f3-4630-9402-a9a65215c153
;; :END:

(defmacro append! (sym &rest lists)
  "Append LISTS to SYM.
SYM is a symbol that stores a list."
  (declare (indent 1))
  `(setq ,sym (append ,sym ,@lists)))

;; ***** prepend!
;; :PROPERTIES:
;; :ID: 3395dec3-0915-49cd-9445-d3db2b1ffe7f
;; :END:

(defmacro prepend! (sym &rest lists)
  (declare (indent defun))
  `(setq ,sym (append ,@lists ,sym)))

;; ***** nconc!
;; :PROPERTIES:
;; :ID: b24d1d8f-f3e1-4dca-afdb-8fb73d5299c3
;; :END:

(defmacro nconc! (sym &rest lists)
  "Append LISTS to SYM by altering them in place."
  (declare (indent 1))
  `(setq ,sym (nconc ,sym ,@lists)))

;; *** autoload
;; :PROPERTIES:
;; :ID:       56bf4e09-1ce4-406c-a18f-e93ba8c4ad39
;; :END:

;; I am using my own simple autoload system that is purely emacs lisp.

;; **** package autoload
;; :PROPERTIES:
;; :ID:       93e8c19b-2306-4e7f-9b43-3418e07a1b9c
;; :END:

(defvar void-package-autoloads (ht-create)
  "A hash-table mapping packages to a list of its autoloads.")

;; **** hook that
;; :PROPERTIES:
;; :ID:       da32e049-e980-47af-b8d9-d3c644702229
;; :END:

;; I put this code in a hook instead of [[][]] because there may be other ways that
;; said package ends up getting loaded besides calling one of the autoload
;; functions.

(defhook! remove-and-unbind-autoloads (before-load-hook)
  "Hook run before feature is loaded."
  (void-log "Removing autoloads from package")
  (--each (ht-get void-package-autoloads package)
    (fmakunbound it))
  (ht-remove void-package-autoloads package))

;; **** autoloading
;; :PROPERTIES:
;; :ID:       e648ce0e-bb00-452d-9498-236c65e3a873
;; :END:

;; Emacs has a built-in [[][autoloading facility]]. I don't use that because it
;; involves. Autoloading can be done in elisp. You define a dummy function which
;; unbinds itself, loads the specified package, then calls the real function.

(defun void-autoload (package fn)
  "Create a function that can be called."
  ;; add function to hash table.
  (unless (fboundp fn)
    (ht-set void-package-autoloads package
            (cons fn (ht-get void-package-autoloads package)))
    (fset fn `(lambda (&rest args)
                ;; will trigger the before-load hook.
                (require package)
                (funcall #',fn ,args)))))

;; *** loading on call
;; :PROPERTIES:
;; :ID:       fa6583aa-5e7c-4212-be8a-b90b4c08aa31
;; :END:

;; Instead of loading all features on startup, we want to load features only when
;; we need them--just in time. And by "just in time" I mean at the last possible
;; moment or in practice just before a function that uses this feature is called.
;; While I could use =defadvice!= for defining these advices, doing this would
;; quickly become repetative because it's something that is done so often in
;; package configuration. The function =before-call= and =after-call= provide a fast
;; and convenient way to do this.

;; **** load-on-call
;; :PROPERTIES:
;; :ID:       324e707b-2f44-4168-a846-037f5401dedb
;; :END:

;; I want a shorthand for advices that involve package loading.

(defun void--load-on-call (package where functions)
  "Load packages FUNCTIONS are called."
  (alet (fset (void-symbol-intern 'void--load- package)
              `(lambda () (require ',package)))
    (void-add-advice it where functions nil t)))

;; **** load before call
;; :PROPERTIES:
;; :ID:       cc0e92bc-cd6d-4994-82ea-eb065fc3ad89
;; :END:

(defun void-load-before-call (package functions)
  (void--load-before-call package :before functions))

;; **** load after call
;; :PROPERTIES:
;; :ID:       b0b294d0-15ac-42d9-9e4c-fd9da8a95206
;; :END:

(defun void-load-after-call (package functions)
  (void--load-after-call package :after functions))

;; ** Init
;; :PROPERTIES:
;; :ID:       71dbf82e-cf4f-4e8a-b14d-df78bea5b20f
;; :END:

;; *** gc cons threshold
;; :PROPERTIES:
;; :ID: 27ad0de3-620d-48f3-aa32-dfdd0324a979
;; :END:

;; A big contributor to long startup times is the garbage collector. When
;; performing a large number of calculations, it can make a big difference to
;; increase the [[helpvar:gc-cons-threshold][gc-cons-threshold]], or the /number of bytes of consing between
;; garbage collections/. The default value is usually too low for modern machines.

;; **** minibuffer
;; :PROPERTIES:
;; :ID: 83f47b4d-a0e2-4275-9c1a-7e317fdc4e41
;; :END:

;; [[helpvar:minibuffer-setup-hook][minibuffer-setup-hook]] and [[helpvar:minibuffer-exit-hook][minibuffer-exit-hook]] are the hooks run just before
;; entering and exiting the minibuffer (respectively). In the minibuffer I'll be
;; primarily doing searches for variables and functions. There are alot of
;; variables and functions so this can certainly get computationally expensive. To
;; keep things snappy I increase boost the [[helpvar:gc-cons-threshold][gc-cons-threshold]] just before I enter
;; the minibuffer, and restore it to it's original value a few seconds after it's closed.

;; It would take me forever to guess the name =minibuffer-setup-hook= from the
;; variable [[helpvar:minibuffer-exit-hook][minibuffer-exit-hook]]. If I knew the name =minibuffer-exit-hook= but did not
;; know what the hook to enter the minibuffer was, I'd probably
;; =minibuffer-enter-hook= because [[https://www.wordhippo.com/what-is/the-opposite-of/exit.html]["enter" is one of the main antonyms of "exit"]].
;; It'd take me forever to guess =startup=. Note that the only tricky thing about
;; this example.

;; At first I thought of =entry= but after more thought I realized
;; hook variables use action verbs in their names not nouns. So the =exit= in
;; =minibuffer-exit-hook= is actually the verb =exit= not the noun.

(defvaralias 'minibuffer-enter-hook 'minibuffer-setup-hook)

(defhook! boost-garbage-collection (minibuffer-enter-hook)
  "Boost garbage collection settings to `VOID-GC-CONS-THRESHOLD-MAX'."
  (setq gc-cons-threshold VOID-GC-CONS-THRESHOLD-MAX))

(defhook! defer-garbage-collection (minibuffer-exit-hook :append t)
  "Reset garbage collection settings to `void-gc-cons-threshold' after delay."
  (run-with-idle-timer 3 nil (lambda () (setq gc-cons-threshold VOID-GC-CONS-THRESHOLD))))

;; **** gc cons threshold
;; :PROPERTIES:
;; :ID: e15d257f-1b0f-421e-8b34-076b1d20e493
;; :END:

(defconst VOID-GC-CONS-THRESHOLD-MAX (eval-when-compile (* 256 1024 1024))
  "The upper limit for `gc-cons-threshold'.
When VOID is performing computationally intensive operations,
`gc-cons-threshold' is set to this value.")

(defconst VOID-GC-CONS-THRESHOLD (eval-when-compile (* 16 1024 1024))
  "The default value for `gc-cons-threshold'.")

(defconst VOID-GC-CONS-PERCENTAGE-MAX 0.6
  "The upper limit for `gc-cons-percentage'.
When VOID is performing computationally intensive operations,
`gc-cons-percentage' is set to this value.")

(defconst VOID-GC-CONS-PERCENTAGE 0.1
  "The default value for `gc-cons-percentage'.")

;; **** gcmh
;; :PROPERTIES:
;; :ID:       86653a5a-f273-4ce4-b89b-f288d5d46d44
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     gitlab
;; :REPO:     "koral/gcmh"
;; :PACKAGE:  "gcmh"
;; :LOCAL-REPO: "gcmh"
;; :COMMIT:   "84c43a4c0b41a595ac6e299fa317d2831813e580"
;; :END:

(require 'gcmh)

(setq gcmh-idle-delay 10)
(setq gcmh-verbose void-debug-p)
(setq gcmh-high-cons-threshold (* 16 1024 1024))

(void-add-hook 'emacs-startup-hook #'gcmh-mode)

;; *** directories
;; :PROPERTIES:
;; :ID: 93cc2db1-44c7-45ec-af98-5a4eb7145f61
;; :END:

;; **** core directories and files
;; :PROPERTIES:
;; :ID: ad18ebcb-803a-4fd6-adcb-c71cf54f3432
;; :END:

;; This headline contains constant variables that store important directories and
;; files.

;; ***** top level
;; :PROPERTIES:
;; :ID: 48bf884a-de27-45f8-a5b1-94567815942d
;; :END:

;; These are important files and directories that I end up referring to often in my
;; code.

(defconst VOID-EMACS-DIR (file-truename user-emacs-directory)
  "Path to `user-emacs-directory'.")

(defconst VOID-INIT-FILE (concat VOID-EMACS-DIR "init.el")
  "Path to the elisp file that bootstraps Void startup.")

(defconst VOID-MAIN-ORG-FILE (concat VOID-EMACS-DIR "main.org")
  "Path to the Org file that when that Void.")

(defconst VOID-MULTIMEDIA-DIR (concat VOID-EMACS-DIR "screenshots/")
  "Directory where any multimedia describing VOID should go.
 These could screenshots are for detailing any problems, interesting behaviors or features.")

(defconst VOID-TEST-FILE (concat VOID-EMACS-DIR "test.org")
  "Path to the file that contains all of Void's tests.")

;; ***** org
;; :PROPERTIES:
;; :ID:       c88f95cd-f5bd-4c69-8679-7e42c52e9a36
;; :END:

(defconst VOID-ORG-DIR (expand-file-name "~/Documents/org/")
  "Path where Void's org files go.")

(defconst VOID-CAPTURE-FILE (concat VOID-ORG-DIR "capture.org")
  "File where all org captures will go.")

;; ***** hidden
;; :PROPERTIES:
;; :ID: d46d573b-1d17-4d0b-9b49-9049dbb6f7c1
;; :END:

(defconst VOID-LOCAL-DIR (concat VOID-EMACS-DIR ".local/")
  "Path to the directory for local Emacs files.
Files that need to exist, but I don't typically want to see go here.")

(defconst VOID-DATA-DIR (concat VOID-LOCAL-DIR "data/")
  "Path to the directory where Void data files are stored.")

(defconst VOID-PACKAGES-DIR (concat VOID-LOCAL-DIR "packages/")
  "Path to the directory where packages are stored.")

;; **** system directories
;; :PROPERTIES:
;; :ID:       f3bdd353-b0ff-48fd-a2f2-295ccfa139ab
;; :END:

;; These are directories I have on my system.

(defconst VOID-DOWNLOAD-DIR (expand-file-name "~/Downloads/")
  "Directory where downloads should go.")

(defconst VOID-MULTIMEDIA-DIR (expand-file-name "~/Multimedia/")
  "Directory where multimedia should go.")

(defconst VOID-VIDEO-DIR (concat VOID-MULTIMEDIA-DIR "Videos/")
  "Directory where videos should go.")

(defconst VOID-MUSIC-DIR (concat VOID-MULTIMEDIA-DIR "Music/")
  "Directory where music should go.")

(defconst VOID-ALERT-SOUNDS (concat VOID-MULTIMEDIA-DIR "Alert Sounds/")
  "Directory where alert sounds should go.")

(defconst VOID-EMAIL-DIR (expand-file-name "~/.mail/")
  "Directories where emails are stored.")

;; **** ensure directories exist
;; :PROPERTIES:
;; :ID: 56e80dda-5d0e-4c7c-a225-00d0028d4995
;; :END:

;; I create the directories that don't exist. But I assume they already exist if
;; Void is compiled.

(dolist (dir (list VOID-LOCAL-DIR VOID-DATA-DIR VOID-ORG-DIR))
  (make-directory dir t))

;; *** default coding system
;; :PROPERTIES:
;; :ID:       4c55a0d4-dbd7-4405-b944-3b68d8a069f2
;; :END:

(defconst VOID-DEFAULT-CODING-SYSTEM 'utf-8
  "Default text encoding.")

;; *** UTF-8
;; :PROPERTIES:
;; :ID: dd0fc702-67a7-404c-849e-22804663308d
;; :END:

;; I set =utf-8= as the default encoding for everything except the clipboard on
;; windows. Window clipboard encoding could be wider than =utf-8=, so we let
;; Emacs/the OS decide what encoding to use.

(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

;; *** initial buffer choice
;; :PROPERTIES:
;; :ID:       8eb302a6-cbc0-40ed-a046-b4c2d3dbc997
;; :END:

(defun void-initial-buffer ()
  "Return the initial buffer to be displayed.
This function is meant to be used as the value of `initial-buffer-choice'."
  (if void-debug-p
      (get-buffer "*Messages*")
    (get-buffer "*scratch*")))

;; *** defined in c source code
;; :PROPERTIES:
;; :ID:       873e6820-52f0-4b70-9992-ccb1610eb266
;; :END:

;; **** default settings
;; :PROPERTIES:
;; :ID: 8d578668-9b0b-4117-bf93-f556e970527b
;; :END:

(setq-default fringe-indicator-alist
              (delq (assq 'continuation fringe-indicator-alist)
                    fringe-indicator-alist))
(setq-default highlight-nonselected-windows nil)
(setq-default indicate-buffer-boundaries nil)
(setq-default inhibit-compacting-font-caches t)
(setq-default max-mini-window-height 0.3)
(setq-default mode-line-default-help-echo nil)
(setq-default mouse-yank-at-point t)
(setq-default resize-mini-windows 'grow-only)
(setq-default show-help-function nil)
(setq-default use-dialog-box nil)
(setq-default visible-cursor t)
(setq-default x-stretch-cursor nil)
(setq-default ring-bell-function #'ignore)
(setq-default visible-bell nil)
(setq-default window-resize-pixelwise t)
(setq-default frame-resize-pixelwise t)

;; **** compilation
;; :PROPERTIES:
;; :ID: 65c83b28-9bee-48fe-856a-f9c38f28c817
;; :END:

;; Non-nil means load prefers the newest version of a file.
(setq-default load-prefer-newer t)

;; **** all
;; :PROPERTIES:
;; :ID:       276d0193-5a46-4034-b145-f235178678d6
;; :END:

;; File name in which to write a list of all auto save file names.
(setq auto-save-list-file-name (concat VOID-DATA-DIR "autosave"))
;; Directory of score files for games which come with GNU Emacs.
(setq shared-game-score-directory (concat VOID-DATA-DIR "shared-game-score/"))

(setq-default cursor-in-non-selected-windows nil)

(setq highlight-nonselected-windows nil)

;; When non-nil, accelerate scrolling operations.
(setq fast-but-imprecise-scrolling t)

(setq-default frame-inhibit-implied-resize t)

;; Non-nil means use lockfiles to avoid editing collisions.
(setq-default create-lockfiles nil)
;; Non-nil says by default do auto-saving of every file-visiting buffer.
(setq-default history-length 500)
;; Specifies whether to use the system's trash can.
(setq-default delete-by-moving-to-trash t)

;; Disabling bidirectional text provides a small performance boost. Bidirectional
;; text is useful for languages that read right to left.
(setq-default bidi-display-reordering 'left-to-right)
(setq-default bidi-paragraph-direction 'left-to-right)

;; Non-nil means echo keystrokes after this many seconds. A value of zero means
;; don't echo at all.
(setq-default echo-keystrokes 0)

;; Template for displaying mode line for current buffer.
(setq-default mode-line-format nil)

(setq-default locale-coding-system VOID-DEFAULT-CODING-SYSTEM)
(setq-default buffer-file-coding-system VOID-DEFAULT-CODING-SYSTEM)

;; **** scrolling
;; :PROPERTIES:
;; :ID: 21e56e37-5ff8-40d8-9f27-c3a3ab37dfb8
;; :END:

(setq-default hscroll-margin 2)
(setq-default hscroll-step 1)
(setq-default scroll-conservatively 1001)
(setq-default scroll-margin 0)
(setq-default scroll-preserve-screen-position t)

;; ***** spacing
;; :PROPERTIES:
;; :ID: 8b3f38f9-b789-43e3-b2c5-5152a67d2803
;; :END:

(setq-default fill-column 80)
(setq-default sentence-end-double-space nil)
(setq-default tab-width 4)

;; ***** line wrapping
;; :PROPERTIES:
;; :ID: e1564e28-d2ab-4649-b18b-24c27b897256
;; :END:

(setq-default word-wrap t)
(setq-default indicate-empty-lines nil)
(setq-default indent-tabs-mode nil)
(setq-default truncate-lines t)
(setq-default truncate-partial-width-windows 50)

;; ***** other
;; :PROPERTIES:
;; :ID: cd0aa7ad-97bc-48ec-9a09-8af56cbf6157
;; :END:

;; Non-nil means reorder bidirectional text for display in the visual order.
;; Disabling this gives Emacs a tiny performance boost.
(setq-default bidi-display-reordering nil)
(setq-default cursor-in-non-selected-windows nil)
(setq-default display-line-numbers-width 3)
(setq-default enable-recursive-minibuffers t)
(setq-default frame-inhibit-implied-resize t)

;; **** printing
;; :PROPERTIES:
;; :ID: 2dfce297-0f01-4576-ae5d-bb5856591ecb
;; :END:

;; When eval and replacing expressions, I want the printed result to express all
;; newlines in strings as =\n= as opposed to an actual newline. In fact, in general I
;; want any character to be expressed in =backslash + number or character= form. It
;; makes the strings more readable and easier to deal with.

;; Furthermore, I'd like printed lisp expressions to express quoted forms the way I
;; write them, with a ='= as opposed to the literal =(quote ...)=.

;; There comes a point when output is too long, or too nested to be usable. It's ok
;; to abbreviate it at this point.

(setq-default print-escape-newlines t)
(setq-default print-escape-multibyte t)
(setq-default print-escape-control-characters t)
(setq-default print-escape-nonascii t)
(setq-default print-length nil)
(setq-default print-level nil)
(setq-default print-quoted t)
(setq-default print-escape-newlines t)

;; *** void specific funtions
;; :PROPERTIES:
;; :ID: 1b49e07a-466f-41da-8b31-18c28421cf62
;; :END:

;; **** windows
;; :PROPERTIES:
;; :ID: 039a9070-2ba3-4e01-abd4-7bdb49cc5a3d
;; :END:

;; ***** split-right-and-focus
;; :PROPERTIES:
;; :ID: 6cb60d94-723b-48e5-850a-3483e78f6647
;; :END:

(defun void/window-split-right-and-focus ()
  "Split window right and select the window created with the split."
  (interactive)
  (select-window (split-window-right)))

;; ***** split-below-and-focus
;; :PROPERTIES:
;; :ID: d6a4a81f-007d-4b7e-97a3-e0bba3ff97a4
;; :END:

(defun void/window-split-below-and-focus ()
  "Split window below and select the window created with the split."
  (interactive)
  (select-window (split-window-below)))

;; **** all
;; :PROPERTIES:
;; :ID: e97267e8-fca8-4bf2-9899-7ec694e8a767
;; :END:

;; ***** quit emacs without hook
;; :PROPERTIES:
;; :ID: b82f721c-39f5-4d41-bb0f-d4c391238eb4
;; :END:

;; Sometimes something goes wrong with [[helpvar:kill-emacs-hook][kill-emacs-hook]] and because of that I can't
;; close emacs. For that reason, I have this function.

(defun void/kill-emacs-no-hook ()
  "Kill emacs, ignoring `kill-emacs-hook'."
  (interactive)
  (when (yes-or-no-p "Quit without `kill-emacs-hook'?")
    (let (kill-emacs-hook) (kill-emacs))))

;; ***** quit emacs brutally
;; :PROPERTIES:
;; :ID: 8753217c-4722-4183-bbb3-049707a37e54
;; :END:

;; I've never had to use this. But better be safe than sorry.

(defun void/kill-emacs-brutally ()
  "Tell an external process to kill emacs."
  (interactive)
  (when (yes-or-no-p "Do you want to BRUTALLY kill emacs?")
    (call-process "kill" nil nil nil "-9" (number-to-string (emacs-pid)))))

;; ***** new emacs instance
;; :PROPERTIES:
;; :ID: eaf80ec3-2bd4-4f05-8a9c-fa525894a6fe
;; :END:

(defun void/open-emacs-instance ()
  "Open a new emacs instance in debug-mode."
  (interactive)
  (cond ((eq system-type 'darwin)
         (start-process-shell-command
          "emacs"
          nil "open -n /Applications/Emacs.app --args --debug-init"))
        ((eq system-type 'gnu/linux)
         (start-process "emacs" nil "emacs" "--debug-init"))))

;; ***** kill all process of program
;; :PROPERTIES:
;; :ID: 913952e2-3727-4b38-aefc-4618c2771730
;; :END:

(defun void/kill-emacs-processes ()
  (interactive)
  (let ((count 1) (process "emacs"))
    (kill-process process)
    (while (ignore-errors (kill-process process))
      (setq process (format "emacs<%d>" count))
      (cl-incf count))
    (message "killed %d processes" count)))

;; ***** qutebrowser
;; :PROPERTIES:
;; :ID: 77bace13-5af8-4974-981a-e07bf271182f
;; :END:

(defun void/open-qutebrowser ()
  "Open qutebrowser."
  (interactive)
  (start-process "qutebrowser" nil "qutebrowser"))

;; **** messages buffer
;; :PROPERTIES:
;; :ID: 7064ea0e-20e0-481c-9d07-18e4506ee3e8
;; :END:

;; In Emacs, messages. The messages buffer is where messages displayed at the bottom
;; of the Emacs frame are recorded after they expire.

(defun void/switch-to-messages ()
  (interactive)
  (select-window (display-buffer (get-buffer "*Messages*"))))

;; **** main org file
;; :PROPERTIES:
;; :ID: fb605553-f234-410a-b27e-697dc667831b
;; :END:

(defun void/switch-to-main-org-file ()
  (interactive)
  (find-file (concat VOID-EMACS-DIR "main.org")))

;; **** main todo file
;; :PROPERTIES:
;; :ID: 2accd21d-7316-4fa5-bd8f-8f40935ed621
;; :END:

(defun void/switch-to-capture-file ()
  (interactive)
  (switch-to-buffer (find-file VOID-CAPTURE-FILE)))

;; **** turn on debug-mode
;; :PROPERTIES:
;; :ID: c1ac481a-6ebd-49ce-a930-3b0593283aee
;; :END:

(defun void/enable-debug-mode ()
  (interactive)
  (setq void-debug-p t))

;; **** switch to init file
;; :PROPERTIES:
;; :ID: 50c5e173-d737-4264-bac5-f13190d468dc
;; :END:

(defun void/switch-to-init-org-file ()
  "Switch to Void's init.el file."
  (interactive)
  (switch-to-buffer VOID-INIT-FILE))

;; **** quit emacs no prompt
;; :PROPERTIES:
;; :ID: d530718a-2b42-4e9b-8d7d-7813e0ae6381
;; :END:

(defun void/quit-emacs-no-prompt ()
  "Quit emacs without prompting."
  (interactive)
  (let (confirm-kill-emacs)
    (kill-emacs)))

;; *** =tty=
;; :PROPERTIES:
;; :ID: 63e351ad-9ef6-4034-9fca-861881c74d6a
;; :END:

;; When running emacs in terminal tty is *tremendously* slow.

(unless (display-graphic-p)
  (void-add-advice #'tty-run-terminal-initialization :override #'ignore)
  (defhook! init-tty (window-setup-hook)
    (advice-remove #'tty-run-terminal-initialization #'ignore)
    (tty-run-terminal-initialization (selected-frame) nil t)))

;; *** tangling
;; :PROPERTIES:
;; :ID: 3288c787-4b5c-4f0c-9d18-6f18afaf2b99
;; :END:

;; **** tangle hook
;; :PROPERTIES:
;; :ID: 549999d7-901b-4ab4-bdbe-81514b756ced
;; :END:

;; Void tangles itself just before quitting if [[helpfn:void-needs-tangling-p][void-needs-tangling-p]] returns true.
;; I tangle before quitting so I don't have to do it before startup. It's
;; preferable for quitting emacs to be slightly slower than for emacs startup to
;; be.

(defhook! tangle-on-quit-maybe (kill-emacs-hook :append t)
  "Tangle if `void-needs-tangling-p' returns t."
  (when (void-needs-tangling-p)
    (alet (concat VOID-LOCAL-DIR "main.el")
      (org-babel-tangle-file VOID-MAIN-ORG-FILE it))))

;; **** tangle asynchronously upon saving
;; :PROPERTIES:
;; :ID: 00298d4e-6b18-4203-874f-f5a877a5cabf
;; :END:

;; This is another attempt to keep my =main.el= file in sync as much as possible with
;; [[helpvar:VOID-README-FILE][void-main-org-file]]. ~void-tangle-on-save-h~ is called whenever a buffer is being
;; saved to a file. The reason why I use ~cl-letf~ to temporarily override [[helpfn:load][load]] is
;; because ~VOID-INIT-FILE~ already contains all the code I need so I don't want it
;; to waste time loading ~void-main-elisp-file~.

(defhook! tangle-maybe (after-save-hook)
  "Tangle `VOID-MAIN-ORG-FILE' asynchronously when it is saved."
  (when (and (require 'async nil t)
             (string= (file-truename VOID-MAIN-ORG-FILE)
                      (or (buffer-file-name (current-buffer)) ""))
             (void-needs-tangling-p))
    (async-start
     (lambda ()
       (let ((old-fn (symbol-function 'load))
             (user-init-file (concat user-emacs-directory "init.el")))
         (require 'cl)
         (cl-letf (((symbol-function 'load)
                    (lambda (file &rest args)
                      (when (string= user-init-file file)
                        (apply old-fn file args)))))
           (load user-init-file))))
     (lambda (_)
       (void-log
        (concat (if (void-needs-tangling-p) "✕ failed" "✓ succeeded")
                " tangling `VOID-MAIN-ORG-FILE'."))))))

;; *** prevent emacs from killing certain buffers
;; :PROPERTIES:
;; :ID:       ae935cf5-7322-499c-96d7-20209d9b6641
;; :END:

;; I never want the =*scratch*= and =*Messages*= buffer to be killed. I owe this idea
;; to [[https://github.com/rememberYou/.emacs.d][rememberYou's Emacs]].

(defhook! lock-certain-buffers (after-init-hook)
  "Prevent certain buffers from being killed."
  (--each (list "*scratch*" "*Messages*")
    (with-current-buffer it
      (emacs-lock-mode 'kill))))

;; ** Packages
;; :PROPERTIES:
;; :ID:       d5c0d112-319d-4271-a819-eb786a64bfc6
;; :END:

;; *** built-in
;; :PROPERTIES:
;; :ID: 40367976-12a0-4ccd-9aff-4df144a73edf
;; :END:

;; **** calc
;; :PROPERTIES:
;; :ID:       98c0a8c7-2dc1-4285-9b7b-146bbc2867ae
;; :END:

;; **** vc-hook
;; :PROPERTIES:
;; :ID:       a8dcb1f6-05a0-46cb-95b5-1d0cd0ad4467
;; :END:

(setq vc-follow-link t)
(setq vc-follow-symlinks t)

;; **** subr-x
;; :PROPERTIES:
;; :ID:       ee3ad1b5-920a-4337-9874-79e066ed53fe
;; :END:

(require 'subr-x)

;; **** startup
;; :PROPERTIES:
;; :ID: 9725b7e0-54b8-4ab4-aa00-d950345d0aea
;; :TYPE:     built-in
;; :END:

;; Emacs starts up with a default screen. Note that it doesn't seem this feature is
;; provided (perhaps it's too fundamental?), therefore I use =:pre-setq=.

(setq inhibit-startup-screen t)
(setq inhibit-default-init t)
(setq inhibit-startup-buffer-menu t)
(setq initial-major-mode 'fundamental-mode)
(setq initial-scratch-message nil)
(setq initial-buffer-choice #'void-initial-buffer)
(setq inhibit-startup-echo-area-message user-login-name)

;; **** paren
;; :PROPERTIES:
;; :ID: 8ba80d6f-292e-4d44-acfe-d7b7ba939fa4
;; :TYPE:     built-in
;; :END:

(setq-default show-paren-delay 0)
(void-add-hook 'prog-mode-hook #'show-paren-mode)

;; **** clipboard
;; :PROPERTIES:
;; :ID: 60abb076-89b1-439b-8198-831b2df47782
;; :TYPE:     built-in
;; :END:

(setq selection-coding-system 'utf-8)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; **** simple
;; :PROPERTIES:
;; :ID: 89df102a-a2c9-4ece-9acc-ed90e8064ed8
;; :TYPE:     built-in
;; :END:

(push '("\\*Messages"
        (display-buffer-at-bottom)
        (window-height . 0.5))
      display-buffer-alist)

(setq-default idle-update-delay 1)
(setq-default blink-matching-paren t)
(setq-default delete-trailing-lines nil)

(setq mail-user-agent 'mu4e-user-agent)

;; **** loaddefs
;; :PROPERTIES:
;; :ID:       5af4faf8-47e3-4db2-9d13-47fc828b8fca
;; :TYPE:     built-in
;; :END:

;; These are *extremely* important lines if you use an external program as I do
;; ([[https://wiki.archlinux.org/index.php/Msmtp][msmtp]]) to send your email. If you don't set these variables, emacs will
;; think you want to use =smtp=.

(setq-default disabled-command-function nil)

;; **** files
;; :PROPERTIES:
;; :ID: 2a7862da-c863-416b-a976-4cf7840a8712
;; :TYPE:     built-in
;; :END:

;; Disable second, case-insensitive pass over `auto-mode-alist'.
(setq-default auto-mode-case-fold nil)
;; Whether to add a newline automatically at the end of the file.
;; Whether confirmation is requested before visiting a new file or buffer.
(setq-default confirm-nonexistent-file-or-buffer nil)
;; How to ask for confirmation when leaving Emacs.
(setq-default confirm-kill-emacs #'y-or-n-p)
(setq-default require-final-newline nil)
(setq-default trash-directory (expand-file-name "Trash" "~"))
(setq-default auto-save-default nil)
(setq-default auto-save-interval 300)
(setq-default auto-save-timeout 30)
(setq-default backup-directory-alist (list (cons ".*" (concat VOID-DATA-DIR "backup/"))))
(setq-default make-backup-files nil)
(setq-default version-control nil)
(setq-default kept-old-versions 2)
(setq-default kept-new-versions 2)
(setq-default delete-old-versions t)
(setq-default backup-by-copying t)
(setq-default backup-by-copying-when-linked t)

;; **** subr
;; :PROPERTIES:
;; :ID:       61603f44-780e-4456-88c6-7ffe1e5c7197
;; :END:

(after! subr
  (fset #'yes-or-no-p #'y-or-n-p)
  (fset #'display-startup-echo-area-message #'ignore))

;; **** subr-x
;; :PROPERTIES:
;; :ID:       1ed0ba00-e5a1-4642-9ed5-a52f4b917a4d
;; :END:

(require 'subr-x)

;; **** ffap
;; :PROPERTIES:
;; :ID: b1229201-a5ac-45c7-91fa-7a6b39bbb879
;; :END:

;; Don't ping things that look like domain names.

(after! ffap
  (setq ffap-machine-p-known 'reject))

;; **** server
;; :PROPERTIES:
;; :ID: 3ddeb65c-9df6-4ede-9644-eb106b3ba1dd
;; :END:

(after! server
  (setq server-auth-dir (concat VOID-DATA-DIR "server/")))

;; **** tramp
;; :PROPERTIES:
;; :ID: 3af0a4d6-bd08-4fe2-bc5c-79b1b811fc6b
;; :END:

(after! tramp
  (setq tramp-backup-directory-alist backup-directory-alist)
  (setq tramp-auto-save-directory (concat VOID-DATA-DIR "tramp-auto-save/"))
  (setq tramp-persistency-file-name (concat VOID-DATA-DIR "tramp-persistency.el")))

;; **** desktop
;; :PROPERTIES:
;; :ID: 3a6b72e7-57c8-42f0-a8d7-1bbde72de9bd
;; :END:

(after! desktop
  (setq desktop-dirname (concat VOID-DATA-DIR "desktop"))
  (setq desktop-base-file-name "autosave")
  (setq desktop-base-lock-name "autosave-lock"))

;; **** cus-edit
;; :PROPERTIES:
;; :ID: 8bd5683d-91e1-4c1b-a8a5-3b39921e995d
;; :END:

(setq custom-file null-device)
(setq custom-theme-directory (concat VOID-LOCAL-DIR "themes/"))

;; **** url
;; :PROPERTIES:
;; :ID: e4b5bfce-1111-48b2-bfee-da754974aa46
;; :END:

(setq url-cache-directory (concat VOID-DATA-DIR "url/cache/"))
(setq url-configuration-directory (concat VOID-DATA-DIR "url/configuration/"))

;; **** bytecomp
;; :PROPERTIES:
;; :ID:       6b375bfb-a8c3-473c-8dbd-530e692a15ab
;; :END:

(setq byte-compile-verbose void-debug-p)
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

;; **** compile
;; :PROPERTIES:
;; :ID:       913aa4f2-e42b-4b74-a2d4-e87b1738a5bd
;; :END:

(setq compilation-always-kill t)
(setq compilation-ask-about-save nil)
(setq compilation-scroll-output 'first-error)

;; **** uniquify
;; :PROPERTIES:
;; :ID:       9ba2726b-3fef-4e9b-9387-a80ab09bdb7d
;; :END:

(after! uniquify
  (setq-default uniquify-buffer-name-style 'forward))

;; **** ansi-color
;; :PROPERTIES:
;; :ID:       5feaab76-e5c1-450c-94a6-8fdfb95ddb94
;; :END:

(use-feature! ansi-color
  :setq-default
  (ansi-color-for-comint-mode . t))

;; **** image mode
;; :PROPERTIES:
;; :ID:       32e2118a-c92b-4e8d-b2db-048428462783
;; :END:

(use-feature! image-mode
  :setq
  ;; Non-nil means animated images loop forever, rather than playing once.
  (image-animate-loop . t))

;; **** window
;; :PROPERTIES:
;; :ID:       af27cd7e-2096-4f6d-a749-63e4c38d136c
;; :END:

(use-feature! window
  :setq-default
  (split-width-threshold . 160))

;; **** paragraphs
;; :PROPERTIES:
;; :ID:       f289ade4-ad16-4f6a-8868-1f9b7af5ddca
;; :END:

(use-feature! paragraphs)

;; **** indent
;; :PROPERTIES:
;; :ID:       a5d97d4d-3af9-4fde-ae14-953ad4d28edd
;; :END:

(use-feature! indent
  :setq-default
  (tab-always-indent . t))

;; **** mouse
;; :PROPERTIES:
;; :ID:       d0d6de11-50fa-4ae2-ad4b-69712f3e2c54
;; :END:

(use-feature! mouse
  :setq-default
  (mouse-yank-at-point . t))

;; **** calendar
;; :PROPERTIES:
;; :ID:       4ad7e704-f490-40e4-b2bc-8a30a10a7bb7
;; :END:

(use-feature! calendar
  :pre-setq (diary-file . (concat VOID-DATA-DIR "diary"))
  :config
  (require 'f)
  (unless (f-exists-p diary-file)
    (f-touch diary-file)))

;; **** mule-cmds
;; :PROPERTIES:
;; :ID:       e48e925e-1f1e-4c79-8652-c92aafe06290
;; :END:

(use-feature! mule-cmds
  :init (prefer-coding-system VOID-DEFAULT-CODING-SYSTEM))

;; **** gv
;; :PROPERTIES:
;; :ID:       84cc5883-a303-453e-af91-644d4544e3f9
;; :END:

;; =gv= is what contains the code for the =setf= macro.
;; https://emacs.stackexchange.com/questions/59314/how-can-i-make-setf-work-with-plist-get

(use-feature! gv
  :config
  (gv-define-simple-setter plist-get plist-put))

;; **** nsm
;; :PROPERTIES:
;; :ID:       0ca7fc66-5312-4c69-a87d-7607292c7a2a
;; :END:

(use-feature! nsm
  :setq (nsm-settings-file . (concat VOID-DATA-DIR "network-settings.data")))

;; ** UI
;; :PROPERTIES:
;; :ID: c21a5946-38b1-40dd-b6c3-da41fb5c4a5c
;; :END:

;; *** maybe get rid of UI elements
;; :PROPERTIES:
;; :ID: 3f466dd8-13f1-4160-a2a5-da1acd4f3d3e
;; :END:

;; Emacs 27 and above allows the user to customize the UI in =early-init.el=. For
;; easy backwards usage previous version of emacs (25 and 26) I include.

(when (version< emacs-version "27")
  (ignore-errors
    (tool-bar-mode -1)
    (scroll-bar-mode -1)
    (menu-bar-mode -1)))

;; *** theme
;; :PROPERTIES:
;; :ID: 2ac7c2fe-a2ba-4e55-a467-ff4af8850331
;; :END:

;; **** theme to load
;; :PROPERTIES:
;; :ID: cd085611-9e56-4df4-97dd-f087899562c0
;; :END:

(defvar void-theme 'tsdh-light
  "The theme to load on startup.
The value of this variable is updated to the current theme whenever `load-theme'
is called.")

(setq custom-safe-themes t)

;; **** initialize at startup
;; :PROPERTIES:
;; :ID: 06b1f381-9066-4062-88d5-f376ad5d6df0
;; :END:

(defhook! set-theme (window-setup-hook)
  "Set the theme and load the font, in that order."
  (when (and void-theme (not (memq void-theme custom-enabled-themes)))
    (condition-case nil
        (load-theme void-theme t)
      (error (void-log "Could not load %s" void-theme)))))

;; **** loading theme
;; :PROPERTIES:
;; :ID: 7ae02d32-4652-494c-9e14-05f60ca60395
;; :END:

;; Sometimes there are things that need tidying up after loading a theme. For
;; example, if I'm using evil I need to update the cursor color.

(defvar void-after-load-theme-hook nil
  "Hook run after the theme is loaded with `load-theme'.")

(defadvice! run-after-load-theme-hook (:after load-theme)
  "Set up `void-load-theme-hook' to run after `load-theme' is called."
  (setq void-theme <theme>)
  (run-hooks 'void-after-load-theme-hook))

;; **** disable old themes first
;; :PROPERTIES:
;; :ID: 9d2f985b-8b0f-497f-982b-6f69c62179a9
;; :END:

;; Sometimes we end up with remants of the faces of old themes when we load a new
;; one. For this reason, I make sure to disable any enabled themes before applying
;; a new theme.

(defadvice! disable-old-themes (:around load-theme)
  "Disable old themes before loading new ones."
  (mapc #'disable-theme custom-enabled-themes)
  (apply <orig-fn> <args>))

;; ** Commands
;; :PROPERTIES:
;; :ID:       14fd249d-b972-472c-b57e-4e53a80b22dc
;; :END:

;; *** switch to buffer
;; :PROPERTIES:
;; :ID:       70c72340-8601-40a7-9ffe-8296ba720e6a
;; :END:

(defun void/switch-buffer ()
  "Wrapper around `switch-to-buffer'.
Prompt for buffer or recentf file to switch to. If buffer is selected, switch to
the buffer. If a recentf path is selected, find the file of the recentf path."
  (interactive)
  (let* ((other-buffers (--remove (s-prefix-p " " (buffer-name it)) (cdr (buffer-list))))
         (file-buffer-paths (-non-nil (-map #'buffer-file-name other-buffers))))
    (--> (append (-map #'buffer-name other-buffers)
                 (-difference recentf-list file-buffer-paths))
         (completing-read "Select buffer: " it)
         (funcall (if (-contains-p recentf-list it)
                      #'find-file
                    #'switch-to-buffer)
                  it))))

;; *** goto line
;; :PROPERTIES:
;; :ID:       14111399-f75a-40ba-b9be-15a8b6a07ae9
;; :END:

(defvar void:goto-line-history nil
  "Submission history for `selectrum-swiper'.")

(defun void/goto-line ()
  "Search for a matching line and jump to the beginning of its text."
  (interactive)
  (let* ((minimum-line-number (line-number-at-pos (point-min) t))
         (current-line-number (line-number-at-pos (point) t))
         (line-choices (->> (split-string (buffer-string) "\n")
                            (--map-indexed (unless (string-empty-p it)
                                             (format "L%d: %s" (+ it-index minimum-line-number) it)))
                            (-non-nil)))
         (chosen-line (completing-read "Jump to matching line: " line-choices
                                       nil t nil 'selectrum:swiper-history))
         (chosen-line-num (--> chosen-line
                               (s-match (rx "L" (group (+ digit)) ":") it)
                               (elt it 1)
                               (string-to-number it))))
    (push-mark (point) t)
    (forward-line (- chosen-line-num current-line-number))
    (beginning-of-line-text 1)))

;; *** set font
;; :PROPERTIES:
;; :ID:       f24d97b6-7c74-491a-a77c-ba3ec22a2b68
;; :END:

(defun void/set-font-face ()
  "Apply an existing xfont to all graphical frames."
  (interactive)
  (set-frame-font (completing-read "Choose font: " (x-list-fonts "*")) nil t))

;; *** switch to scratch buffer
;; :PROPERTIES:
;; :ID:       7d9af4b6-7744-437f-b088-ec9397056113
;; :END:

(defun void/open-scratch ()
  "Pop scratch."
  (interactive)
  (pop-to-buffer "*scratch*"))

;; * Window Management
;; :PROPERTIES:
;; :ID: 29dbf899-17cd-4b00-aacb-090ccd20e133
;; :END:

;; Window management is one of the most important things to get right if you're
;; going to be efficient in emacs (that is unless you're using primarily frames
;; instead of windows).

;; ** ace-window
;; :PROPERTIES:
;; :ID:       ff248a3a-5dbd-4a3d-b27d-1ac5e2b0215a
;; :REPO:     "abo-abo/ace-window"
;; :HOST:     github
;; :TYPE:     git
;; :COMMIT:   "c7cb315c14e36fded5ac4096e158497ae974bec9"
;; :FLAVOR:   melpa
;; :PACKAGE:  "ace-window"
;; :LOCAL-REPO: "ace-window"
;; :END:

;; [[https://github.com/abo-abo/ace-window][ace-window]] uses avy to navigate windows in cases when there are many. There is
;; an alternative package for this, [[https://github.com/dimitri/switch-window][switch-window]]. The advantage of =switch-window=
;; is that the characters used for switching to a window are *really* easy to see,
;; but you can't see the buffer contents. That's a no-go for me I need to see them.

(void-autoload 'ace-window '(ace-window ace-swap-window))
(general-def [remap other-window] #'ace-window)
(setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
(setq aw-background t)

;; ** workgroups2
;; :PROPERTIES:
;; :ID:       890c8e5b-524d-44b6-b90e-c830436b9da8
;; :HOST:     github
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("src/*.el" "workgroups2-pkg.el")
;; :REPO:     "pashinin/workgroups2"
;; :PACKAGE:  "workgroups2"
;; :LOCAL-REPO: "workgroups2"
;; :COMMIT:   "737306531f6834227eee2f63b197a23401003d23"
;; :END:

;; There is a need to save buffers and window configurations in their own groups.
;; Often we'll have a group of buffers we've setup to work on a project or task and
;; suddenly, in the middle of that task we'll want to work on another task. It's
;; inconvenient to get rid of the window configuration we've set up just to have to
;; come back to it and set it up again. This is what workspaces, also called
;; workgroups, are for. You can save the window configuration you're using and
;; switch to a new one.

;; Workgroup provides a. One notable advantage of workgroups is that it does not
;; use emacs's built-in serialization of window configs. Usually, it is better to
;; use something that's built-in. However, emacs's serialization has the drawback
;; that it's not a lisp object; implying that it is not.

;; *** settings
;; :PROPERTIES:
;; :ID:       3de17bba-1c3e-4d7d-a30c-f34f1eda640b
;; :END:

(setq wg-flag-modified nil)
(setq wg-session-file (concat VOID-DATA-DIR "wg-session"))

;; *** ignore changing the modeline
;; :PROPERTIES:
;; :ID:       a036dc89-7d5e-49b6-880c-87b4a4c2105e
;; :END:

(setq wg-mode-line-display-on nil)
(advice-add #'wg-change-modeline :override #'ignore)

;; *** save sessions on quit
;; :PROPERTIES:
;; :ID:       1ca7da0b-7227-48be-88a7-8ad738c5263e
;; :END:

(setq wg-emacs-exit-save-behavior 'save)
(setq wg-workgroups-mode-exit-save-behavior 'save)
(setq wg-flag-modified nil)

;; *** display in modeline
;; :PROPERTIES:
;; :ID:       80793c50-2954-4ea4-a7e5-df5e2da60d7f
;; :END:

(after! (feebleline all-the-icons)
  (defun feebleline:current-workgroup ()
    (when (bound-and-true-p workgroups-mode)
      (wg-workgroup-name (wg-current-workgroup)))))

;; ** window divider
;; :PROPERTIES:
;; :ID: 0bcebb71-f730-427f-9919-1538bd63456c
;; :TYPE:     built-in
;; :END:

;; Emacs can add border to windows using a mode called [[helpfn:window-divider-mode][window-divider-mode]].
;; Often in emacs you have multiple windows displaying different buffers on the
;; screen. By default the border between these windows is very thin, so it can be
;; hard to distinguish windows sometimes. The point of adding borders to windows is
;; to distinguish them easily from one another.

;; Window dividers are useful in general so I don't get confused about when one
;; window ends and another begins (see [[helpfn:window-divider-mode][window-divider-mode]]). When using [[I like emacs][exwm]] it
;; makes emacs feel like a window manager with gaps.

;; *** init
;; :PROPERTIES:
;; :ID:       c3e2fda8-89c8-4f3b-951a-113e936d6206
;; :END:

;; **** hooks
;; :PROPERTIES:
;; :ID:       66ada8e3-2fce-428b-a096-e3495e573414
;; :END:

(void-add-hook 'window-setup-hook #'window-divider-mode)

;; **** custom variables
;; :PROPERTIES:
;; :ID:       21010045-e2e1-4c13-a9d7-63468e6a5739
;; :END:

(general-setq window-divider-default-places t)
(general-setq window-divider-default-bottom-width 4)
(general-setq window-divider-default-right-width  4)

;; *** color
;; :PROPERTIES:
;; :ID:       61157149-dcce-40a9-8bfa-76a6af24838a
;; :END:

(set-face-foreground 'window-divider "black")

;; *** update on theme change
;; :PROPERTIES:
;; :ID: 342bd557-889b-4dbd-8e76-5cd9da3b0f74
;; :END:

(defhook! update-window-divider (void-after-load-theme-hook)
  "Ensure window divider persists after theme change."
  (unless (bound-and-true-p window-divider-mode)
    (window-divider-mode 1)))

;; *** adjust window divider gap size
;; :PROPERTIES:
;; :ID:       5485c926-fac0-4e87-ae97-f7bf25d0a55c
;; :END:

;; **** TODO increase gap size
;; :PROPERTIES:
;; :ID:       867fad5c-b4d4-4cba-929e-0dc23f007c5b
;; :END:

;; Somtimes I might want to adjust this.

(defun frame:adjust-window-divider-size (amount)
  "Adjust the gap size of window-divider by AMOUNT."
  (general-setq window-divider-default-bottom-width
                (+ amount window-divider-default-bottom-width))
  (general-setq window-divider-default-right-width
                (+ amount window-divider-default-right-width)))

;; **** increase
;; :PROPERTIES:
;; :ID:       ebd6b013-6213-42a1-9e95-fefc7e7da991
;; :END:

(defun frame/increment-window-divider-size ()
  "Increase window divider size."
  (interactive)
  (frame:adjust-window-divider-size 1))

;; **** decrease
;; :PROPERTIES:
;; :ID:       6b1eb1cd-1cfd-4b82-a413-cb61fa13e0a4
;; :END:

(defun frame/decrement-window-divider-size ()
  "Decrease window divider size."
  (interactive)
  (frame:adjust-window-divider-size -1))

;; ** transpose-frame
;; :PROPERTIES:
;; :ID: 5487535d-2534-4857-b1e0-c63b40917710
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "emacsorphanage/transpose-frame"
;; :PACKAGE:  "transpose-frame"
;; :LOCAL-REPO: "transpose-frame"
;; :COMMIT:   "12e523d70ff78cc8868097b56120848befab5dbc"
;; :END:

;; https://www.emacswiki.org/emacs/TransposeFrame

(alet (list #'transpose-frame #'flip-frame #'flop-frame
            #'rotate-frame #'rotate-frame-clockwise)
  (void-autoload 'transpose-frame it))

;; ** exwm
;; :PROPERTIES:
;; :ID: dbb69880-2180-4ecc-897d-78ff72a6358b
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacs-straight/exwm"
;; :FILES:    ("*" (:exclude ".git"))
;; :PACKAGE:  "exwm"
;; :LOCAL-REPO: "exwm"
;; :COMMIT:   "45ac28cc9cffe910c3b70979bc321a1a60e002ea"
;; :END:

;; [[https://github.com/ch11ng/exwm][EXWM]] (Emacs X-Window Manager) is a full-featured window manager in Emacs.
;; There are benefits and drawbacks to making emacs your window manager. One
;; benefit is that you get a super consistent window management experience. If you
;; use a typical window manager, you have to.

;; *** init
;; :PROPERTIES:
;; :ID:       581b8529-00a0-4935-9363-60dba9dbe5f4
;; :END:

(void-add-hook 'exwm-mode #'hide-mode-line-mode)
(void-load-before-call 'exwm (list #'browse-url))
(setq exwm-replace nil)

;; *** exwm
;; :PROPERTIES:
;; :ID: 18ee4dd8-445b-4101-adfb-ba8e18a71bb4
;; :END:

;; In fact, EXWM does not need to be loaded on startup. It is only needed when you
;; actually want to open another application such as a separate Emacs instance or
;; the web browser. This is great because EXWM actually does consume significant
;; startup time. Instead of loading =EXWM= immediately, I add advises to the
;; functions which open external linux applications.

(defhook! setup-hide-mode-line (exwm-mode-hook)
  (add-hook 'exwm-floating-setup-hook #'exwm-layout-hide-mode-line)
  (add-hook 'exwm-floating-exit-hook #'exwm-layout-show-mode-line))

;; *** start it
;; :PROPERTIES:
;; :ID:       bcfbb2b7-527d-4fdb-97f2-6d824bc9e94c
;; :END:

(after! exwm
  (exwm-init)
  ;; Enable the clipboard.
  (require 'exwm-systemtray)
  (exwm-systemtray-enable))

;; *** org capture from an exwm buffer
;; :PROPERTIES:
;; :ID:       5428bdc1-c075-4387-b3ab-080d372c478f
;; :END:

;; A common dream among many Org users is to integrate [[info:org#Capture][org-capture]] into their browser.
;; Indeed, the browser by nature would be a place you'd want to capture from a lot.
;; However, since graphical browsers are not in emacs the main way to do this was
;; via a hacky and difficult to set up [[https://orgmode.org/worg/org-contrib/org-protocol.html][org-protocol]].

;; https://www.reddit.com/r/emacs/comments/f6zzux/capturing_website_url_with_orgcapture_and_exwm/

;; **** exwm title
;; :PROPERTIES:
;; :ID:       ce78d409-e635-4d94-b20e-38c2034ab5e8
;; :END:

(defun exwm::title-info (title)
  "Return the webpage and the program."
  (-let [(_ webpage program) (s-match "\\([^z-a]+\\) - \\([^z-a]+\\)\\'" title)]
    (list webpage program)))

;; **** download webpage as pdf
;; :PROPERTIES:
;; :ID:       bd7165df-9dae-4954-b153-96335678e296
;; :END:

;; Storing the links is better, but not good enough. Webpages die. They can be
;; taken off by a third-party or removed by the owner themselves. Even if they
;; aren't though, they can be modified so that what you originally found isn't
;; there anymore. As a solution for this I came upon [[https://wkhtmltopdf.org/][wkhtmltopdf]], a command that
;; downloads a given webpage as pdf. A consequence of doing this is that you will
;; have access to all the webpages you used for research offline.

(defun void-download-webpage-as-pdf (url webpage-title)
  "Save the webpage at URL to `VOID-SCREENSHOT-DIR'."
  (let* ((program "wkhtmltopdf")
         (process-name (format "%s - %s" program (ts-format)))
         (webpage-title (s-replace "/" "~" webpage-title))
         (pdf-path (format "%s%s.pdf" VOID-SCREENSHOT-DIR webpage-title))
         (fn `(lambda (&rest _)
                (if (file-exists-p ,pdf-path)
                    (message "Webpage saved succesfully.")
                  (warn "Failed to save webpage %s to %s." ,url ,pdf-path)))))
    (message "%s <-- %s" (f-abbrev pdf-path) url)
    (async-start-process process-name "firejail" fn program url pdf-path)))

;; **** replacement for fake id
;; :PROPERTIES:
;; :ID:       4f0436c4-bc37-49b0-a8a3-894e212d4d13
;; :END:

(defun exwm-input::fake-key-to-id (event id)
  "Fake a key event equivalent to Emacs event EVENT and send it
 to program with x window ID."
  (let* ((keysym (xcb:keysyms:event->keysym exwm--connection event))
         keycode)
    (when (= 0 (car keysym))
      (user-error "[EXWM] Invalid key: %s" (single-key-description event)))
    (setq keycode (xcb:keysyms:keysym->keycode exwm--connection
					                           (car keysym)))
    (when (/= 0 keycode)
      (dolist (class '(xcb:KeyPress xcb:KeyRelease))
        (xcb:+request exwm--connection
	        (make-instance
	         'xcb:SendEvent
	         :propagate 0 :destination id
	         :event-mask xcb:EventMask:NoEvent
	         :event
	         (xcb:marshal
	          (make-instance
	           class
	           :detail keycode :time xcb:Time:CurrentTime
	           :root exwm--root :event id :child 0 :root-x 0 :root-y 0
	           :event-x 0 :event-y 0 :state (cdr keysym) :same-screen 0)
	          exwm--connection)))))
    (xcb:flush exwm--connection)))

;; **** url from firefox
;; :PROPERTIES:
;; :ID:       f407cc8c-0bb9-47fe-adeb-4e9d27b5c5b7
;; :END:

;; Emacs simulates a keypress to firefox--specifically the keypresses to select the
;; current url and to add it to the kill ring.

(defun exwm::firefox-url ()
  "Save the current firefox url to kill ring."
  ;; We get the xwindow id of the buffer named Firefox
  (let ((fid (exwm--buffer->id (current-buffer))))
    ;; Send c-l to select url
    (exwm-input::fake-key-to-id 'C-l fid)
    ;; We sleep to avoid race conditions.
    (sleep-for 0 300)
    ;; Copy url to kill ring (note: this is not affected by simulation keys)
    (exwm-input::fake-key-to-id 'C-c fid)
    (sleep-for 0 300)
    ;; try to set the state back
    (exwm-input::fake-key-to-id 'escape fid)
    (current-kill 0)))

;; **** url from qutebrowser
;; :PROPERTIES:
;; :ID:       822cbb61-60b4-445e-9756-4bf797500375
;; :END:

(defun exwm::qutebrowser-url ()
  (interactive)
  (let ((fid (exwm--buffer->id (current-buffer))))
    (sleep-for 0 300)
    ;; if in insert state exit it.
    (exwm-input::fake-key-to-id 'escape fid)
    (sleep-for 0 300)
    (exwm-input::fake-key-to-id 'y fid)
    (sleep-for 0 300)
    (exwm-input::fake-key-to-id 'y fid)
    (sleep-for 0 300)
    (aprog1 (current-kill 0)
      (void-log "Copied %S to the kill ring." it))))

;; *** appropriate name for exwm buffers
;; :PROPERTIES:
;; :ID: b9712cdc-2cf9-482f-8f62-b2e4f56b9c97
;; :END:

(defhook! rename-buffer-to-title (exwm-update-title-hook)
  "Rename buffer to title."
  (exwm-workspace-rename-buffer exwm-title))

;; *** to start in char mode
;; :PROPERTIES:
;; :ID: 790c7f6e-6f66-4074-b51a-56b491bcde99
;; :END:

;; =EXWM= has two modes, =line-mode= and =char-mode=. It's best for Emacs and Next to
;; start with =char-mode= because they both have keys that are important for their
;; use (like =M-x=) which conflict with Emacs (the instance that's managing the
;; windows).

;; **** list of applications
;; :PROPERTIES:
;; :ID:       d1bf0601-a995-48f7-ab80-86755ba9269a
;; :END:

(defvar exwm:char-mode-apps (list "emacs" "next" "nyxt" "qutebrowser")
  "List of applications to exwm should start in char-mode.")

;; **** to start in char mode
;; :PROPERTIES:
;; :ID: 790c7f6e-6f66-4074-b51a-56b491bcde99
;; :END:

(defhook! start-in-char-mode (exwm-manage-finish-hook)
  "Start a program in char-mode if it's in `exwm:char-mode-apps'."
  (when (--any-p (string-prefix-p it exwm-instance-name) exwm:char-mode-apps)
    (exwm-input-release-keyboard (exwm--buffer->id (window-buffer)))))

;; *** exwm-edit
;; :PROPERTIES:
;; :ID: 1a167827-b791-4a69-a90e-c2d30bd83abb
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "agzam/exwm-edit"
;; :PACKAGE:  "exwm-edit"
;; :LOCAL-REPO: "exwm-edit"
;; :COMMIT:   "2fd9426922c8394ec8d21c50dcc20b7d03af21e4"
;; :END:

;; The dream is to do all text editing in Emacs. This package is a big step towards
;; achieving that dream. =exwm-edit= allows the user to edit text fields in
;; external packages with an emacs buffer. It acts a lot like =org-edit-src-code=:
;; it copies any text in the text field to a buffer, you edit the buffer, then
;; press a binding to insert the buffer text into the text field. It goes without
;; saying that when the text is in an emacs buffer, you can use the full-force of
;; Emacs's text editing capabilities on it.

(after! exwm (require 'exwm-edit))

;; *** exwm-firefox
;; :PROPERTIES:
;; :ID:       333e6bd1-4371-4563-a0d1-a12b42c67836
;; :END:

;; **** setup
;; :PROPERTIES:
;; :ID:       027e4e46-bb81-4161-8a46-7c6576ec3435
;; :END:

(void-add-hook 'exwm-manage-finish-hook #'exwm-firefox-evil-activate-if-firefox)
(void-autoload 'exwm-firefox 'exwm-firefox-evil-activate-if-firefox)

;; **** add appropriate prefix keys
;; :PROPERTIES:
;; :ID:       2b37c2a6-83ea-458d-9749-781903b3b82d
;; :END:

(dolist (k `(escape))
  (cl-pushnew k exwm-input-prefix-keys))

;; ** buffer-expose
;; :PROPERTIES:
;; :ID:       07b13cf0-49ca-4463-9d5b-9eb032585e96
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacs-straight/buffer-expose"
;; :FILES:    ("*" (:exclude ".git"))
;; :PACKAGE:  "buffer-expose"
;; :LOCAL-REPO: "buffer-expose"
;; :COMMIT:   "3f8e0c52d85397e59b6081c8c3e71a55d610c56d"
;; :END:

;; *** TODO commands
;; :PROPERTIES:
;; :ID:       6ea230c6-d60e-4cc1-989b-cb9b34198311
;; :END:

(alet (list #'buffer-expose #'buffer-expose-no-stars #'buffer-expose-major-mode
            #'buffer-expose-dired-buffers #'buffer-expose-stars
            #'buffer-expose-current-mode)
  (void-autoload 'buffer-expose it))

;; *** setq
;; :PROPERTIES:
;; :ID:       b30c439e-a2e0-43c4-a1ef-08d68d579c21
;; :END:

(setq buffer-expose-show-current-buffer t)
(setq buffer-expose-rescale-factor      0.5)
(setq buffer-expose-highlight-selected  nil)
(setq buffer-expose-max-num-windows     8)
(setq buffer-expose-auto-init-aw        t)
(setq buffer-expose-hide-modelines      nil)
(setq buffer-expose-key-hint            "")

;; *** bindings
;; :PROPERTIES:
;; :ID:       c73d075a-bbf2-4548-baee-9963f4acd725
;; :END:

(general-def buffer-expose-grid-map
  "l" buffer-expose-next-window
  "h" buffer-expose-prev-window
  "L" buffer-expose-next-page
  "H" buffer-expose-prev-page
  "j" buffer-expose-down-window
  "k" buffer-expose-up-window)

;; * Completion
;; :PROPERTIES:
;; :ID: 056384d1-a95a-4dcb-bc9d-ffe95bbb52a8
;; :END:

;; Completion has certainly become an integral part of any efficient workflow. One
;; commonality among things like searching emails, code-completing a word, surfing
;; the web is that in one way or another all of these things involve the suggestion
;; of likely candidates from a population that is too time consuming to look
;; through on our own. It's not much different in Emacs. We're constantly sifting
;; though files, buffers, commands, words--all to try to get through to the subset
;; of things that we actually want at this moment.

;; ** snippets
;; :PROPERTIES:
;; :ID:       02dd54d0-f545-447e-89cf-c0cfcd941c76
;; :END:

;; *** autoyasnippet
;; :PROPERTIES:
;; :ID: 851aaa47-5220-43a2-9861-b36d4cb9b803
;; :END:

(void-add-advice 'aya-expand :after #'evil-insert-state)
(setq aya-persist-snippets-dir (concat VOID-LOCAL-DIR "auto-snippets/"))

;; *** yasnippet
;; :PROPERTIES:
;; :ID:       22b3c8d9-5560-4e47-b3d9-71a82e4b9fc7
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("yasnippet.el" "snippets" "yasnippet-pkg.el")
;; :HOST:     github
;; :REPO:     "joaotavora/yasnippet"
;; :PACKAGE:  "yasnippet"
;; :LOCAL-REPO: "yasnippet"
;; :COMMIT:   "5cbdbf0d2015540c59ed8ee0fcf4788effdf75b6"
;; :END:

;; **** init
;; :PROPERTIES:
;; :ID:       9ccba3e4-072e-4838-9461-b962740f02c6
;; :END:

(void-add-hook 'prog-mode-hook #'yas-minor-mode-on)
(void-autoload 'yasnippet #'yas-minor-mode-on)
(setq yas-snippet-dirs (list (concat VOID-DATA-DIR "snippets/")))

;; **** settings
;; :PROPERTIES:
;; :ID:       eeebeb45-18a3-41ab-a540-3fc67e272b89
;; :END:

(setq yas-verbosity (if void-debug-p 3 0))
(setq yas-indent-line 'auto)
(setq yas-prompt-functions '(yas-completing-prompt yas-ido-prompt))
(setq yas-use-menu nil)
(setq yas-triggers-in-field t)

;; **** ensure each yasnippet directory
;; :PROPERTIES:
;; :ID:       0dae1585-e454-4740-b8c6-bad7bf1e4bb0
;; :END:

(defhook! create-yasnippet-dirs-maybe (yas-minor-mode-hook)
  (--each yas-snippet-dirs (mkdir it t)))

;; **** delete yasnippet prompt
;; :PROPERTIES:
;; :ID:       c66234de-3bd7-48bd-a518-538002fbaa6c
;; :END:

(delq #'yas-dropdown-prompt yas-prompt-functions)

;; **** dont interfere with yasnippet
;; :PROPERTIES:
;; :ID:       72229078-6419-4bc2-a2b5-44f218a1ec71
;; :END:

(after! (smartparens yasnippet)
  (void-add-advice #'yas-expand :before #'sp-remove-active-pair-overlay))

;; *** yasnippet-snippets
;; :PROPERTIES:
;; :ID:       006e4191-a61f-4886-86db-024180a5fb1c
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("*.el" "snippets" ".nosearch" "yasnippet-snippets-pkg.el")
;; :HOST:     github
;; :REPO:     "AndreaCrotti/yasnippet-snippets"
;; :PACKAGE:  "yasnippet-snippets"
;; :LOCAL-REPO: "yasnippet-snippets"
;; :COMMIT:   "7716da98b773f3e25a8a1b1949e24b4f3e855d17"
;; :END:

(after! yasnippet
  (awhen (-first (-partial #'s-contains-p "yasnippet-snippets") load-path)
    (push it yas-snippet-dirs)))

;; ** selectrum
;; :PROPERTIES:
;; :ID:       294a9fde-e76f-40ce-9552-dd5801318717
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "raxod502/selectrum"
;; :PACKAGE:  "selectrum"
;; :LOCAL-REPO: "selectrum"
;; :COMMIT:   "1ef55328dfba7abc653f7de695c34e2fbbef8ec9"
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID:       6e670980-7794-4505-a285-184416a5b377
;; :END:

;; **** hook
;; :PROPERTIES:
;; :ID:       c12c2919-adf7-44ad-8175-b92bb8905f74
;; :END:

(void-add-hook 'emacs-startup-hook #'selectrum-mode)

;; **** settings
;; :PROPERTIES:
;; :ID:       29cf793e-2b4c-4e33-822c-cc8b9ab2f713
;; :END:

(setq selectrum-fix-minibuffer-height t)
(setq selectrum-should-sort-p t)
(setq selectrum-count-style nil)
(setq selectrum-num-candidates-displayed 15)

;; *** ensure certain functions dont sort
;; :PROPERTIES:
;; :ID:       1e39a4d2-8d4a-4413-a86e-3f92547cff14
;; :END:

(after! selectrum
  (alet '(list #'void/goto-line #'void/set-font #'void/switch-buffer)
    (void-add-advice it :around #'selectrum::dont-sort-with-selectrum-advice)))

(defun selectrum::dont-sort-with-selectrum-advice (orig-fn &rest args)
  (if (bound-and-true-p selectrum-mode)
      (let (selectrum-should-sort-p) (apply orig-fn args))
    (apply orig-fn args)))

;; *** prescient
;; :PROPERTIES:
;; :ID:       4445c814-9899-4d54-affe-0cee38642690
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("prescient.el" "prescient-pkg.el")
;; :HOST:     github
;; :REPO:     "raxod502/prescient.el"
;; :PACKAGE:  "prescient"
;; :LOCAL-REPO: "prescient.el"
;; :COMMIT:   "41443e1c9f794b569dafdad4c0b64a608df64b99"
;; :END:

;; **** prescient
;; :PROPERTIES:
;; :ID:       e8c77d62-9c28-4193-9c60-f1148b55f96e
;; :END:

(void-add-hook 'selectrum-mode-hook #'prescient-persist-mode)

(setq prescient-save-file (concat VOID-DATA-DIR "prescient-save-file"))

;; *** selectrum-prescient
;; :PROPERTIES:
;; :ID:       70668ed8-9c83-42d2-8dce-d8f7de923569
;; :flavor:   melpa
;; :files:    ("selectrum-prescient.el" "selectrum-prescient-pkg.el")
;; :package:  "selectrum-prescient"
;; :local-repo: "prescient.el"
;; :type:     git
;; :repo:     "raxod502/prescient.el"
;; :host:     github
;; :COMMIT:   "41443e1c9f794b569dafdad4c0b64a608df64b99"
;; :END:

;; **** selectrum prescient
;; :PROPERTIES:
;; :ID:       5215a4ad-67cd-4c02-ac79-e4ace589c253
;; :END:

(void-add-hook 'selectrum-mode-hook #'selectrum-prescient-mode)

(setq selectrum-preprocess-candidates-function #'selectrum-prescient--preprocess)

;; *** orderless
;; :PROPERTIES:
;; :ID:       2278ca33-dbf2-45a7-bba7-8c73942b08be
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "oantolin/orderless"
;; :PACKAGE:  "orderless"
;; :LOCAL-REPO: "orderless"
;; :COMMIT:   "e56eeef6e11909ccd62aa7250867dce803706d2c"
;; :END:

;; **** init
;; :PROPERTIES:
;; :ID:       9702810e-2013-4c41-ba12-0b55de6ceb38
;; :END:

(alet (list #'orderless-filter #'orderless-highlight-matches)
  (void-autoload 'orderless it))

;; **** use orderless filters
;; :PROPERTIES:
;; :ID:       02b92dca-f879-43ad-89a5-fcf8902ff0b6
;; :END:

(after! selectrum
  (setq selectrum-refine-candidates-function #'orderless-filter)
  (setq selectrum-highlight-candidates-function #'orderless-highlight-matches)))

;; **** stop selectrum filtering and highlight
;; :PROPERTIES:
;; :ID:       a6720cdc-9d51-463b-9ffe-f9341c6bd967
;; :END:

(defadvice! orderless:inhibit-filtering-and-highlighting (:around selectrum-prescient-mode)
  "Don't let `selectrum-prescient' filter or highlight.
Orderless will do this."
  (let ((selectrum-refine-candidates-function selectrum-refine-candidates-function)
        (selectrum-highlight-candidates-function selectrum-highlight-candidates-function))
    (apply <orig-fn> <args>)))

;; ** company
;; :PROPERTIES:
;; :ID: 436d68f7-09f1-470a-a730-fd79d9c183ee
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "company-mode/company-mode"
;; :PACKAGE:  "company"
;; :LOCAL-REPO: "company-mode"
;; :COMMIT:   "dd925936f7c0bf00319c81e8caea1b3db63bb8b5"
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID:       0f670007-165b-4a2d-ac35-97eab9ada739
;; :END:

;; **** hooks
;; :PROPERTIES:
;; :ID:       5e5393d9-9f58-45be-9ecc-1bc9f0316379
;; :END:

(void-add-hook 'prog-mode-hook #'company-mode)

;; **** settings
;; :PROPERTIES:
;; :ID:       5b7962d9-0a43-4efc-b8ad-3f638f6abff3
;; :END:

(setq company-frontends '(company-pseudo-tooltip-frontend))
(setq company-tooltip-align-annotations t)
(setq company-show-numbers t)
(setq company-dabbrev-downcase nil)
(setq company-idle-delay 0.15)
(setq company-tooltip-limit 14)
(setq company-minimum-prefix-length 1)
(setq company-minimum-prefix-length 1)
(setq company-require-match 'never)

;; **** bindings
;; :PROPERTIES:
;; :ID:       ba170d95-7d86-4827-af6b-dc5fd4c1b7e5
;; :END:

(general-def company-active-map
  [tab]     #'company-select-next
  [backtab] #'company-select-previous
  "C-k"     #'company-select-previous
  "C-j"     #'company-select-next)

;; *** backends
;; :PROPERTIES:
;; :ID: 976f3260-992a-44ee-af91-5eff0b398b20
;; :END:

;; [[helpvar:company-backends][company-backends]] is what you have to keep in mind when you're using
;; company. According to its documentation, =company-backends= contain
;; individual backends or groups of backends. This is important so it's
;; worth quoting here:

;; **** backends-alist
;; :PROPERTIES:
;; :ID: 1ca376a2-e92f-4b77-8a91-3c2d00c0c5b7
;; :END:

(defvar company:backend-alist
  '((text-mode :derived (company-dabbrev company-yasnippet company-ispell))
    (prog-mode :derived ((:separate company-capf company-yasnippet)))
    (conf-mode :derived (company-capf company-dabbrev-code company-yasnippet))
    (org-mode  :only (company-yasnippet)))
  "An alist matching modes to company backends.")

;; **** initialize a backend
;; :PROPERTIES:
;; :ID: 24288386-3600-4a23-90d1-d38f9862aca0
;; :END:

(defhook! setup-backends (after-change-major-mode-hook :local t)
  "Set `company-backends' for the current buffer."
  (when (and (bound-and-true-p company-mode)
             (not (eq major-mode 'fundamental-mode)))
    (set (make-local-variable 'company-backends) (company--backends+))))

;; **** get backends
;; :PROPERTIES:
;; :ID: 985f9898-2608-4aa2-8ee9-98a178a4d5e5
;; :END:

(defun company--backends+ ()
  "Compute company backends."
  (or
   (-when-let (((mode type backends) (assoc major-mode company:backend-alist)))
     (when (eq type :only) backends))
   (-mapcat (-lambda ((mode type backends))
              (when (or (and (eq type :derived) (derived-mode-p mode))
                        (and (eq type :exact)
                             (or (eq major-mode mode)
                                 (and (boundp mode) (symbol-value mode)))))
                backends))
            company:backend-alist)))

;; **** local hook
;; :PROPERTIES:
;; :ID: 49a1e8e6-c557-4a9c-9a3a-a1aa60f90924
;; :END:

(after! company
  (put 'company:init-backends-h 'permanent-local-hook t))

;; *** close company on escape
;; :PROPERTIES:
;; :ID: 750cc608-865e-4f69-a7b2-826fc66a7b71
;; :END:

(defhook! close-tooltip (void-escape-hook)
  "Close company tooltip."
  (when (and (boundp 'company-mode)
             (eq company-mode t))
    (company-abort)
    t))

;; *** company-prescient
;; :PROPERTIES:
;; :ID: df21548a-c262-4802-8e76-71a3135789cb
;; :FLAVOR:   melpa
;; :FILES:    ("company-prescient.el" "company-prescient-pkg.el")
;; :PACKAGE:  "company-prescient"
;; :LOCAL-REPO: "prescient.el"
;; :TYPE:     git
;; :REPO:     "raxod502/prescient.el"
;; :HOST:     github
;; :COMMIT:   "41443e1c9f794b569dafdad4c0b64a608df64b99"
;; :END:

;; [[https://github.com/raxod502/prescient.el][company-prescient]] is the same as =prescient= but for =company= instead of =ivy=.

(void-add-hook 'company-mode-hook #'company-prescient-mode)

;; * Email
;; :PROPERTIES:
;; :ID: b31fc41c-135d-45d9-9c05-5889d21d1cd4
;; :END:

;; In today's world communication is largely done via emails. Whether at work or at
;; school it's common to receive emails every day. In fact, you hear of people that
;; have 20,000+ emails in a particular account. Unsurprisingly, when we're getting
;; so many emails, it's easy to become overwhelmed. Fortunately, there are numerous
;; ways to read and send emails in Emacs.

;; ** built-in settings
;; :PROPERTIES:
;; :ID:       f2f187ab-caef-4fa6-85e7-628f76e3da41
;; :END:

;; *** sendmail
;; :PROPERTIES:
;; :ID:       48c3332f-975d-4f22-94a8-4ccd394ca82a
;; :END:

(use-feature! sendmail
  :setq
  (send-mail-function . #'sendmail-send-it)
  (sendmail-program . (executable-find "msmtp"))
  (mail-specify-envelope-from . t))

;; *** smtpmail
;; :PROPERTIES:
;; :ID: 4dc1e0a6-5441-4b3e-8b75-ed3626a59154
;; :END:

(use-feature! smtpmail
  :disabled t
  :setq
  (smtp-default-mail-server . "mail.example.com")
  (smtp-smtp-server . "mail.example.com")
  (smtpmail-smtp-service . 587)
  (smtpmail-debug-info . t))

;; *** message
;; :PROPERTIES:
;; :ID:       4cf38804-18d6-470c-a9c3-e3327f2bebf9
;; :END:

(use-feature! message
  :setq
  (message-signature . user-full-name)
  (message-sendmail-envelope-from . 'header)
  (message-send-mail-function . #'sendmail-send-it)
  (message-kill-buffer-on-exit . t))

;; ** mu4e
;; :PROPERTIES:
;; :ID: 1ec73e33-5b94-4199-976d-1d72f8fb5a8e
;; :END:

;; The most popular emacs mail client is =mu4e=. And, there is good reason why. =mu4e=
;; has many juicy features. Overall, =mu4e= is definitely a great mail client.
;; However, it's not all roses and rainbows; it does have a few annoying quicks.
;; One is that unlike virtually all other emacs packages it does not come decoupled
;; from =mu=. Another is that it is hard to set up multiple accounts properly despite
;; it's [[explicit support]] for multiple accounts. =mu4e= comes bundled with =mu=. A
;; significant advantage of using it is it's the most popular option and,
;; therefore, has the most support (in the form of setup blogs and packages).

;; *** settings
;; :PROPERTIES:
;; :ID:       11a37383-0316-49fa-900e-c06f830c0e3f
;; :END:

(setq mu4e-completing-read-function #'completing-read)
(setq mu4e-view-show-addresses t)
(setq mu4e-view-show-images t)
(setq mu4e-view-image-max-width 800)
(setq mu4e-compose-signature-auto-include t)
(setq mu4e-compose-format-flowed t)
(setq mu4e-get-mail-command "mbsync -a")
(setq mu4e-index-cleanup t)
(setq mu4e-index-lazy-check nil)
(setq mu4e-update-interval 180)
(setq mu4e-headers-auto-update t)
(setq mu4e-context-policy 'pick-first)
(setq mu4e-compose-context-policy 'ask-if-none)
(setq mu4e-confirm-quit nil)

;; *** mu4e
;; :PROPERTIES:
;; :ID: 565eff90-8626-4ec8-a576-4ff3dfb307ae
;; :END:

(setq mu4e-header-fields '((:human-date . 12)
                           (:flags . 4)
                           (:from . 25)
                           (:subject)))

(setq mu4e-html2text-command
      (if (executable-find "w3m") "w3m -dump -T text/html" #'mu4e-shr2text))

;; (use-package! mu4e
;;   :straight nil
;;   :system-ensure mu
;;   :load-path "/usr/share/emacs/site-lisp/mu4e/"
;;   :commands mu4e
;;   :setq
;;   )

;; *** TODO setup mu4e
;; :PROPERTIES:
;; :ID:       8ed2fe81-eda9-4343-a6e1-0a6a725866a4
;; :END:

(defun mu4e/init ()
  "Initialize mu4e."
  (interactive)
  (require 'password-store)
  (let ((email-dirs (--map (concat VOID-EMAIL-DIR it) (pass:email-list))))
    (when (or (not (-all-p #'f-exists-p email-dirs))
              (-some-p #'f-empty-p email-dirs))
      (message "creating directories that don't exist.")
      (--each email-dirs (mkdir it t))
      (shell-command (format "mu init -m %s" VOID-EMAIL-DIR))
      (message "Updating mail...")
      (mu4e-update-mail-and-index t))))

;; *** mu4e headers
;; :PROPERTIES:
;; :ID:       8bc93633-f3a0-494d-ae61-c05f6490cd87
;; :END:

(setq mu4e-use-fancy-chars t)
(after! (mu4e all-the-icons)
  (setq mu4e-headers-draft-mark     (cons "D" (all-the-icons-faicon "pencil")))
  (setq mu4e-headers-flagged-mark   (cons "F" (all-the-icons-faicon "flag")))
  (setq mu4e-headers-new-mark       (cons "N" (all-the-icons-material "fiber_new")))
  (setq mu4e-headers-passed-mark    (cons "P" (all-the-icons-faicon "arrow-right")))
  (setq mu4e-headers-seen-mark      (cons "S" (all-the-icons-faicon "eye")))
  (setq mu4e-headers-attach-mark    (cons "a" (all-the-icons-material "attach_file")))
  (setq mu4e-headers-replied-mark   (cons "R" (all-the-icons-faicon "reply")))
  (setq mu4e-headers-unread-mark    (cons "u" (all-the-icons-faicon "eye-slash")))
  (setq mu4e-headers-encrypted-mark (cons "x" (all-the-icons-octicon "lock")))
  (setq mu4e-headers-signed-mark    (cons "s" (all-the-icons-faicon "certificate")))
  (setq mu4e-headers-trash-mark     (cons "T" (all-the-icons-faicon "trash"))))

;; *** org-mu4e
;; :PROPERTIES:
;; :ID:       eaa1577b-bcb9-4f6e-9927-8c6d8042dda2
;; :END:

;; Mu4e's org integration lets you write emails in org mode and convert it to html
;; before sending--very interesting indeed. I have yet to explore this feature but
;; it is definitely on my list of things to try out.

;; **** init
;; :PROPERTIES:
;; :ID:       47c8d5d8-575f-4b73-9247-38f32cb706fd
;; :END:

(void-add-hook 'mu4e-compose-mode-hook #'org-mu4e-compose-org-mode)

(setq org-mu4e-link-query-in-headers-mode nil)
(setq org-mu4e-convert-to-html t)

;; **** hook
;; :PROPERTIES:
;; :ID:       fcdbaa17-20c6-4322-baed-27df5a0ad9a2
;; :END:

;; Only render to html once. If the first send fails for whatever reason,
;; org-mu4e would do so each time you try again.
(defhook! org-mu4e-render-html-only-once (message-send-hook)
  (setq-local org-mu4e-convert-to-html nil))

;; *** multiple accounts
;; :PROPERTIES:
;; :ID: ad6de3a4-674c-490f-841e-19b8f891cd65
;; :END:

;; Mu4e certainly gave me some trouble setting up multiple accounts despite [its
;; attempt] to make this easy. I have one directory =~/.mail= where which stores all
;; my mail. The subdirectories of =~/.mail= correspond to my individual email
;; accounts. Until I set multiple accounts correctly it keeps prompting me to
;; create folders (such as =sent/=) in the =~/.mail= directory. I think part of the
;; reason I spent so much time setting this up is because.

;; **** return the list of emails with credentials
;; :PROPERTIES:
;; :ID:       3f7b1728-b855-447f-9f15-43bd79a94c14
;; :END:

(defun pass:email-list ()
  "Return a list of emails."
  (->> (password-store-list)
       (--map (elt (s-match "email/\\(.*\\)" it) 1))
       (-non-nil)))

;; **** return the stuff as a plist
;; :PROPERTIES:
;; :ID:       8129ca16-8641-4f2f-a4b6-03477d5b78f3
;; :END:

(defun pass:email-account-plist (email)
  "Return a plist of the relevant values of an email."
  (shut-up!
    (->> (cdr (password-store-parse-entry email))
         (mapcar #'car)
         (--mapcat (list (intern it)
                         (password-store-get-field (concat "email/" email) it))))))

;; **** mu4e folder name alist
;; :PROPERTIES:
;; :ID:       2ef07842-e321-4fff-ae73-f19c41d263a4
;; :END:

;; Mu4e keeps prompting you for the sent, trash, and drafts directory if you do not
;; assign the corresponding mu4e variables. The way certain email servers name
;; their directories varies. For example, outlook names its sent directory as =Sent
;; Items=.

(defun mu4e:guess-folder (base-dir possible-name &rest other-possible-names)
  "Return the first file in BASE-DIR that matches POSSIBLE-NAME or any POSSIBLE-NAMES.
If there is no match, return POSSIBLE-NAME."
  (alet (or (--first (-some-p (-cut s-contains-p <> it t)
                              (cons possible-name other-possible-names))
                     (cddr (directory-files base-dir)))
            possible-name)
    (format "/%s/%s" (f-filename base-dir) it)))

;; **** set up contexts for single account
;; :PROPERTIES:
;; :ID:       66d460d7-9647-4c29-8348-eb7b3d571630
;; :END:

(defun mu4e::account-context (email)
  "Return an mu4e account context for specified EMAIL."
  (let* ((base-dir (concat VOID-EMAIL-DIR email "/"))
         (name (cl-second (s-match ".*@\\([^.]*\\)" email)))
         (account (pass:email-account-plist email))
         (out-host (plist-get 'out-host account))
         (out-port (plist-get 'out-port account)))
    (alet `((mu4e-sent-folder      . ,(mu4e:guess-folder base-dir "sent"))
            (mu4e-drafts-folder    . ,(mu4e:guess-folder base-dir "draft"))
            (mu4e-trash-folder     . ,(mu4e:guess-folder base-dir "trash" "delete" "junk"))
            (user-email-address    . ,email)
            (smtpmail-smtp-server  . ,out-host)
            (smtpmail-smtp-user    . ,base-dir)
            (smtpmail-smtp-service . ,out-port))
      (make-mu4e-context :name name :vars it))))

;; **** multiple contexts
;; :PROPERTIES:
;; :ID: e56b64ac-ed36-4689-b8f4-8711c1f4f79f
;; :END:

(defadvice! setup-contexts (:before mu4e)
  "Initiaize context for each email account."
  (require 'password-store)
  (--each (-map #'mu4e::account-context (pass:email-list))
    (cl-pushnew it mu4e-contexts)))

;; *** truncate lines in messages
;; :PROPERTIES:
;; :ID: e6addd49-6aa4-4b9e-8e50-4f0ea43aedb7
;; :END:

(defhook! wrap-text-in-message (mu4e-view-mode-hook)
  (setq-local truncate-lines nil))

;; * Web Browsing
;; :PROPERTIES:
;; :ID: f0960e47-5dbb-4cca-a17a-f8eb0da445d3
;; :END:

;; In current times we are fortunate enough to have a wealth of information
;; available to us only a web search away.

;; ** engine-mode
;; :PROPERTIES:
;; :ID:       d701f44f-85eb-4849-8f2d-15423eb41a02
;; :HOST:     github
;; :BRANCH:   "main"
;; :REPO:     "hrs/engine-mode"
;; :COMMIT:   "e0910f141f2d37c28936c51c3c8bb8a9ca0c01d1"
;; :TYPE:     git
;; :PACKAGE:  "engine-mode"
;; :LOCAL-REPO: "engine-mode"
;; :END:

;; *** different engines
;; :PROPERTIES:
;; :ID:       2f5c974e-b26e-4080-a9b3-acd6406ab118
;; :END:

;; This package essentially automates the creation of an interactive web searching
;; functions. Engine mode seems to only be useful for binding keys.

(defengine amazon
  "http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=%s")
(defengine duckduckgo
  "https://duckduckgo.com/?q=%s")
(defengine qwant
  "https://www.qwant.com/?q=%s")
(defengine wikipedia
  "http://www.wikipedia.org/search-redirect.php?language=en&go=Go&search=%s")

;; ** w3m
;; :PROPERTIES:
;; :ID: e5e13423-bc70-49b0-969e-94897c798d54
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "icons" (:exclude "octet.el" "mew-w3m.el" "w3m-xmas.el") "w3m-pkg.el")
;; :HOST:     github
;; :REPO:     "emacs-w3m/emacs-w3m"
;; :PACKAGE:  "w3m"
;; :LOCAL-REPO: "emacs-w3m"
;; :COMMIT:   "a4edf91ba14d39b6a1a2724ad275e941b1f00235"
;; :END:

;; [[http://w3m.sourceforge.net/][w3m]] is a text-based web browser. There are many other text-based browsers out
;; there, but =w3m= has the benefit of having comprehensive [[https://github.com/emacs-w3m/emacs-w3m][emacs interface]]. Why
;; use this when you can use the GUI browser? Well, using the Emacs interface I can
;; view an Emacs webpage as plain text, which means I can perform searches on it
;; with [[https://github.com/abo-abo/swiper.git][swiper]], or any other Emacs operation on it. Another advantage is that
;; because the w3m interface's backend is a terminal application, it will (I'm
;; guessing; no benchmarks made) typically be faster than browsers at rendering
;; plain text webpages. Of course, the main limitation is that w3m will typically
;; only display text based web pages well--not ones with lots of interactive
;; javascript code.

;; * Multimedia
;; :PROPERTIES:
;; :ID: 20a915a0-8525-413c-bd68-f1d5c14ce3da
;; :END:

;; I'm using "multimedia" here as an umbrella term for non-text sources of
;; information such as music, videos, images, and gifs.

;; ** ytel
;; :PROPERTIES:
;; :ID:       6bf0b85c-212d-406d-b4b5-7720ccc274ba
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "gRastello/ytel"
;; :PACKAGE:  "ytel"
;; :LOCAL-REPO: "ytel"
;; :COMMIT:   "d80c7964ec66589d5580fc13773e94f1834ab76f"
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID:       167bc712-5552-4cfe-83ce-d0bb9927fa6a
;; :END:

;; =ytel= is a YouTube search front-end. It is designed to let the user collect
;; YouTube search results into a buffer and manipulate them with emacs lisp.

(void-autoload 'ytel #'ytel)

(setq ytel-invidious-api-url "https://invidious.snopyta.org")

(void-system-ensure-package 'ytel '(youtube-dl curl))

;; *** watch video
;; :PROPERTIES:
;; :ID:       547c6d1d-c8a5-42b3-8000-029228923304
;; :END:

(defun ytel/watch ()
  "Stream video at point in mpv."
  (interactive)
  (let* ((video (ytel-get-current-video))
     	 (id    (ytel-video-id video)))
    (start-process "ytel mpv" nil
		           "mpv"
		           (concat "https://www.youtube.com/watch?v=" id))
	"--ytdl-format=bestvideo[height<=?720]+bestaudio/best")
  (message "Starting streaming..."))

;; *** download music
;; :PROPERTIES:
;; :ID:       7c28f457-3a63-45a7-87bc-dc5232a5a5cd
;; :END:

(defun ytel/download-music ()
  "Download youtube video from `ytel' interface."
  (interactive)
  (let* ((video (ytel-get-current-video))
         (title (ytel-video-title video))
         (id (ytel-video-id video))
         (dir VOID-MUSIC-DIR)
         (url (format "https://www.youtube.com/watch?v=%s" id)))
    (async-shell-command (format "cd %s && youtube-dl -f bestaudio %s" dir url))
    (message "Downloading music...")))

;; ** emms
;; :PROPERTIES:
;; :ID: 5d1abf3e-d0e5-4074-8d06-2b6eba47c6e4
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("*.el" "lisp/*.el" "doc/emms.texinfo" "emms-pkg.el")
;; :REPO:     "https://git.savannah.gnu.org/git/emms.git"
;; :PACKAGE:  "emms"
;; :LOCAL-REPO: "emms"
;; :COMMIT:   "94019bb34c56341e66b14c41ff706273e039f525"
;; :END:

;; [[https://www.gnu.org/software/emms/][emms]] is a very complete music player.

;; *** ensure mpv is available
;; :PROPERTIES:
;; :ID:       259e8bfb-a896-4e8b-8c3b-e120d4f141b4
;; :END:

(void-system-ensure)

;; *** commands
;; :PROPERTIES:
;; :ID:       a59fba5b-8687-4416-8ce8-a05dec352e0c
;; :END:

(void-autoload)

;; *** settings
;; :PROPERTIES:
;; :ID:       3861c03d-b08e-463b-a28e-e88c191993fc
;; :END:

(setq emms-directory (concat VOID-DATA-DIR "emms/"))
(setq emms-seek-seconds 5)
(setq emms-player-list '(emms-player-mpv))
(setq emms-source-file-default-directory "~/Multimedia/music")
(setq emms-source-file-directory-tree-function 'emms-source-file-directory-tree-find)
(setq emms-playlist-buffer-name "*EMMS-PLAYLIST*")
(setq mpc-host "127.0.0.1:6600")

;; *** emms
;; :PROPERTIES:
;; :ID: 5d28b703-a87f-47ca-b320-785e7589fea6
;; :END:

(void-system-ensure-package 'emms 'mpv)

(void-autoload 'emms (list #'emms-play-directory #'emms-play-file))

(void-load-before-call 'package 'emms-player-mpv)

;; *** quitting
;; :PROPERTIES:
;; :ID: 545e6534-f289-4a89-838a-2a65ac74fe72
;; :END:

(defhook! quit-emms (kill-emacs-hook)
  "Shut down EMMS."
  (when emms-player-playing-p (emms-pause))
  (emms-stop)
  ;; kill any existing mpd processes
  (when (member 'emms-player-mpd emms-player-list)
    (call-process "killall" nil nil nil "mpd")))

;; ** escr
;; :PROPERTIES:
;; :ID: 0038e1ed-ac6a-4529-9ecd-dfa8a44d40c9
;; :host:     github
;; :repo:     "atykhonov/escr"
;; :package:  "escr"
;; :type:     git
;; :local-repo: "escr"
;; :commit:   fc9dcdd98fcd7c9482f31032779fcd9e574016c0
;; :END:

;; Pictures or GIFs of behaviors can relate emacs behaviors in away descriptions
;; cannot. From my experience looking at posts on [[https://emacs.stackexchange.com/][emacs stackexchange]] or
;; [[https://www.reddit.com/r/emacs/][emacs-reddit]] or even other [[https://github.com/caisah/emacs.dz][emacs configs]], screenshots are underutilized (or
;; often not utilized at all).

;; There are three screenshot packages I know of [[https://github.com/emacsmirror/screenshot][screenshot]], [[https://github.com/dakra/scrot.el][scrot]] and [[https://github.com/atykhonov/escr][escr]]. But
;; they all have their downsides. Screenshot's main command, =screenshot=, assumes
;; that you want. =escr= doesn't provide prompt you for the filename or provide any
;; option that would prompt you for the file name.

;; *** init
;; :PROPERTIES:
;; :ID:       a6a8610e-84b5-471d-8f07-2ad2c67c2998
;; :END:

(alet '(escr-window-screenshot escr-frame-screenshot escr-window-screenshot)
  (void-autoload 'escr it))

;; *** settings
;; :PROPERTIES:
;; :ID:       4ec97ac8-cad6-4536-be21-6ae2ee1655f3
;; :END:

(setq escr-screenshot-quality 10)
(setq escr-screenshot-directory VOID-SCREENSHOT-DIR)

;; *** function for geting screenshot filename
;; :PROPERTIES:
;; :ID:       58405f4f-e891-494e-afc7-a227415ec12b
;; :END:

;; =escr= doesn't prompt for the filename. While this is faster in the shortrun and
;; may be useful for situations when you're short on time, it does mean that I'll
;; need to invest time in looking at the screenshots again so you can properly name
;; them.

(defun escr:get-filename ()
  "Return the filename."
  (alet (format "%s-%s.png"
                (alet (read-string "Image name: ")
                  (if (string-empty-p it) "screenshot" it))
                (format-time-string "%Y-%m-%d-%H-%M-%S.png"))
    (expand-file-name it escr-screenshot-directory)))

;; *** tell =escr--screenshot= to use maim
;; :PROPERTIES:
;; :ID:       3b17fb6e-a15b-4b4a-bdcf-a756961c00d3
;; :END:

;; If we don't use an short idle timer to take the screenshot, we'll end up
;; capturing the prompt for the filename (like in [[][this example]]).

(defadvice! use-miam (:override (x y width height) escr--screenshot)
  (let ((window-id (frame-parameter (selected-frame) 'window-id))
        (crop (format "%sx%s+%s+%s" width height x y))
        (filename (escr:get-filename)))
    (alet `(lambda ()
             (call-process "maim" nil nil nil
                           "--window" ,window-id
                           "--geometry" ,crop
                           "--quality" ,(number-to-string escr-screenshot-quality)
                           ,filename)
             (message "Screenshot Taken!"))
      (run-with-timer 1 nil it))))

;; ** gif-screencast
;; :PROPERTIES:
;; :ID: 28387a67-7037-47ce-97c9-c35d77f7cb22
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     gitlab
;; :REPO:     "Ambrevar/emacs-gif-screencast"
;; :PACKAGE:  "gif-screencast"
;; :LOCAL-REPO: "emacs-gif-screencast"
;; :COMMIT:   "e39786458fb30e2e9683094c75c6c2cef537d9c4"
;; :END:

;; This package allows for the creation of gifs from within emacs.

;; ** keypression
;; :PROPERTIES:
;; :ID: 1943c432-4d47-43a5-ba92-2f17205bbae0
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "chuntaro/emacs-keypression"
;; :PACKAGE:  "keypression"
;; :LOCAL-REPO: "emacs-keypression"
;; :END:

;; [[https://github.com/chuntaro/emacs-keypression][keypression]] is displays keypresses from within Emacs--no external tools
;; necessary! It [[https://raw.githubusercontent.com/wiki/chuntaro/emacs-keypression/images/screencast.gif][looks]] pretty professional!

(setq keypression-frame-justify 'keypression-right-justified)

;; * Text Editing
;; :PROPERTIES:
;; :ID: 42e0838f-f72a-43f3-8db2-a406d2d89adb
;; :END:

;; ** highlight-numbers
;; :PROPERTIES:
;; :ID:       373d8428-5ac4-480c-82b3-44d9013ed97a
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Fanael/highlight-numbers"
;; :PACKAGE:  "highlight-numbers"
;; :LOCAL-REPO: "highlight-numbers"
;; :COMMIT:   "8b4744c7f46c72b1d3d599d4fb75ef8183dee307"
;; :END:

;; What [[https://github.com/Fanael/highlight-numbers][highlight-numbers]] does is pretty self explanatory: it highlights numbers.

;; *** hooks
;; :PROPERTIES:
;; :ID:       203c9d45-7293-4edd-afab-d22acf07b655
;; :END:

(void-add-hook '(prog-mode-hook conf-mode-hook) #'highlight-numbers-mode)

;; *** settings
;; :PROPERTIES:
;; :ID:       d8ec896c-9ac0-4d06-b4dd-1d0195bdee7a
;; :END:

(setq highlight-numbers-generic-regexp "\\_<[[:digit:]]+\\(?:\\.[0-9]*\\)?\\_>")

;; ** hideshow
;; :PROPERTIES:
;; :ID:       85063206-4937-49df-95fa-c42484c0d199
;; :TYPE:     built-in
;; :END:

;; Hiding text can be extremely useful. It is something that's used extensively in
;; Org Mode. The feature responsible for doing this is [[][hide-lines]].

;; *** commands
;; :PROPERTIES:
;; :ID:       f377eed0-45bc-4309-9056-349f71857764
;; :END:

(alet (list #'hs-minor-mode #'hs-toggle-hiding #'hs-already-hidden-p)
  (void-load-before-call 'hideshow it))

;; *** hooks
;; :PROPERTIES:
;; :ID:       97dc0e31-88f7-48d2-9d29-8f2e4af18f2f
;; :END:

(void-add-hook 'prog-mode-hook #'hs-minor-mode)

;; *** settings
;; :PROPERTIES:
;; :ID:       2926b12e-2383-4fab-86e9-c69760ee8652
;; :END:

(setq hs-hide-comments-when-hiding-all nil)

;; ** rainbow-delimiters
;; :PROPERTIES:
;; :ID:       5b58bb1c-5d3c-4f04-b4fb-c55f1588839e
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Fanael/rainbow-delimiters"
;; :PACKAGE:  "rainbow-delimiters"
;; :LOCAL-REPO: "rainbow-delimiters"
;; :COMMIT:   "f43d48a24602be3ec899345a3326ed0247b960c6"
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID: c771a943-593f-4119-8754-9d7e5da4466b
;; :END:

;; [[https://github.com/Fanael/rainbow-delimiters][rainbow-delimiters]] colors parentheses different colors based on level. This is a
;; great idea! It makes it really easy to see which parentheses go together.

(void-add-hook '(prog-mode-hook reb-mode-hook) #'rainbow-delimiters-mode)
(void-autoload 'rainbow-delimiters #'rainbow-delimiters-mode)

(setq rainbow-delimiters-max-face-count 9)

;; ** spacing and indentation
;; :PROPERTIES:
;; :ID: 4f5e0d70-fe6d-4dda-8949-8154464160e1
;; :END:

;; *** aggressive-indent
;; :PROPERTIES:
;; :ID: f1b9a36e-26e4-4305-99ae-cbcf6a90013d
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Malabarba/aggressive-indent-mode"
;; :PACKAGE:  "aggressive-indent"
;; :LOCAL-REPO: "aggressive-indent-mode"
;; :COMMIT:   "b0ec0047aaae071ad1647159613166a253410a63"
;; :END:

;; [[https://github.com/Malabarba/aggressive-indent-mode][aggressive-indent]] indents portions of the text your working on as your typing
;; it. It's pretty smart and very convenient.

(void-add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)

;; *** ws-butler
;; :PROPERTIES:
;; :ID:       caf0335b-923c-4427-af2b-d398af1700f7
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "lewang/ws-butler"
;; :PACKAGE:  "ws-butler"
;; :LOCAL-REPO: "ws-butler"
;; :COMMIT:   "52321b99be69aa1b661da7743c4421a30d8b6bcb"
;; :END:

;; [[https://github.com/lewang/ws-butler][ws-butler]] cleans up whitespace.

;; **** init
;; :PROPERTIES:
;; :ID: 7e0c30ea-a109-4176-a92b-4a1de4922032
;; :END:

(void-add-hook #'prog-mode-hook #'ws-butler-mode)

;; **** exempt modes
;; :PROPERTIES:
;; :ID:       eada4f60-aad8-471f-8f5a-43fed5d32295
;; :END:

(append! ws-butler-global-exempt-modes
  '(special-mode comint-mode term-mode eshell-mode))

;; *** ialign
;; :PROPERTIES:
;; :ID: 55570266-36e8-426e-aef6-5005bce6d73b
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "mkcms/interactive-align"
;; :PACKAGE:  "ialign"
;; :LOCAL-REPO: "interactive-align"
;; :COMMIT:   "eca40b8b59ea713dba21b18f5b047a6c086b91dc"
;; :END:

;; Package [[https://github.com/mkcms/interactive-align][ialign]] lets me use regular expressions to align text.

(void-autoload 'ialign)

;; ** lisp editing
;; :PROPERTIES:
;; :ID: f616348a-ba44-44f6-aeb6-3dc0a312143e
;; :END:

;; *** smartparens
;; :PROPERTIES:
;; :ID: 17257f23-c45e-4b7b-a3b4-7fd2333edf4d
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Fuco1/smartparens"
;; :PACKAGE:  "smartparens"
;; :LOCAL-REPO: "smartparens"
;; :COMMIT:   "c59bfef7e8f1687ac77b0afaaaed86d8051d3de1"
;; :END:

;; **** init
;; :PROPERTIES:
;; :ID:       e26f4c55-9585-4544-bed6-9733d50823e7
;; :END:

(void-add-hook '(prog-mode-hook eshell-mode-hook ielm-mode-hook)
               #'smartparens-strict-mode)

;; **** settings
;; :PROPERTIES:
;; :ID:       d4c619a8-c3e3-49ae-9e43-8274aeab1ba9
;; :END:

(setq sp-highlight-pair-overlay nil)
(setq sp-highlight-wrap-overlay nil)
(setq sp-highlight-wrap-tag-overlay nil)
(setq sp-show-pair-from-inside t)
(setq sp-cancel-autoskip-on-backward-movement nil)
(setq sp-show-pair-delay 0.1)
(setq sp-max-pair-length 4)
(setq sp-max-prefix-length 50)
(setq sp-escape-quotes-after-insert . nil)

;; **** config
;; :PROPERTIES:
;; :ID: f1c64411-ad51-4c24-8dad-b4aa7b8fc3b5
;; :END:

(sp-local-pair 'emacs-lisp-mode "<" ">")
(require 'smartparens-config)
(sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)

;; **** disable =smartparens-navigate-skip-match=
;; :PROPERTIES:
;; :ID: fda1875b-b3f7-4f43-83b1-873f3db3ae77
;; :END:

(defhook! disable-smartparens-navigate-skip-match (after-change-major-mode-hook)
  "Disable smartparents skip match feature."
  (setq sp-navigate-skip-match nil)
  (setq sp-navigate-consider-sgml-tags nil))

;; **** autopairing
;; :PROPERTIES:
;; :ID: e860ce7e-aaac-477b-a373-a8b01957481d
;; :END:

(defhook! enable-smartparens-maybe (minibuffer-setup-hook)
  "Enable `smartparens-mode' in the minibuffer, during `eval-expression' or
`evil-ex'."
  (when (memq this-command '(eval-expression evil-ex))
    (smartparens-mode 1)))

;; *** lispyville
;; :PROPERTIES:
;; :ID: 9d22714a-086d-49a1-9f8b-66da3b646110
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "noctuid/lispyville"
;; :PACKAGE:  "lispyville"
;; :LOCAL-REPO: "lispyville"
;; :COMMIT:   "0f13f26cd6aa71f9fd852186ad4a00c4294661cd"
;; :END:

;; [[https://github.com/noctuid/lispyville][lispyville]] helps vim commands work better with lisp by providing
;; commands (like [[helpfn:lispyville-delete][lispyville-delete]]) which preserve parentheses.

;; **** initialize
;; :PROPERTIES:
;; :ID: 5567b70d-60f2-4161-9a19-d6098f45cd95
;; :END:

(void-autoload 'lispyville (list #'lispyville-comment-or-uncomment-line))
(void-add-hook 'emacs-lisp-mode-hook #'lispyville-mode)

(general-def
  [remap evil-yank]                 lispyville-yank
  [remap evil-delete]               lispyville-delete
  [remap evil-change]               lispyville-change
  [remap evil-yank-line]            lispyville-yank-line
  [remap evil-delete-line]          lispyville-delete-line
  [remap evil-change-line]          lispyville-change-line
  [remap evil-delete-char]          lispyville-delete-char-or-splice
  [remap evil-delete-backward-char] lispyville-delete-char-or-splice-backwards
  [remap evil-substitute]           lispyville-substitute
  [remap evil-change-whole-line]    lispyville-change-whole-line
  [remap evil-join]                 lispyville-join)

;; **** inner text objects
;; :PROPERTIES:
;; :ID:       f9f82ebe-5749-452f-ba49-269e60526b04
;; :END:

(general-def evil-inner-text-objects-map
  "a" #'lispyville-inner-atom
  "l" #'lispyville-inner-list
  "x" #'lispyville-inner-sexp
  "c" #'lispyville-inner-comment
  ;; "f" #'lispyville-inner-function
  ;; "c" #'evilnc-inner-comment
  ;; overriding inner-sentence.
  "s" #'lispyville-inner-string)

;; **** outer text objects
;; :PROPERTIES:
;; :ID:       9dda9a1b-c76f-4537-9554-45ad3c77977a
;; :END:

(general-def evil-outer-text-objects-map
  "a" #'lispyville-a-atom
  "l" #'lispyville-a-list
  "x" #'lispyville-a-sexp
  "c" #'lispyville-a-comment
  ;; "f" #'lispyville-a-function
  ;; "c" #'evilnc-outer-commenter
  ;; "c" #'evilnc-outer-commenter
  "s" #'lispyville-a-string)

;; **** slurp/barf
;; :PROPERTIES:
;; :ID: 21626641-98e3-4134-958d-03227e4da6b5
;; :END:

(general-def 'normal lispyville-mode-map
  ">" #'lispyville-slurp
  "<" #'lispyville-barf)

;; **** escape
;; :PROPERTIES:
;; :ID: b355e1a1-6242-47f5-b357-5c3f5adbd200
;; :END:

;; =lispyville= binds escape to [[helpfn:lipyville-normal-state][lispyville-normal-state]]. So for =void-escape-hook=
;; to still happen on escape, I need to add [[helpfn:evil:escape-a][evil:escape-a]] as advice to
;; =lispyville-normal-state=.

;; Sometimes =evil-normal-state= enters visual state.

(general-def '(emacs insert) lispyville-mode-map [escape] #'lispyville-normal-state)

;; **** additional
;; :PROPERTIES:
;; :ID: 1fbafa78-87a0-45ee-9c7c-0c703df2ac66
;; :END:

(general-def '(emacs insert) lispyville-mode-map
  "SPC" #'lispy-space
  ";"   #'lispy-comment)

(general-def '(normal visual) lispyville-mode-map
  "M-j" #'lispyville-drag-forward
  "M-k" #'lispyville-drag-backward
  "M-R" #'lispyville-raise-list
  "M-v" #'lispy-convolute-sexp)

;; *** lispy
;; :PROPERTIES:
;; :ID:       47f19607-13a7-4857-bb1a-33760f95cb7e
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "lispy-clojure.clj" "lispy-python.py" "lispy-pkg.el")
;; :HOST:     github
;; :REPO:     "abo-abo/lispy"
;; :PACKAGE:  "lispy"
;; :LOCAL-REPO: "lispy"
;; :COMMIT:   "41f5574aefb69930d9bdcbe4e0cf642005369765"
;; :END:

;; For learning how to use lispy. [[https://github.com/abo-abo/lispy][the README]] and the [[http://oremacs.com/lispy/#lispy-different][lispy function reference]] were
;; very useful to me.

;; **** hook
;; :PROPERTIES:
;; :ID:       37bd49d1-3e34-4579-87d2-e791278be017
;; :END:

(void-add-hook 'emacs-lisp-mode-hook #'lispy-mode)
(void-autoload 'lispy #'lispy-mode)

;; **** settings
;; :PROPERTIES:
;; :ID:       20d99206-ddc4-42db-b4c1-8721decbaf8d
;; :END:

(setq lispy-avy-style-paren 'at-full)
(setq lispy-eval-display-style 'overlay)
(setq lispy-safe-delete t)
(setq lispy-safe-copy t)
(setq lispy-safe-paste t)
(setq lispy-safe-actions-no-pull-delimiters-into-comments t)
(setq lispy-delete-sexp-from-within t)
(setq lispy-parens-only-left-in-string-or-comment nil)
(setq lispy-safe-threshold 5000)
(setq lispy-use-sly t)
;; allow space before asterisk for headings (e.g. ";; *")
(setq lispy-outline "^;;\\(?:;[^#]\\|[[:space:]]*\\*+\\)")
(setq lispy-key-theme nil)

;; **** avoid void variable error
;; :PROPERTIES:
;; :ID:       a73ff9be-1a3d-4007-ad40-5a34c38767f6
;; :END:

;; You'll get void variable if you don't do this.
(after! (avy lispy) (setq lispy-avy-keys avy-keys))

;; ** writing
;; :PROPERTIES:
;; :ID: 27e382d7-5735-4f33-87c8-3dec2d2ca082
;; :END:

;; *** spell-number
;; :PROPERTIES:
;; :ID: 9cc794c5-dc10-4fb5-8af1-dd555c749071
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacsmirror/spell-number"
;; :PACKAGE:  "spell-number"
;; :LOCAL-REPO: "spell-number"
;; :COMMIT:   "3ce612dce14326b2304f5272e86b10c16102acce"
;; :END:

(setq spelln-language 'english-us)
(setq spelln-country 'united-states)
(setq spelln-period-character ?,)
(setq spelln-decimal-character ?.)

;; *** aggressive-fill-paragraph
;; :PROPERTIES:
;; :ID: 4f57fd49-b466-4eea-b91a-2cc8f0b07297
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "davidshepherd7/aggressive-fill-paragraph-mode"
;; :PACKAGE:  "aggressive-fill-paragraph"
;; :LOCAL-REPO: "aggressive-fill-paragraph-mode"
;; :COMMIT:   "2d65d925318006e2f6fa261ad192fbc2d212877b"
;; :END:

(void-add-hook 'prog-mode-hook #'aggressive-fill-paragraph-mode)

;; *** spell check
;; :PROPERTIES:
;; :ID:       864ab561-f3f6-4fdf-8b85-009a90f1b1f5
;; :END:

;; **** spell-fu
;; :PROPERTIES:
;; :ID: fc68d949-246f-43bf-85c2-7fbb947af7e9
;; :HOST:     gitlab
;; :REPO:     "ideasman42/emacs-spell-fu"
;; :PACKAGE:  "spell-fu"
;; :TYPE:     git
;; :LOCAL-REPO: "emacs-spell-fu"
;; :COMMIT:   "a7db58747131dca2eee0e0757c3d254d391ddd1c"
;; :END:

(void-autoload 'spell-fu)

(setq spell-fu-directory (concat VOID-DATA-DIR "spell-fu/"))

;; **** directory
;; :PROPERTIES:
;; :ID:       f3c7b015-c3c4-4898-9f64-834435cdae2f
;; :END:

;; *** auto-capitalize
;; :PROPERTIES:
;; :ID:       4ddfacc1-a25e-466e-ab6b-2a5ec306f3be
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacsmirror/auto-capitalize"
;; :PACKAGE:  "auto-capitalize"
;; :LOCAL-REPO: "auto-capitalize"
;; :COMMIT:   "0ee14c76d5771aaa84a004463f8b8b3a195c2fd8"
;; :END:

;; [[https://github.com/emacsmirror/auto-capitalize][auto-capitalize]] automatically capitalizes the first word of a sentence for me.
;; It will also upcase any word I add to [[helpvar:auto-capitalize-words][auto-capitalize-words]].

(void-add-hook '(text-mode-hook org-mode-hook) #'auto-capitalize-mode)
(void-autoload 'auto-capitalize #'auto-capitalize-mode)
(setq auto-capitalize-words . '("I" "English"))

;; *** powerthesaurus
;; :PROPERTIES:
;; :ID: 5578aaf2-796f-4006-af60-de87b215120a
;; :END:

(alet (list #'powerthesaurus-lookup-word-at-point
            #'power-thesaurus-lookup-word-dwim)
  (void-autoload 'powerthesaurus it))

;; *** define-it
;; :PROPERTIES:
;; :ID: 9ddc66c9-87be-43d1-8366-1bdb40718892
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "jcs-elpa/define-it"
;; :PACKAGE:  "define-it"
;; :LOCAL-REPO: "define-it"
;; :COMMIT:   "8df0505babf930bafe3fd28d472cc325637f886b"
;; :END:

(void-autoload 'define-it '(define-it define-it-at-point))

(setq define-it-output-choice 'view)
(setq define-it-show-google-translate nil)

;; *** plural
;; :PROPERTIES:
;; :ID:       bf2ed9b7-144c-4d4b-92ae-74c93dfc6db5
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacsmirror/plural"
;; :PACKAGE:  "plural"
;; :LOCAL-REPO: "plural"
;; :COMMIT:   "b91ce1594783c51dabeadbbcbb9caa00aaaa1353"
;; :END:

;; This package determines whether a noun is plural and provides a function to
;; convert a singular noun to a plural one. For example ~(plural-pluralize
;; "goose")~ returns ~"geese"~.

;; My intended use for this package is to help automate prompts, docstrings or the
;; like that concern N number of things, where N could be 1 or more things.

;; **** commands
;; :PROPERTIES:
;; :ID:       8c8ce3ab-e7b1-492c-b891-8b4b304baaca
;; :END:

(void-autoload 'plural #'plural-make-plural)

;; **** plural
;; :PROPERTIES:
;; :ID:       55e3bd54-336f-4a9f-be87-fa16b4549c94
;; :END:

(push (cons (rx bos "is" eos) "are") plural-knowledge)
(push (cons (rx bos "thas" eos) "those") plural-knowledge)
(push (cons (rx bos "this" eos) "these") plural-knowledge)

;; ** evil
;; :PROPERTIES:
;; :ID: 73366b3e-7438-4abf-a661-ed1553b1b8df
;; :END:

;; *** evil
;; :PROPERTIES:
;; :ID: 3b9aaf0c-a69c-474a-b1a3-f0e748e83558
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "doc/build/texinfo/evil.texi" (:exclude "evil-test-helpers.el") "evil-pkg.el")
;; :HOST:     github
;; :REPO:     "emacs-evil/evil"
;; :PACKAGE:  "evil"
;; :LOCAL-REPO: "evil"
;; :COMMIT:   "32b2783d2cb7e093ac284fa6af9ceed8e4418826"
;; :END:

;; [[https://github.com/emacs-evil/evil][evil]] is an extensible vi layer for Emacs. It emulates the main features of Vim,
;; and provides facilities for writing custom extensions. Also see our page on
;; [[emacswiki:Evil][EmacsWiki]]. See a brief [[https://bytebucket.org/lyro/evil/raw/default/doc/evil.pdf][manual]]. See the [[https://github.com/noctuid/evil-guide][evil-guide]] by noctuid.

;; **** init
;; :PROPERTIES:
;; :ID:       af3a9791-76ac-4fd5-96fe-d361cef3b5b3
;; :END:

(require 'evil)
(void-add-hook 'window-setup-hook #'evil-mode)

;; **** custom
;; :PROPERTIES:
;; :ID:       f7ece898-25e2-4b2c-94f3-e832a687114c
;; :END:

(general-setq evil-want-C-u-scroll t)

;; **** settings
;; :PROPERTIES:
;; :ID:       9f184a21-ef04-4b3d-a1b7-88a16eaa7b97
;; :END:

(setq evil-want-C-w-in-emacs-state         nil)
(setq evil-want-visual-char-semi-exclusive t)
;; Whether the cursor can move past the end of the line.
(setq evil-move-beyond-eol                 nil)
(setq evil-magic                           t)
(setq evil-echo-state                      nil)
(setq evil-indent-convert-tabs             t)
(setq evil-ex-search-vim-style-regexp      t)
(setq evil-ex-substitute-global            t)
(setq evil-ex-visual-char-range            t)
(setq evil-insert-skip-empty-lines         t)
(setq evil-mode-line-format                nil)
(setq evil-respect-visual-line-mode        t)
(setq evil-symbol-word-search              t)

;; **** cursors
;; :PROPERTIES:
;; :ID: a5f558fb-221c-4b33-a7cd-29308ef74b0d
;; :END:

;; It's nice to have cursors change colors (and sometimes shape) depending on the
;; current evil state. It makes it easy to tell which state you're in. I define
;; some colors here. Evil has a cursor variable for each state. The cursor variable
;; for insert state, for example, is [[helpvar:evil-insert-state-cursor][evil-insert-state-cursor]]. Its value is of the
;; form: ~((CURSOR-SHAPE . CURSOR-WIDTH) COLOR)~.

;; ***** colors and shapes
;; :PROPERTIES:
;; :ID: 3f3cd5c9-1f6d-4c3b-b73f-82c9ee00395e
;; :END:

;; Evil differentiates what state you're in based on the cursor color.

(defhook! setup-cursor (evil-mode-hook)
  "Initialize the default cursor shape and size."
  (setq evil-insert-state-cursor   '((bar . 3)   "chartreuse3"))
  (setq evil-emacs-state-cursor    '((bar . 3)   "SkyBlue2"))
  (setq evil-normal-state-cursor   '( box        "DarkGoldenrod2"))
  (setq evil-visual-state-cursor   '((hollow)    "dark gray"))
  (setq evil-operator-state-cursor '((hbar . 10) "hot pink"))
  (setq evil-replace-state-cursor  '( box        "chocolate"))
  (setq evil-motion-state-cursor   '( box        "plum3")))

;; ***** updating cursors
;; :PROPERTIES:
;; :ID: ea4da6d4-4a2c-42cf-b397-cea1555781ce
;; :END:

;; After a theme is loaded, the cursor color won't automatically update. Therefore,
;; I add a hook in [[helpvar:void-after-load-theme-hook][void-after-load-theme-hook]]. Now after a new theme is loaded, the
;; cursor color will update.

(defhook! refresh-evil-cursor (void-after-load-theme-hook)
  "Enable cursor refreshing after theme change."
  (when (bound-and-true-p evil-mode)
    (evil-refresh-cursor)))

;; **** normal state everywhere
;; :PROPERTIES:
;; :ID:       e6126bd7-94b8-4ce0-b547-0536b59437ea
;; :END:

(defhook! make-normal-state-default (evil-mode-hook)
  "Make normal state the default `evil-mode' state."
  (setq evil-normal-state-modes (append evil-emacs-state-modes evil-normal-state-modes))
  (setq evil-emacs-state-modes nil)
  (setq evil-motion-state-modes nil))

(defadvice! replace-motion-with-normal (:around evil-make-overriding-map)
  "Advice for `evil-make-overriding-map' that inhibits motion state."
  (-let (((keymap state copy) <args>))
    (funcall <orig-fn> keymap (if (eq state 'motion) 'normal state) copy)))

(defadvice! replace-motion-with-normal (:around evil-set-initial-state)
  (-let (((mode state) <args>))
    (funcall <orig-fn> mode (if (eq state 'motion) 'normal state))))

(void-add-advice #'evil-motion-state :override #'evil-normal-state)

;; **** insert state in minibuffer
;; :PROPERTIES:
;; :ID: a23137c5-62a0-4e77-9e51-6a7372dac703
;; :END:

;; Before I just used ~(evil-change-state evil-previous-state)~ to revert the
;; state back to what it last was. But this fails with ~evil-force-normal-state~
;; which is what I'm currently using to exit the minibuffer because then the
;; last state is normal state if the minibuffer is aborted. Using a
;; =evil:state-before-minibuffer= ensures that the state will be reverted to
;; the correct one.

(defhook! preserve-prior-evil-state (minibuffer-enter-hook)
  "Save state before entering the minibuffer and enter insert state."
  (when (bound-and-true-p evil-mode)
    (setq evil:state-before-minibuffer evil-state)
    (evil-insert-state)))

(defhook! restore-prior-evil-state (minibuffer-exit-hook)
  "Restore state after minibuffer."
  (when (bound-and-true-p evil-mode)
    (evil-change-state evil:state-before-minibuffer)
    (setq evil:state-before-minibuffer nil)))

;; **** escape
;; :PROPERTIES:
;; :ID:       e4b9d33d-c64d-47ef-9bff-baa80d1b34b2
;; :END:

;; ***** escape
;; :PROPERTIES:
;; :ID: ea9378de-e5c5-482c-b53b-743a81e3bc8e
;; :END:

;; We want escape to be a general "quit everything".

(general-def :states '(emacs insert) [escape] #'evil-force-normal-state)

(defadvice! exit-everything (:after evil-force-normal-state lispyville-normal-state)
  "Exits out of whatever is happening after escape."
  (cond ((minibuffer-window-active-p (minibuffer-window))
         (abort-recursive-edit))
        ((run-hook-with-args-until-success 'void-escape-hook))
        ((or defining-kbd-macro executing-kbd-macro) nil)
        (t (keyboard-quit))))

;; ***** keychord
;; :PROPERTIES:
;; :ID:       8fd1bcdc-c4b3-4fee-b91b-dcdf96167582
;; :END:

;; Sometimes we don't have access to a convenient escape key--I mean that caps-lock
;; is not bound to escape. Or, perhaps, we might find it faster or preferable to
;; press =jk= really quickly to invoke escape.

;; This is better than evil escape as it only binds in insert.

;; ****** init
;; :PROPERTIES:
;; :ID:       6d02f80a-6d77-4a02-911e-98b7f4004048
;; :END:

(alet (list #'evil-insert-state #'evil-emacs-state)
  (void-load-before-call 'keychord it))

;; ****** be quiet when turning on
;; :PROPERTIES:
;; :ID:       1e1cff0d-3a2b-45cf-ab32-30379a86023c
;; :END:

(quiet! (key-chord-mode 1))

;; ****** keychord bindings
;; :PROPERTIES:
;; :ID:       738065e2-d607-4672-b44e-1fff5ed249bc
;; :END:

(general-def :states '(visual insert)
  (general-chord "jk") 'evil-force-normal-state
  (general-chord "kj") 'evil-force-normal-state)

;; **** saving
;; :PROPERTIES:
;; :ID: 8181807e-9811-427c-beec-f380d91040f9
;; :END:

(setq save-silently t)

(defun evil:save-message ()
  (message "\"%s\" %dL, %dC written"
           (buffer-name)
           (count-lines (point-min) (point-max))
           (buffer-size)))

;; **** text objects
;; :PROPERTIES:
;; :ID: 07366548-2960-49c6-9ab7-cb177b06ad70
;; :END:

;; To edit text efficiently Vim has the concept of [[https://blog.carbonfive.com/2011/10/17/vim-text-objects-the-definitive-guide/][text objects]]. Text objects are
;; structures that are seen in text. For example, a set of words followed by a
;; period is a sentence. A words between two closing parentheses is a sexp.

;; ***** general delimiter text object
;; :PROPERTIES:
;; :ID: f551956d-440c-431b-8fb0-8e71c9714f11
;; :END:

;; I discovered this the =form= text object from using [[https://github.com/luxbock/evil-cleverparens][evil-cleverparens]] in the past.
;; The package =evil-cleverparens= was too slow for my taste; noctuid's [[https://github.com/sp3ctum/evil-lispy][evil-lispy]] is
;; much faster and gave me the functionality that I needed most from
;; =evil-cleverparens=: deleting and copying text with parentheses intelligently.
;; However, many of the ideas of =evil-cleverparens= were excellent. One particular
;; idea was to have a general =form= text object. Instead of specifying the
;; particular surrounding bounds when doing an evil operator command you just use a
;; single key for them. It's kind of like a =Do-What-I-Mean= surround operator. This
;; is suprisingly useful because it takes significant time to specify whether you
;; want =[]= or ={=}= or =()= or =""=. The main drawback you cannot distinguish between
;; surround characters at multiple levels--it just takes the closest one. In
;; practice, this is rarely an issue.

(after! evil
  (evil-define-text-object evil:textobj-inner-form (count &rest _)
    "Inner sexp object."
    (-if-let ((beg . end)
              (->> (list (lispy--bounds-list) (lispy--bounds-string))
                   (-non-nil)
                   (--sort (< (- (cdr it) (car it)) (- (cdr other) (car other))))
                   (car)))
        (evil-range (1+ beg) (1- end) 'inclusive :expanded t)
      (error "No surrounding form found.")))

  (evil-define-text-object evil:textobj-outer-form (count &rest _)
    "Smartparens inner sexp object."
    (-if-let ((beg . end)
              (->> (list (lispy--bounds-list) (lispy--bounds-string))
                   (-non-nil)
                   (--sort (< (- (cdr it) (car it)) (- (cdr other) (car other))))
                   (car)))
        (evil-range beg end 'inclusive :expanded t)
      (error "No surrounding form found.")))

  (general-def evil-inner-text-objects-map
    "f" #'evil:textobj-inner-form)
  (general-def evil-outer-text-objects-map
    "f" #'evil:textobj-outer-form))

;; ***** fix vim/evil around =""=
;; :PROPERTIES:
;; :ID: b57bf245-3d63-4078-8bcb-2ec0b9952ab9
;; :END:

;; =Vim= and =Evil= both have the interesting (inconsistent?) behavior that doing an
;; outer text object operator on a comment grabs some whitespace on the left side.
;; Try doing =va"= to ~(progn "hello world")~ and you'll see that =\s"hello world"= is
;; selected instead of just "hello world".

;; Why not just go to the end of the ="= like any other around operator?

(after! evil
  (evil-define-text-object evil:textobj-a-string (count &rest _)
    "An outer comment text object as defined by `lispy--bounds-string'."
    (-if-let ((beg . end) (lispy--bounds-string))
        (evil-range beg end 'exclusive :expanded t)
      (error "Not inside a comment.")))

  (general-def evil-outer-text-objects-map
    "\"" #'evil:textobj-a-string))

;; **** package specific setup                                           :disabled:
;; :PROPERTIES:
;; :ID: 5f9025e0-156c-4270-96ab-49011df83632
;; :END:

;; ***** helpful
;; :PROPERTIES:
;; :ID: 81552b9b-46aa-46c8-8541-500059dda695
;; :END:

(after! (evil helpful)
  (evil-set-initial-state 'helpful-mode 'normal))

;; ***** magit
;; :PROPERTIES:
;; :ID: a27830b2-b60a-4aca-b65a-4042392d7105
;; :END:

(after! (evil magit)
  (add-hook 'git-commit-mode-hook #'evil-insert-state))

;; ***** org
;; :PROPERTIES:
;; :ID: 62d87b9a-6219-4feb-b46c-a6e2e4155a90
;; :END:

;; ****** insert state
;; :PROPERTIES:
;; :ID: b9cde044-5190-4789-97c4-a124c6701cd4
;; :END:

(after! (evil org)
  (add-hook 'org-insert-heading-hook #'evil-insert-state)
  (after! org-capture
    (add-hook 'org-capture-mode-hook #'evil-insert-state)))

;; ***** eshell
;; :PROPERTIES:
;; :ID: 0a974596-2004-4ed2-9053-8bc6db1acd84
;; :END:

;; ****** evil operators
;; :PROPERTIES:
;; :ID: 142162a1-0495-427e-bac6-f2e8e63dd184
;; :END:

;; ******* evil-change
;; :PROPERTIES:
;; :ID: 1a47ff34-8f3b-4845-b3e9-0ae0937c5c84
;; :END:

(after! eshell
  (evil-define-operator eshell/evil-change (beg end type register yank-handler delete-func)
    "Like `evil-change' but will not delete/copy the prompt."
    (interactive "<R><x><y>")
    (save-restriction
      (narrow-to-region eshell-last-output-end (point-max))
      (evil-change (max beg (point-min))
                   (if (eq type 'line) (point-max) (min (or end (point-max)) (point-max)))
                   type register yank-handler delete-func))))

;; ******* evil-change-line
;; :PROPERTIES:
;; :ID: 296c4f58-261f-4f1b-a333-7807ebef331b
;; :END:

(after! eshell
  (evil-define-operator eshell/evil-change-line (beg end type register yank-handler)
    "Change to end of line."
    :motion evil-end-of-line
    (interactive "<R><x><y>")
    (eshell/evil-change beg end type register yank-handler #'evil-delete-line)))

;; ******* evil-delete
;; :PROPERTIES:
;; :ID: 63b0c253-a59e-409a-b593-36ddd84d8777
;; :END:

(after! eshell
  (evil-define-operator eshell/evil-delete (beg end type register yank-handler)
    "Like `evil-delete' but will not delete/copy the prompt."
    (interactive "<R><x><y>")
    (save-restriction
      (narrow-to-region eshell-last-output-end (point-max))
      (evil-delete (if beg (max beg (point-min)) (point-min))
                   (if (eq type 'line) (point-max) (min (or end (point-max)) (point-max)))
                   type register yank-handler))))

;; ******* evil-delete-line
;; :PROPERTIES:
;; :ID: 017b5fe8-a27e-4bab-a014-8bf53258b92a
;; :END:

(after! eshell
  (evil-define-operator eshell/evil-delete-line (_beg end type register yank-handler)
    "Change to end of line."
    :motion nil
    :keep-visual t
    (interactive "<R><x>")
    (eshell/evil-delete (point) end type register yank-handler)))

;; ****** update cursors after entering eshell
;; :PROPERTIES:
;; :ID: 5384f57c-9eba-4f00-953a-92814a253ce9
;; :END:

(after! evil
  (evil-set-initial-state 'eshell-mode 'insert))

;; ***** smartparens
;; :PROPERTIES:
;; :ID: 4977e770-2c5b-4819-8c6d-ed2c794737fe
;; :END:

;; smartparens breaks evil-mode's replace state
(after! (evil smartparens)
  (add-hook 'evil-replace-state-entry-hook #'turn-off-smartparens-mode)
  (add-hook 'evil-replace-state-exit-hook  #'turn-on-smartparens-mode))

;; ***** debugger-mode
;; :PROPERTIES:
;; :ID: 614215d3-33b1-482e-bf0e-c9d66cdb1c24
;; :END:

(after! evil (evil-set-initial-state 'debugger-mode 'emacs))

;; *** evil-surround
;; :PROPERTIES:
;; :ID:       bc9899a4-654e-4bf6-89bd-557a72c713a8
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "emacs-evil/evil-surround"
;; :PACKAGE:  "evil-surround"
;; :LOCAL-REPO: "evil-surround"
;; :COMMIT:   "346d4d85fcf1f9517e9c4991c1efe68b4130f93a"
;; :END:

;; **** hooks
;; :PROPERTIES:
;; :ID: ef933441-4891-48d8-a4aa-016702e55b48
;; :END:

(void-add-hook '(prog-mode-hook text-mode-hook) #'evil-surround-mode)

;; *** evil-matchit
;; :PROPERTIES:
;; :ID: 30ff273a-253b-4cdc-8e86-22e5705f44c1
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "redguardtoo/evil-matchit"
;; :PACKAGE:  "evil-matchit"
;; :LOCAL-REPO: "evil-matchit"
;; :COMMIT:   "539192328ec521796c3f2bd8c1ac1a1b0e4f08f9"
;; :END:

(void-add-hook 'prog-mode-hook #'evil-matchit-mode)

;; *** evil-exchange
;; :PROPERTIES:
;; :ID: d1c40ac0-d143-4e27-847b-d3d8e72a552a
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Dewdrops/evil-exchange"
;; :PACKAGE:  "evil-exchange"
;; :LOCAL-REPO: "evil-exchange"
;; :COMMIT:   "3030e21ee16a42dfce7f7cf86147b778b3f5d8c1"
;; :END:

;; Package [[https://github.com/Dewdrops/evil-exchange][evil-exchange]] lets me swap two regions of text.

(void-autoload 'evil-exchange (list #'evil-exchange))

(general-def 'normal
  :prefix "g"
  "X" (list :def #'evil-exchange-cancel :wk "cancel")
  "x" (list :def #'evil-exchange :wk "exchange"))

;; *** evil-visualstar
;; :PROPERTIES:
;; :ID:       8b86236c-2162-47e2-a2cc-eaee2f51d1b2
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "bling/evil-visualstar"
;; :PACKAGE:  "evil-visualstar"
;; :LOCAL-REPO: "evil-visualstar"
;; :COMMIT:   "06c053d8f7381f91c53311b1234872ca96ced752"
;; :END:

;; **** evil-visualstar
;; :PROPERTIES:
;; :ID: 6ebca72d-f90a-4423-9ecd-706f9d426002
;; :END:

;; [[https://github.com/bling/evil-visualstar][evil-visualstar]]

(alet (list #'evil-visualstar/begin-search-backward
            #'evil-visualstar/begin-search-forward)
  (void-autoload 'evil-visualstart it))

(general-def
  :package evil-visualstar
  :map evil-visual-state-map
  "#" evil-visualstar/begin-search-backward
  "*" evil-visualstar/begin-search-forward)

;; ** expand-region
;; :PROPERTIES:
;; :ID:       8ffebf9c-c783-4a5d-beb1-3194863bb234
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "magnars/expand-region.el"
;; :PACKAGE:  "expand-region"
;; :LOCAL-REPO: "expand-region.el"
;; :COMMIT:   "ea6b4cbb9985ddae532bd2faf9bb00570c9f2781"
;; :END:

;; [[https://github.com/magnars/expand-region.el][expand-region]] allows me to toggle a key ("v" in my case) to select progressively
;; larger text objects. It's saves me keystrokes.

;; *** expand region
;; :PROPERTIES:
;; :ID:       dc5d1a43-fee6-48d8-bed0-8f6bc0119c68
;; :END:

(general-def 'visual
  "V" #'er/contract-region
  "v" #'er/expand-region)

;; *** autoload commands
;; :PROPERTIES:
;; :ID:       23d68159-bb65-45b7-96e5-48cb1dfca946
;; :END:

(alet (list #'er/expand-region
            #'er/contract-region
            #'er/mark-symbol
            #'er/mark-word)
  (void-autoload 'expand-region))

;; *** quit expand region
;; :PROPERTIES:
;; :ID:       0dc7bb0d-a0ef-450a-b129-9c8d80cb6a0e
;; :END:

(defadvice! quit-expand-region (:before evil-escape)
  "Properly abort an expand-region region."
  (when (memq last-command '(er/expand-region er/contract-region))
    (er/contract-region 0)))

;; ** avy
;; :PROPERTIES:
;; :ID: 71d016e2-a118-4468-8a01-fe86863bc030
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "abo-abo/avy"
;; :PACKAGE:  "avy"
;; :LOCAL-REPO: "avy"
;; :COMMIT:   "bbf1e7339eba06784dfe86643bb0fbddf5bb0342"
;; :END:

;; [[https://github.com/abo-abo/avy][Avy]]

;; *** settings
;; :PROPERTIES:
;; :ID:       fd52fbe0-e491-41f8-8558-3fc263a62c80
;; :END:

(setq avy-background t)
;; Jump only on current window.
(setq avy-all-windows nil)
;; Use avy keys.
(setq avy-keys-alist nil)

(setq avy-style 'at)

;; *** avy keys
;; :PROPERTIES:
;; :ID:       cbe231da-a16e-4846-a30e-aa4bc8228378
;; :END:

(setq avy-keys
      (list
       ;; homerow keys in alternating order.
       ?a ?j ?s ?k ?d ?l ?f ?\;
       ;; middle homerow keys
       ?g ?h
       ;; keys above homerow in alternating order
       ?t ?y ?r ?u ?e ?i ?w ?o ?q ?p
       ;; keys below homerow
       ?b ?n ?v ?m ?c ?, ?x ?. ?z ?/))

;; *** bootstrap
;; :PROPERTIES:
;; :ID: eff03171-05b3-4a70-93ee-0a0f2b2c64f4
;; :END:

(void-autoload 'avy 'avy-jump)

;; *** avy-command-helper
;; :PROPERTIES:
;; :ID:       814e98f9-5823-4e8f-9f89-49cdecf3d809
;; :END:

(defun avy:jump-to-regexp (regexp)
  (avy-jump regexp
            :beg (window-start)
            :end (window-end)
            :pred `(lambda () (/= (1+ ,(point)) (point)))))

;; *** avy commands
;; :PROPERTIES:
;; :ID: 01ee387f-f153-497e-b9fb-d62d5df9ebe1
;; :END:

(defun void/evil-beginning-of-word ()
  (interactive)
  (avy:jump-to-regexp (rx word-start nonl)))

(defun void/evil-beginning-of-WORD ()
  (interactive)
  (avy:jump-to-regexp (rx symbol-start nonl)))

(defun void/evil-end-of-word ()
  (interactive)
  (avy:jump-to-regexp (rx nonl word-end)))

(defun void/evil-end-of-WORD ()
  (interactive)
  (avy:jump-to-regexp (rx nonl symbol-end)))

;; ** undo
;; :PROPERTIES:
;; :ID: 87fde0b2-5db6-4b5f-8945-d469449f1207
;; :END:

;; *** undo-fu
;; :PROPERTIES:
;; :ID:       a808c260-399c-4cf7-82ae-48a433474e25
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     gitlab
;; :REPO:     "ideasman42/emacs-undo-fu"
;; :PACKAGE:  "undo-fu"
;; :LOCAL-REPO: "emacs-undo-fu"
;; :COMMIT:   "c0806c1903c5a0e4c69b6615cdc3366470a9b8ca"
;; :END:

;; **** settings
;; :PROPERTIES:
;; :ID:       85230cf3-d90a-426a-b3dd-7cb3b27e8218
;; :END:

(setq undo-limit 400000)
(setq undo-strong-limit 3000000)
(setq undo-outer-limit 3000000)

;; **** bind
;; :PROPERTIES:
;; :ID:       650470d8-bf28-49a7-b120-7c60b1bfd618
;; :END:

(general-def [remap undo] undo-fu-only-undo)
(general-def [remap redo] undo-fu-only-redo)

;; **** make sure that built-in undo is disabled
;; :PROPERTIES:
;; :ID:       aa8f5747-5c19-45da-9957-ddf2b1c3f067
;; :END:

(global-undo-tree-mode -1)

;; *** undo-fu-session
;; :PROPERTIES:
;; :ID:       12a36a4e-65df-4dd3-be35-d84dd76651a4
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     gitlab
;; :REPO:     "ideasman42/emacs-undo-fu-session"
;; :PACKAGE:  "undo-fu-session"
;; :LOCAL-REPO: "emacs-undo-fu-session"
;; :COMMIT:   "56cdd3538a058c6916bdf2d9010c2179f2505829"
;; :END:

;; * Utility
;; :PROPERTIES:
;; :ID: 15266577-fc6e-4ec7-8277-3a94b6f4f926
;; :END:

;; ** request
;; :PROPERTIES:
;; :ID:       d9644e3d-fc9b-4fb4-a46c-f68134f3c301
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("request.el" "request-pkg.el")
;; :HOST:     github
;; :REPO:     "tkf/emacs-request"
;; :PACKAGE:  "request"
;; :LOCAL-REPO: "emacs-request"
;; :COMMIT:   "0183da84cb45eb94da996cd2eab714ef0d7504cc"
;; :END:

(setq request-storage-directory (concat VOID-DATA-DIR "request"))

;; ** savehist
;; :PROPERTIES:
;; :ID:       dd4b9da7-e54d-4d62-bb70-aa8f7f4a016f
;; :END:

;; =savehist= is a built-in feature for saving the minibuffer-history to a file--the
;; [[helpvar:savehist][savehist]] file. Additionally, it provides the ability to save additional
;; variables which may or may not be related to minibuffer history. You add the
;; ones you want to save to [[helpvar:savehist-additional-variables][savehist-additional-variables]].

;; *** init
;; :PROPERTIES:
;; :ID:       54183df6-b4f5-4b01-9ddb-4054ef0583b0
;; :END:

(idle-require 'custom)
(void-add-hook 'emacs-startup-hook #'savehist-mode)

(setq savehist-save-minibuffer-history t)
(setq savehist-autosave-interval nil)
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(push 'void-package-load-paths savehist-additional-variables)
(setq savehist-file (concat VOID-DATA-DIR "savehist"))

;; *** unpropertize kill ring
;; :PROPERTIES:
;; :ID:       da2b6c31-d251-48aa-a6ed-8f01b9fa0b8d
;; :END:

(defhook! unpropertize-kill-ring (kill-emacs-hook :append t)
  "Remove text properties from `kill-ring'."
  (setq kill-ring
        (--map (when (stringp it) (substring-no-properties it))
               (-non-nil kill-ring))))

;; ** find-file-rg
;; :PROPERTIES:
;; :ID:       561ebd06-98db-4253-bee8-066c338b8cac
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "muffinmad/emacs-find-file-rg"
;; :PACKAGE:  "find-file-rg"
;; :LOCAL-REPO: "emacs-find-file-rg"
;; :COMMIT:   "ed556e092a92e325f335554ab193cef2d8fec009"
;; :END:

;; *** find-file-rg
;; :PROPERTIES:
;; :ID:       b45fd2d1-d21a-49aa-8ad9-7ba4dbec1356
;; :END:

;; =find-file-rg= is a package that uses [[https://github.com/BurntSushi/ripgrep][ripgrep]] to find files.

(void-system-ensure 'find-file-rg #'rg)

(general-def
  [remap find-file]          . find-file-rg
  [remap find-file-at-point] . find-file-rg-at-point)

;; ** eshell
;; :PROPERTIES:
;; :ID: 5f04a252-2985-46b4-ab0b-eb4567de5dd9
;; :TYPE:     built-in
;; :END:

;; [[info:eshell#Top][eshell]] is a built-in shell written entirely in elisp. This means that it's as
;; portable and customizable as emacs itself. It can run elisp functions as
;; commands. There's a good article about it in [[https://masteringemacs.org/article/complete-guide-mastering-eshell][mastering-emacs]]. Other articles I
;; have like about eshell: [[https://ambrevar.xyz/emacs-eshell/][ambrevar's eshell post]], [[http://www.howardism.org/Technical/Emacs/eshell-fun.html][Howard Abram's Post]].

;; *** init
;; :PROPERTIES:
;; :ID:       f91b3d13-3470-4108-aae3-2b8b4e5f5edb
;; :END:

;; **** idle require
;; :PROPERTIES:
;; :ID:       9ff94547-b138-41dc-836f-71fc37171ec3
;; :END:

(-each '(em-alias em-banner em-basic em-cmpl
         em-dirs em-glob em-hist em-ls em-prompt
         em-script em-term em-unix)
  #'idle-require)

;; **** popup
;; :PROPERTIES:
;; :ID:       bd580e0c-1736-4855-8cfb-e4e365ecd8d3
;; :END:

;; :popup ("\\*eshell"
(display-buffer-at-bottom)
(window-height . 0.5)
(side . bottom)
(slot . 2))

;; **** directories
;; :PROPERTIES:
;; :ID:       4923faac-1630-4389-8f2c-d9e75c88eecf
;; :END:

(eshell-directory-name . (concat VOID-DATA-DIR "eshell/"))
(eshell-history-file-name . (concat eshell-directory-name "history"))

;; **** bootstrap
;; :PROPERTIES:
;; :ID: 8ed5b69c-be1f-4181-bd01-88fc33b148d6
;; :END:

(use-feature! eshell
  :commands eshell
  :idle-require
  :setq
  (eshell-prefer-lisp-functions . nil)
  (eshell-scroll-to-bottom-on-input . 'all)
  (eshell-scroll-to-bottom-on-output . 'all)
  (eshell-buffer-shorthand . t)
  (eshell-kill-processes-on-exit . t)
  (eshell-hist-ignoredups . t)
  (eshell-input-filter . #'eshell-input-filter-initial-space)
  (eshell-glob-case-insensitive . t)
  (eshell-error-if-no-glob . t)
  (eshell-banner-message . '(format "%s %s\n\n"
                             (propertize (format " %s " (string-trim (buffer-name)))
                              'face 'mode-line-highlight)
                             (propertize (current-time-string)
                              'face 'font-lock-keyword-face)))
  :config
  (remove-hook 'eshell-output-filter-functions
               'eshell-postoutput-scroll-to-bottom))

;; *** visual commands
;; :PROPERTIES:
;; :ID: fedfa200-7d17-408d-ba42-da401cba6419
;; :END:

(after! em-term
  (--each '("tmux" "htop" "bash" "zsh" "fish" "vim" "nvim" "ncmpcpp")
    (add-to-list 'eshell-visual-commands it)))

;; *** improvements
;; :PROPERTIES:
;; :ID: b3da5d39-1591-4a19-ae96-45a117a13f24
;; :END:

;; Eshell uses pcomplete as its completion engine.

;; **** pcomplete
;; :PROPERTIES:
;; :ID: 63de7a7f-431c-4652-aa55-45973b5a4c2a
;; :END:

;; This replaces the default popup window at the bottom of eshell. By using the
;; =completion-in-region= backend, it triggers ivy/helm for completion.

(defun eshell/pcomplete ()
  "Use pcomplete with completion-in-region backend."
  (interactive)
  (require 'pcomplete)
  (ignore-errors (pcomplete-std-complete)))

;; **** go to prompt on insert
;; :PROPERTIES:
;; :ID: 76bd909c-901c-4bc6-8848-d84b121a06c3
;; :END:

(defun eshell:goto-prompt-on-insert-h ()
  "Move cursor to the prompt when switching to insert mode."
  (when (< (point) eshell-last-output-end)
    (goto-char
     (if (memq this-command '(evil-append evil-append-line))
         (point-max)
       eshell-last-output-end))))

;; *** eshell commands
;; :PROPERTIES:
;; :ID: 4a7074f6-7f53-4950-9c92-be39b23e1d70
;; :END:

;; **** eshell-z
;; :PROPERTIES:
;; :ID:       5a90b4ea-a3ee-42cf-825f-d1d093133b58
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "xuchunyang/eshell-z"
;; :PACKAGE:  "eshell-z"
;; :LOCAL-REPO: "eshell-z"
;; :COMMIT:   "337cb241e17bd472bd3677ff166a0800f684213c"
;; :END:

;; ***** eshell-z
;; :PROPERTIES:
;; :ID: 497798a0-7b62-4779-bf15-f67500528f03
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "xuchunyang/eshell-z"
;; :PACKAGE:  "eshell-z"
;; :LOCAL-REPO: "eshell-z"
;; :COMMIT:   "337cb241e17bd472bd3677ff166a0800f684213c"
;; :END:

(after! eshell
  (defalias 'eshell:z-file 'eshell-z-freq-dir-hash-table-file-name)
  (setq eshell:z-file . (expand-file-name "z" eshell-directory-name))
  (void-autoload 'eshell-z #'eshell-z))

;; **** eshell-up
;; :PROPERTIES:
;; :ID: 478219b9-1c6f-4907-b428-a2dfe0f45e5c
;; :END:

;; This is an Emacs package for quickly navigating to a specific parent directory
;; in ~eshell~ without having to repeatedly typing ~cd ..~.

(use-package! eshell-up
  :after eshell
  :commands eshell-up eshell-up-peek
  :init
  (defalias 'eshell/up 'eshell-up)
  (defalias 'eshell/pk 'eshell-up-peek)
  (defalias 'eshell/peek 'eshell-up-peek))

;; **** eshell-clear
;; :PROPERTIES:
;; :ID: 6ae332e7-f2e8-4a78-9bb8-c9b4f271a6a2
;; :END:

;; The shell often gets cluttered with many commands. It's often useful to clear it
;; and indeed there are many suggestions on how to do so online. However, many of
;; them involve erasing the eshell buffer or making it's previous contents
;; inaccessable. I don't like getting rid of information that could be important.
;; All I really wanted is to just scroll up to the top of the window so that the
;; previous contents weren't visible. Note that it is important that this command
;; returns nil. Eshell shell ignores output returns nil. However, when it returns
;; non-nil it prints it to the eshell buffer, which results in a residue
;; line--that's not what we want.

;; https://emacs.stackexchange.com/questions/28819/eshell-goes-to-the-bottom-of-the-page-after-executing-a-command

(defadvice! scroll-to-top (:override eshell/clear)
  "Scroll eshell buffer to top.
The effect of this is to clear the contents of the eshell buffer."
  (progn (call-interactively #'evil-scroll-line-to-top) nil))

;; *** display
;; :PROPERTIES:
;; :ID: 66d647e3-b83b-4469-bb62-75546c2fee64
;; :END:

;; **** prompt
;; :PROPERTIES:
;; :ID: c21591c9-43a2-4c6b-aac8-b46b41f4dc63
;; :END:

;; I got a lot of inspiration from the [[http://www.modernemacs.com/post/custom-eshell/][modern emacs blog]]. I think the
;; author's code is in general a good example of how to use macros to abstract a
;; task and make it much simpler than it would be otherwise.

;; ***** with-face
;; :PROPERTIES:
;; :ID: ae757b22-27e1-4243-8da0-35c3a8e6ff65
;; :END:

(defmacro with-face! (string &rest props)
  "Return STR propertized with PROPS."
  `(propertize ,string 'face '(,@props)))

;; ***** helpers
;; :PROPERTIES:
;; :ID: c29bac50-32e4-4128-8446-6f4153d3a7a0
;; :END:

;; Eshell prompt function finds eshell section functions specified by
;; [[helpvar:eshell:enabled-sections][+eshell-enabled-sections]] and concatenates their results in order to
;; generate the body of the eshell prompt.

(defun eshell:acc (acc x)
  "Accumulator for evaluating and concatenating `eshell:enabled-sections'."
  (--if-let (funcall x)
      (if (s-blank? acc)
          it
        (concat acc eshell:sep it))
    acc))

(defun eshell:prompt-func ()
  "Generate the eshell prompt.
This function generates the eshell prompt by concatenating `eshell:header' with
valid `eshell:enabled-sections' and the `eshell-prompt-string'."
  (concat eshell:header
          (->> eshell:enabled-sections
               (mapcar (lambda (it) (void-symbol-intern 'eshell-prompt-- it)))
               (-filter #'fboundp)
               (-reduce-from #'eshell:acc ""))
          eshell-prompt-string))

;; ***** eshell components
;; :PROPERTIES:
;; :ID: c22a9cdb-9b9f-4f06-9c09-f330d454ab1f
;; :END:

;; This heading contains the parts that make up the eshell prompt. They are the
;; header, the separator, the section delimiter and, the meat of the prompt, the
;; actual eshell sections.

(defvar eshell:sep "\s|\s"
  "Separator between eshell sections.")

(defvar eshell:section-delim "\s"
  "Separator between an eshell section icon and form.")

(defvar eshell:header "\s"
  "Eshell prompt header.")

(defvar eshell:enabled-sections '(dir git)
  "List of enabled eshell sections.
Each element of the list is an abbreviated.")

;; This is a regex that matches your eshell prompt so that eshell knows what to
;; keep readonly and what not to.
(setq eshell-prompt-regexp (rx (*? anything) "-> "))
(setq eshell-prompt-string " -> ")

(setq eshell-prompt-function #'eshell:prompt-func)

;; **** text wrapping
;; :PROPERTIES:
;; :ID: 7d155cf8-a90c-4183-a9be-5ffdc266d82a
;; :END:

(defhook! enable-text-wrapping (eshell-mode-hook)
  "Enable text wrapping."
  (visual-line-mode +1)
  (set-display-table-slot standard-display-table 0 ?\ ))

;; **** fringes
;; :PROPERTIES:
;; :ID: 312652e5-9975-4241-b709-7ed5b8537202
;; :END:

(defhook! remove-fringes (eshell-mode-hook)
  "Remove fringes for eshell."
  (set-window-fringes nil 0 0)
  (set-window-margins nil 1 nil))

;; **** hide modeline
;; :PROPERTIES:
;; :ID: 6dc13e60-abd4-40d0-be15-55b11c1faeb2
;; :END:

(add-hook 'eshell-mode-hook #'hide-mode-line-mode)

;; *** shrink-path
;; :PROPERTIES:
;; :ID: eef8ea28-4de2-44ab-a09d-26f58c0a75ac
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     gitlab
;; :REPO:     "bennya/shrink-path.el"
;; :PACKAGE:  "shrink-path"
;; :LOCAL-REPO: "shrink-path.el"
;; :COMMIT:   "c14882c8599aec79a6e8ef2d06454254bb3e1e41"
;; :END:

(void-autoload #'shrink-path-file)

;; ** command-log-mode
;; :PROPERTIES:
;; :ID:       714699b3-1d02-4c0b-9898-d56f872af351
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "lewang/command-log-mode"
;; :PACKAGE:  "command-log-mode"
;; :LOCAL-REPO: "command-log-mode"
;; :COMMIT:   "af600e6b4129c8115f464af576505ea8e789db27"
;; :END:

;; [[https://github.com/lewang/command-log-mode][command-log-mode]] keeps track of all the commands you run and displays them to
;; you on a side window.

;; *** init
;; :PROPERTIES:
;; :ID:       4bb025cf-5933-46ed-abc6-7f1d40a7faa5
;; :END:

(void-autoload 'command-log-mode '(command-log-mode global-command-log-mode))

;; *** settings
;; :PROPERTIES:
;; :ID:       5cad9fe1-772e-46d7-88dd-09a5cdd366b0
;; :END:

(setq command-log-mode-auto-show t)
(setq command-log-mode-open-log-turns-on-mode nil)
(setq command-log-mode-is-global t)

;; ** recentf
;; :PROPERTIES:
;; :ID: f26bedb3-a172-4543-afd0-4c47f5872d15
;; :TYPE:     built-in
;; :END:

;; =recentf= is a built-in program that tracks the files you've opened recently
;; persistently. This is a great idea because these are the files you'll likely
;; revisit. In practice, I look at this list of files in addition to the buffers I
;; already have open using a [[f26bedb3-a172-4543-afd0-4c47f5872d15][completion-framework]]. Because of this I rarely
;; have to set out to look for a file with =dired=.

;; *** init
;; :PROPERTIES:
;; :ID:       3e25c6a3-6a0f-47a4-a63f-ceca6476cc59
;; :END:

(-each '(easymenu tree-widget timer) #'idle-require)

(before-call )

;; *** settings
;; :PROPERTIES:
;; :ID:       3b9ab738-de00-40d4-93be-b2c84bfaac5c
;; :END:

;; *** cleanup after save
;; :PROPERTIES:
;; :ID:       8b682202-b948-4e6a-ac64-089726f7d84e
;; :END:

;; *** recentf
;; :PROPERTIES:
;; :ID: 527f55e1-48c3-4d90-a2ef-9dd463e6d1fd
;; :END:

(use-feature! recentf
  :before-call find-file
  :idle-require easymenu tree-widget timer
  :commands recentf-open-files
  :config
  (void-add-advice #'recentf-save-list :before #'recentf-cleanup)
  (recentf-mode 1)
  :setq
  ;; (recentf-exclude . (list #'file-remote-p
  ;;                          "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\)$"
  ;;                          ;; ignore private Void temp files (but not all of them)
  ;;                          #'(lambda (file)
  ;;                              (-some-p (apply-partially #'file-in-directory-p file)
  ;;                               (list VOID-DATA-DIR)))))
  (recentf-max-menu-items . 0)
  (recentf-max-saved-items . 700)
  :custom
  (recentf-save-file (concat VOID-DATA-DIR "recentf"))
  (recentf-auto-cleanup 'never)
  (recentf-filename-handlers '(file-truename abbreviate-file-name)))

;; *** silence recentf
;; :PROPERTIES:
;; :ID: 15a971c4-b43a-4539-846e-70fe4e90d84a
;; :END:

(defadvice! silence-ouput (:around recentf-mode)
  "Shut up recentf."
  (shut-up! (apply <orig-fn> <args>)))

;; ** saveplace
;; :PROPERTIES:
;; :ID:       41cb3357-9b4b-4205-987d-ff72f9a35df3
;; :TYPE:     built-in
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID:       196ad7bd-f1eb-4de5-8a51-b5bef062fff9
;; :END:

;; *** recenter cursor
;; :PROPERTIES:
;; :ID:       dda57b64-b645-4eda-be54-9dda4af35404
;; :END:

(defadvice! recenter-on-load (:after-while save-place-find-file-hook)
  "Recenter on cursor when loading a saved place."
  (when buffer-file-name (ignore-errors (recenter))))

;; *** saveplace
;; :PROPERTIES:
;; :ID: 6da42724-3137-4d70-9aed-9a978357679f
;; :END:

;; As its name suggests, =save-place= is a built-in package that stores the buffer
;; location you left off at in a particular buffer. When you visit that buffer
;; again, you are taken to the location you left off. This is very convenient.

(void-load-after-call #'after-find-file #'saveplace)

(setq save-place-file (concat VOID-DATA-DIR "saveplace"))
(setq save-place-limit nil)

(after! save-place (save-place-mode))

;; ** bookmarks
;; :PROPERTIES:
;; :ID: e1a569f8-d27a-4e0c-924a-3b123c62b6a2
;; :TYPE:     built-in
;; :END:

;; [[info:emacs#Bookmarks][Bookmarks]] persistently store file locations. I use [[https://github.com/emacsmirror/bookmark-plus][bookmark-plus]] an increadibly
;; featureful bookmark extension package. Usually =xah lee= has good basic overviews
;; of topics on his site, check out the [[http://ergoemacs.org/emacs/bookmark.html — Emacs: Bookmark][one on bookmarks]]. I had already known about
;; =bookmark-plus=, however I hadn't really done anything with it. It was after I
;; read this [[https://emacs.stackexchange.com/questions/51853/retracing-steps-with-emacs-when-programming-exploring — search - Retracing steps with emacs (When programming /exploring) - Emacs Stack Exchange][question]].

(use-feature! bookmark
  :pre-setq
  (bookmark-default-file . (concat VOID-DATA-DIR "bookmarks"))
  (bookmark-save-flag . t))

;; ** elfeed
;; :PROPERTIES:
;; :ID:       e018eeba-2e0b-4d9e-b813-bb9c427098f5
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "skeeto/elfeed"
;; :PACKAGE:  "elfeed"
;; :LOCAL-REPO: "elfeed"
;; :COMMIT:   "7b2b6fadaa498fef2ba212a50da4a8afa2a5d305"
;; :END:

;; *** elfeed
;; :PROPERTIES:
;; :ID:       171f6599-052e-4a75-bc28-5b0314577424
;; :END:

;; **** elfeed
;; :PROPERTIES:
;; :ID: 7454a51a-cb50-47e4-b0ab-7ac493d9d09d
;; :END:

;; [[https://github.com/skeeto/elfeed][elfeed]] is a news feed reader. I can give it a set of rss-feeds to blogs I like
;; to read and then read the articles in emacs! Typically, you'd set the feeds via
;; [[helpvar:elfeed-feeds][elfeed-feeds]], but with [[https://github.com/remyhonig/elfeed-org][elfeed-org]] I can do it by specifying a set of org files
;; from which to read my feeds. The org file I use is [[file:.local/config/elfeed.org][elfeed.org]]. The [[helpvar:rmh-elfeed-org-tree-id][rmh-elfeed-org-tree-id]] is the
;; tags that =elfeed-org= will consider when checking for feeds. Note that it's
;; case-sensitive so consider this if your tags (like me) capitalized. The
;; [[helpvar:elfeed-search-filter][elfeed-search-filter]] specifies how far back to go when looking for newsfeed
;; posts. So if you have some infrequent blogs, you might have to go further back
;; in time to see older posts.

(void-autoload 'elfeed #'elfeed)

(setq elfeed-search-filter         "@1-year-old")
(setq elfeed-db-directory          (concat VOID-DATA-DIR "elfeed/db/"))
(setq elfeed-enclosure-default-dir (concat VOID-DATA-DIR "elfeed/enclosures/"))
(setq elfeed-show-entry-switch     #'pop-to-buffer)
(setq elfeed-show-entry-delete     #'elfeed-kill-buffer)
(setq shr-max-image-proportion     0.8)

;; **** elfeed org
;; :PROPERTIES:
;; :ID: e385b9b0-4681-4faa-9bfe-c759080ff5d9
;; :END:

(use-package! elfeed-org
  :after elfeed
  :demand t
  :setq
  (rmh-elfeed-org-files      . (list (concat VOID-ORG-DIR "elfeed.org")))
  (rmh-elfeed-org-tree-id    . "ELFEED")
  (rmh-elfeed-org-ignore-tag . "IGNORE")
  :config
  (let ((default-directory org-directory))
    (elfeed-org)))

;; ** file browsing
;; :PROPERTIES:
;; :ID: a8a9edfe-a4c0-4531-92d5-a59991f4af92
;; :END:

;; *** dired
;; :PROPERTIES:
;; :ID: 4021c260-0529-4a65-a3c4-4651cc33c6ae
;; :TYPE:     built-in
;; :END:

;; **** settings
;; :PROPERTIES:
;; :ID: 55109eeb-8e59-4d15-926e-fbe42ed28056
;; :END:

(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'top)
(setq dired-hide-details-hide-symlink-targets nil)
(setq dired-clean-confirm-killing-deleted-buffers nil)

;; **** sort directories first
;; :PROPERTIES:
;; :ID: 4b6c0ed8-dbf2-4a65-adcc-1ce326eac465
;; :END:

(defhook! dired:sort-directories-first (dired-after-readin-hook)
  "List directories first in dired buffers."
  (save-excursion
    (let (buffer-read-only)
      (forward-line 2) ;; beyond dir. header
      (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max))))
  (and (featurep 'xemacs)
       (fboundp 'dired-insert-set-properties)
       (dired-insert-set-properties (point-min) (point-max)))
  (set-buffer-modified-p nil))

;; **** Create non-existent directory
;; :PROPERTIES:
;; :ID: 66981d0c-fe40-4552-9f63-2c39a7d584d2
;; :END:

(defun dired:create-non-existent-directory-h ()
  "Automatically create missing directories when creating new file."
  (let ((parent-directory (file-name-directory buffer-file-name)))
    (when (and (not (file-exists-p parent-directory))
               (y-or-n-p (format "Directory `%s' does not exist! Create it?" parent-directory)))
      (make-directory parent-directory t))))

(after! dired
  (add-to-list 'find-file-not-found-functions 'dired:create-non-existent-directory-h nil #'eq))

;; *** ranger
;; :PROPERTIES:
;; :ID: 7504cab0-ddd9-4069-b6bb-9a5f3161cace
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "ralesi/ranger.el"
;; :PACKAGE:  "ranger"
;; :LOCAL-REPO: "ranger.el"
;; :COMMIT:   "caf75f0060e503af078c7e5bb50d9aaa508e6f3e"
;; :END:

;; [[github:ralesi/ranger.el][ranger]] is a file browser built on top of dired that seeks to emulate [[github:ranger/ranger][a VIM
;; inspired file manager]] of also called =ranger=.

;; **** make sure that =;= uses =M-x=
;; :PROPERTIES:
;; :ID:       c63911ca-6d26-4d7c-be76-246639fb6c7a
;; :END:

(general-def 'normal ranger-mode-map
  ";" #'execute-extended-command
  "u" #'dired-unmark)

;; **** general bindings
;; :PROPERTIES:
;; :ID:       f69d31ab-1385-498c-9423-8fb3d5e4e94e
;; :END:

(general-def 'normal ranger-mode-map
  "A" #'dired-do-find-regexp
  "C" #'dired-do-copy
  "B" #'dired-do-byte-compile
  "D" #'dired-do-delete
  "H" #'dired-do-hardlink
  "L" #'dired-do-load
  "M" #'dired-do-chmod
  "O" #'dired-do-chown
  "P" #'dired-do-print
  "Q" #'dired-do-find-regexp-and-replace
  "R" #'dired-do-rename
  "S" #'dired-do-symlink
  "T" #'dired-do-touch
  "X" #'dired-do-shell-command
  "Z" #'dired-do-compress
  "c" #'dired-do-compress-to
  "!" #'dired-do-shell-command
  "&" #'dired-do-async-shell-command)

;; **** entry
;; :PROPERTIES:
;; :ID: 2edf3f72-726f-4b31-9ff0-20e5e7d251b1
;; :END:

(void-autoload 'ranger (list #'deer #'ranger))

(after! ranger
  (setq ranger-override-dired-mode t)
  (setq ranger-cleanup-eagerly t)
  (setq ranger-cleanup-on-disable t)
  (setq ranger-omit-regexp "^.DS_Store$")
  (setq ranger-excluded-extensions
        '("mkv" "iso" "mp4"))
  (setq ranger-deer-show-details nil)
  (setq ranger-max-preview-size 10)
  (setq ranger-modify-header t)
  (setq ranger-hide-cursor t)
  (setq ranger-dont-show-binary t))

(setq image-dired-dir (concat VOID-DATA-DIR "image-dir"))
(setq dired-omit-verbose nil)

;; **** refresh contents
;; :PROPERTIES:
;; :ID:       cef37397-53aa-47e1-a519-ef56a311ae30
;; :END:

;; Ranger doesn't refresh the buffer after stuff like moving and pasting has
;; happend. It results in a very jarring display.

(defadvice! refresh-contents (:after ranger-paste dired-do-rename)
  "Refresh contents."
  (when (eq major-mode 'ranger-mode)
    (ranger-refresh)))

;; **** toggle dotfiles
;; :PROPERTIES:
;; :ID: 5b9b190c-b4a6-4834-b8c9-def16b0457ac
;; :END:

;; There's this wierd intermidiate stage between =hidden= and =format= called =prefer= in
;; which only some files are hidden. That's wierd, so I get rid of it.

(defadvice! toggle-between-two-only (:override ranger-toggle-dotfiles)
  "Show/hide dot-files."
  (interactive)
  (setq ranger-show-hidden
        (cl-case ranger-show-hidden
          (hidden 'format)
          (format 'hidden)))
  (ranger-setup))

;; **** silence window check
;; :PROPERTIES:
;; :ID: e9d83b37-1257-4d78-ae5f-863c4e7198d1
;; :END:

(defadvice! silence-output (:around ranger-window-check)
  "Silence `ranger-window-check'."
  (quiet! (apply <orig-fn> <args>)))

;; *** dired icons
;; :PROPERTIES:
;; :ID: 3b4561b3-18a5-475f-a8e8-e9cb7e213881
;; :END:

(use-package! all-the-icons-dired :hook ranger-mode-hook)

;; ** restart emacs
;; :PROPERTIES:
;; :ID: 2855f9fe-baac-43c4-9e7d-08c6fd118252
;; :END:

;; As it's name suggests [[https://github.com/iqbalansari/restart-emacs][restart-emacs]] provides a function (called ~restart-emacs~)
;; that restarts emacs. I haven't tested this in EXWM mode.

(void-autoload 'restart-emacs restart-emacs)

;; ** version control
;; :PROPERTIES:
;; :ID: d99a378c-449f-4a0d-9b88-dd77d5a41bb1
;; :END:

;; *** git-auto-commit-mode
;; :PROPERTIES:
;; :ID:       00a518e9-56ae-4c0b-b2cd-518fb4c5d201
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "ryuslash/git-auto-commit-mode"
;; :PACKAGE:  "git-auto-commit-mode"
;; :LOCAL-REPO: "git-auto-commit-mode"
;; :COMMIT:   "df07899acdb3f9c114b72fdab77107c924b3172c"
;; :END:

;; To avoid losing information. You should commit often in git--like every 10
;; seconds or so. Obviously doing this manually on the command line (or even on
;; [[id:d6088ed3-417a-44e8-822b-ce4743f497d0][magit]]) every time is a pain. This package commits your changes every time
;; you save your file--which for me is all the time because I use [[id:bd455e73-4035-49b9-bbdf-3d59d4906c97][super-save]].

;; **** TODO ensure
;; :PROPERTIES:
;; :ID:       bb97e0f6-4381-4191-a20e-229ef544d539
;; :END:

(void-system-ensure-for-package )

;; **** commands
;; :PROPERTIES:
;; :ID:       626a59e6-2426-4a75-ae3f-4e5a31a75014
;; :END:

;; **** settings
;; :PROPERTIES:
;; :ID:       8a46cee4-624c-4440-8b99-c6b34d356a6b
;; :END:

(setq gac-automatically-push-p nil)
(setq gac-ask-for-summary nil)
(setq gac-default-message #'gac:commit-message)
(setq gac-commit-additional-flag "-S")

;; **** toggle summary
;; :PROPERTIES:
;; :ID:       50641d0a-0908-4207-bcb9-8e7437e75159
;; :END:

;; **** auto-commit
;; :PROPERTIES:
;; :ID:       36b71eb7-b71d-47a0-ad0a-5d62825fffa3
;; :END:

(use-package! git-auto-commit-mode
  :system-ensure git
  :commands git-auto-commit-mode)

;; **** commit message
;; :PROPERTIES:
;; :ID:       3f0297a0-5929-4217-a109-545a2a010473
;; :END:

;; Committing often as I recommend will inevitably result with commits that are
;; many bits and pieces of a change. The idea is to then squash together all
;; related commits for the "polished" result. With this function I create "smart"
;; commit messages that take advantage of the org headline structure. This makes it
;; easy to go back and group commits which are related. Note that this function
;; fails when you have a change that spans across multiple headlines (such as the
;; replacement of a name throughout a document). This is something I plan to
;; address later.

(defun gac:commit-message (file)
  "Return the commit message for changes to FILE."
  (or (with-current-buffer (get-file-buffer file)
        (when (eq major-mode 'org-mode)
          (--> (org-ml-parse-subtree-at (point))
               (org-element-map it org-element-all-elements #'identity)
               (car it)
               (org-element-property :raw-value it)
               (format "Change at \"%s\".\n" it))))
      (format "Update %s" (f-base file))))

(void-load-before-call 'org-ml #'gac:commit-message)

;; *** magit
;; :PROPERTIES:
;; :ID:       d6088ed3-417a-44e8-822b-ce4743f497d0
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("lisp/magit" "lisp/magit*.el" "lisp/git-rebase.el" "Documentation/magit.texi" "Documentation/AUTHORS.md" "LICENSE" (:exclude "lisp/magit-libgit.el") "magit-pkg.el")
;; :HOST:     github
;; :REPO:     "magit/magit"
;; :PACKAGE:  "magit"
;; :LOCAL-REPO: "magit"
;; :COMMIT:   "87a63353df0ad8ac661ac1b93c59d40669b65ffc"
;; :END:

;; **** transient
;; :PROPERTIES:
;; :ID: baf64a0f-f9fa-4700-bebf-d996018f894f
;; :END:

(use-package! transient
  :setq
  (transient-default-level . 5)
  (transient-levels-file   . (concat VOID-DATA-DIR "transient/levels"))
  (transient-values-file   . (concat VOID-DATA-DIR "transient/values"))
  (transient-history-file  . (concat VOID-DATA-DIR "transient/history")))

;; **** magit
;; :PROPERTIES:
;; :ID: c8a37b6a-46c7-406e-8793-1186f14407e0
;; :END:

(use-package! magit
  :system-ensure git
  :commands magit-status magit-get-current-branch
  :idle-require f s with-editor git-commit package eieio lv transient
  :popup ("magit:"
          (display-buffer-at-bottom)
          (window-height . 0.5))
  :bind (:map magit-status-mode-map
         ([remap magit-mode-bury-buffer] . magit/quit))
  :setq
  (magit-completing-read-function . #'completing-read)
  (magit-revision-show-gravatars . '("^Author:     " . "^Commit:     "))
  (magit-diff-refine-hunk . t)
  (magit-auto-revert-mode . nil)
  :config
  (add-hook 'magit-popup-mode-hook #'hide-mode-line-mode))

;; **** quitting
;; :PROPERTIES:
;; :ID: 49088c3e-6d3a-41b7-aee4-f0bb34c71a0c
;; :END:

(defun magit/quit ()
  "Clean up magit buffers after quitting `magit-status'."
  (interactive)
  (let ((buffers (magit-mode-get-buffers)))
    (magit-restore-window-configuration)
    (mapc #'kill-buffer buffers)))

;; **** evil-magit
;; :PROPERTIES:
;; :ID: 02025227-8f1a-45aa-b40a-aabf43a3041c
;; :END:

(use-package! evil-magit
  :before-call magit-status
  :config
  (shut-up! (evil-magit-init))
  (setq evil-magit-state 'normal)
  (require 'evil-magit nil :no-error))

;; *** git-gutter
;; :PROPERTIES:
;; :ID: 96f0c876-533c-4b1a-a4c1-7b6c9bf58c03
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "emacsorphanage/git-gutter"
;; :PACKAGE:  "git-gutter"
;; :LOCAL-REPO: "git-gutter"
;; :COMMIT:   "db0e794fa97e4c902bbdf51b234cb68c993c71ae"
;; :END:

(use-package! git-gutter
  :system-ensure git
  :commands git-gutter-mode)

;; ** server                                                             :built-in:
;; :PROPERTIES:
;; :ID: b2bc973f-7d24-431c-90bc-4c1055a9fc0a
;; :END:

(when (display-graphic-p)
  (after! server
    (when-let* ((name (getenv "EMACS_SERVER_NAME")))
      (setq server-name name))
    (unless (server-running-p)
      (server-start))))

;; ** security
;; :PROPERTIES:
;; :ID: 313aedc2-c737-42b4-afaa-069ec33803aa
;; :END:

;; *** pass
;; :PROPERTIES:
;; :ID: 78e2ac6e-e465-482c-80bf-19ddfdaff31d
;; :END:

;; **** pass
;; :PROPERTIES:
;; :ID: 4ab61136-e27a-4bd1-bfd6-d99015819a1b
;; :END:

(use-package! pass
  :system-ensure pass
  :commands pass
  :setq
  (pass-username-field . "username"))

;; **** password-store
;; :PROPERTIES:
;; :ID:       52693bb0-ce70-4203-aafb-d459d8e047cb
;; :END:

;; ***** password-store
;; :PROPERTIES:
;; :ID:       8dd647c8-ebda-47e1-a8ba-0544c1b75d23
;; :END:

(use-package! password-store
  :ensure pass)

;; ***** get password
;; :PROPERTIES:
;; :ID: 52d9423c-32fb-4538-9e69-537e458b52d5
;; :END:

(defun pass/get-password ()
  "Copy password from entry into kill ring."
  (interactive)
  (require 'pass)
  (password-store-copy
   (completing-read "Copy password of entry: "
                    (password-store-list (password-store-dir))
                    nil
                    t)))

;; **** auth source pass
;; :PROPERTIES:
;; :ID: 2cd2fcee-e503-4430-9f37-43fecb12ac19
;; :END:

(use-package! auth-source-pass
  ;; (:after-hook pre-command-hook)
  :setq
  (auth-source-pass-filename . "~/.password-store")
  (auth-source-pass-port-separator . ":")
  :config (auth-source-pass-enable))

;; **** epa
;; :PROPERTIES:
;; :ID: 9eeb5714-a5dc-4f88-8992-0bd3a158878b
;; :END:

(use-feature! epa
  :setq
  (epg-gpg-program . "gpg2")
  (epa-pinentry-mode . 'loopback))

;; *** password-generator
;; :PROPERTIES:
;; :ID: 11bc4d9a-78df-4010-b81a-4a87b1443ea9
;; :END:

;; I'm sure that =pass= can generate custom passwords with some options or other, but
;; I do not like dealing with the command line. I want real elisp code please.

(use-package! password-generator
  :commands password-generator-simple password-generator-paranoid)

;; ** uuidgen
;; :PROPERTIES:
;; :ID: 9becd3bb-e74e-4644-a716-5b941fbbda50
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "kanru/uuidgen-el"
;; :PACKAGE:  "uuidgen"
;; :LOCAL-REPO: "uuidgen-el"
;; :COMMIT:   "b50e6fef2de4199a8f207b46588c2cb3890ddd85"
;; :END:

;; ** xr
;; :PROPERTIES:
;; :ID: 75c56163-9ce1-4726-969a-350fcc56395f
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacs-straight/xr"
;; :FILES:    ("*" (:exclude ".git"))
;; :PACKAGE:  "xr"
;; :LOCAL-REPO: "xr"
;; :COMMIT:   "3cdf1129474cebd223d9313eff52be936ba2556a"
;; :END:

;; This package is the inverse of =rx=. It takes a regular expression and returns the
;; =rx= representation.

(use-package! xr
  ;; :functions xr xr-pp
  )

;; ** pdf-tools
;; :PROPERTIES:
;; :ID:       63343f9d-6b19-43de-8302-d1344d571949
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    ("lisp/*.el" "README" ("build" "Makefile") ("build" "server") (:exclude "lisp/tablist.el" "lisp/tablist-filter.el") "pdf-tools-pkg.el")
;; :HOST:     github
;; :REPO:     "politza/pdf-tools"
;; :PACKAGE:  "pdf-tools"
;; :LOCAL-REPO: "pdf-tools"
;; :COMMIT:   "c510442ab89c8a9e9881230eeb364f4663f59e76"
;; :END:

;; *** pdf-tools
;; :PROPERTIES:
;; :ID: 163d8880-6a7d-4479-a7e4-e333e4f930da
;; :END:

(use-package! pdf-tools
  ;; :system-ensure (libpng zlib poppler-glib)
  :magic ("%PDF" . pdf-view-mode)
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :bind (:map pdf-view-mode-map
         ("j" . pdf-view-next-line-or-next-page)
         ("k" . pdf-view-previous-line-or-previous-page)))

;; *** epd-pdf-info-program
;; :PROPERTIES:
;; :ID:       25826061-a4a7-4f8a-8d3b-bdd5a80f70d0
;; :END:

(defadvice! build-pdf-into-program (:before pdf-view-mode)
  "Build the pdf-info program if it hasn't already been built."
  (unless (file-executable-p pdf-info-epdfinfo-program)
    (let ((wconf (current-window-configuration)))
      (pdf-tools-install)
      (message "Building epdfinfo, this will take a moment...")
      (--each (buffer-list)
        (with-current-buffer it
          (when (eq major-mode 'pdf-view-mode)
            (fundamental-mode))))
      (while compilation-in-progress
        ;; Block until `pdf-tools-install' is done
        (redisplay)
        (sleep-for 1))
      ;; HACK If pdf-tools was loaded by you opening a pdf file, once
      ;;      `pdf-tools-install' completes, `pdf-view-mode' will throw an error
      ;;      because the compilation buffer is focused, not the pdf buffer.
      ;;      Therefore, it is imperative that the window config is restored.
      (when (file-executable-p pdf-info-epdfinfo-program)
        (set-window-configuration wconf)))))

;; *** bindings
;; :PROPERTIES:
;; :ID:       506c568c-0473-4db6-82b6-cc91174b0ce4
;; :END:

(general-def 'normal pdf-view-mode-map
  "j" #'pdf-view-next-line-or-next-page
  "k" #'pdf-view-previous-line-or-previous-page
  "0" #'pdf-view-first-page
  "9" #'pdf-view-last-page
  "s" #'pdf-view-fit-width-to-window)

;; ** circe
;; :PROPERTIES:
;; :ID: 65495471-b9b4-47cc-aa85-5a6ead4c6538
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "jorgenschaefer/circe"
;; :PACKAGE:  "circe"
;; :LOCAL-REPO: "circe"
;; :COMMIT:   "d98986ce933c380b47d727beea8bad81bda65dc9"
;; :END:

;; ** persistent scratch
;; :PROPERTIES:
;; :ID:       ec2a603c-d68b-4811-88d8-2baeccdbba26
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID:       09e3ace6-80e2-4ebc-8f53-70c2f0145b31
;; :END:

;; *** peristent scratch
;; :PROPERTIES:
;; :ID: 8180d63f-1c0c-4a03-8dbc-9a99bf0c9f0b
;; :END:

(use-package! persistent-scratch
  :commands persistent-scratch-restore
  :setq (persistent-scratch-save-file . (concat VOID-DATA-DIR "scratch")))

;; ** sudo-edit
;; :PROPERTIES:
;; :ID:       38a9aec6-f826-4ebc-82f1-08ace40c2287
;; :END:

;; Sometimes I'll want edit files with root privileges. This package let's you edit
;; a file from another user (=root= by default). To use it you just call [[helpfn:sudo-edit][sudo-edit]]
;; on the buffer you'd like to edit.

(use-package! sudo-edit :commands sudo-edit)

;; ** yadm
;; :PROPERTIES:
;; :ID:       5783c785-cee0-4705-9b6b-eec5124f34a0
;; :END:

(defun void/dotfile-status ()
  (interactive)
  (require 'tramp)
  (add-to-list 'tramp-methods
               '("yadm"
                 (tramp-login-program "yadm")
                 (tramp-login-args (("enter")))
                 (tramp-login-env (("SHELL") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c"))))
  (magit-status "/yadm::"))

;; ** plantuml-mode
;; :PROPERTIES:
;; :ID:       5fb03277-998a-4a86-8ef7-f157a2642b49
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "skuro/plantuml-mode"
;; :PACKAGE:  "plantuml-mode"
;; :LOCAL-REPO: "plantuml-mode"
;; :COMMIT:   "5889166b6cfe94a37532ea27fc8de13be2ebfd02"
;; :END:

;; *** plantuml
;; :PROPERTIES:
;; :ID:       4c452dea-a404-4443-9ecc-189c940d201e
;; :END:

(use-package! plantuml-mode
  :system-ensure plantuml
  :init
  (after! org
    (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
    (org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t))))
  :setq
  (plantuml-executable-path . (executable-find "plantuml"))
  (plantuml-jar-path . "/usr/share/java/plantuml/plantuml.jar")
  (plantuml-default-exec-mode . 'jar)
  (org-plantuml-jar-path . "/usr/share/java/plantuml/plantuml.jar")
  (org-plantuml-executable-path . (executable-find "plantuml")))

;; ** super-save
;; :PROPERTIES:
;; :ID:       684e788c-6db9-4e6e-826b-d4871c0a3f90
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "bbatsov/super-save"
;; :PACKAGE:  "super-save"
;; :LOCAL-REPO: "super-save"
;; :COMMIT:   "886b5518c8a8b4e1f5e59c332d5d80d95b61201d"
;; :END:

;; The default auto-saving feature in emacs saves after a certain number of
;; characters are typed (see [[helpvar:auto-save-interval][auto-save-interval]]). The problem is that if you're in
;; the middle of typing and you've just hit the number of characters that trigger a
;; save, you could experience a lag, particularly if you are dealing with a large
;; file being saved. Instead of doing this, [[https://github.com/bbatsov/super-save][super-save]] saves buffers during idle
;; time and after certain commands like [[helpfn:switch-to-buffer][switch-to-buffer]] (see [[helpvar:super-save-triggers][super-save-triggers]]).
;; Note that this is the same strategy employed by [[id:c550f82a-9608-47e6-972b-eca460015e3c][idle-require]] to load packages.
;; Saving files like this reduces the likelihood of user delays.

;; *** TODO hooks
;; :PROPERTIES:
;; :ID:       18d884a6-5eab-4454-8806-d2d760b8ea0c
;; :END:

(void-add-hook 'emacs-startup-hook #'super-save-mode)

;; *** settings
;; :PROPERTIES:
;; :ID:       d4253696-58cc-49a4-b5de-e6458597352a
;; :END:

(setq super-save-idle-duration 5)
(setq super-save-auto-save-when-idle t)

;; ** goto-chg
;; :PROPERTIES:
;; :ID:       443c36b7-f75f-41cb-91e5-b474f7f5ff7d
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "emacs-evil/goto-chg"
;; :PACKAGE:  "goto-chg"
;; :LOCAL-REPO: "goto-chg"
;; :COMMIT:   "5c057c8623abadf7fd57ce625843435d231f2739"
;; :END:


;; * Languages
;; :PROPERTIES:
;; :ID: 51e3b9b1-0e74-431e-a113-fe6f86a4b22a
;; :END:

;; ** csv-mode
;; :PROPERTIES:
;; :ID:       b6f5b8b6-522e-4817-b3f8-ca6dbc50a2e2
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacs-straight/csv-mode"
;; :FILES:    ("*" (:exclude ".git"))
;; :PACKAGE:  "csv-mode"
;; :LOCAL-REPO: "csv-mode"
;; :COMMIT:   "635337407c44c1c3e9f7052afda7e27cf8a05c14"
;; :END:

;; *** align
;; :PROPERTIES:
;; :ID:       c8999694-08ec-4882-96fa-7e2f09204518
;; :END:

(void-add-hook 'csv-mode-hook #'csv-align-mode)

;; *** add to mode list
;; :PROPERTIES:
;; :ID:       bb7d7cc9-8ee0-4e07-ae44-074305098a85
;; :END:


;; *** TODO csv
;; :PROPERTIES:
;; :ID:       e5b591e4-a261-4a36-90d0-b370cda73a47
;; :END:

(use-package! csv-mode
  :mode "\\.csv\\'"
  :hook (csv-mode-hook . csv-align-mode))

;; ** lisp
;; :PROPERTIES:
;; :ID: 9b7ec12e-e62b-447a-90dd-2fef0cc952ad
;; :END:

;; *** sly
;; :PROPERTIES:
;; :ID: 2e4ddfa7-2243-458c-8045-ef4a9f652d9c
;; :END:

;; [[https://github.com/joaotavora/sly][sly]] is an alternative to [[https://github.com/slime/slime][slime]].

(use-package! sly
  :system-ensure sbcl
  :setq (inferior-lisp-program . "/usr/bin/sbcl"))

;; *** clojure
;; :PROPERTIES:
;; :ID: 7941233e-6524-4da1-b6d9-05faf8991824
;; :END:

;; [[https://github.com/clojure-emacs/cider][cider]] is a repl for clojure.

(use-package! cider
  :system-ensure clojure
  :commands cider)

;; *** emacs lisp
;; :PROPERTIES:
;; :ID: f90ab909-dd53-41ca-bc77-849fb89ac6c8
;; :END:

;; **** printing
;; :PROPERTIES:
;; :ID: 954a5a72-1db9-4a40-b9cb-e9099bfd0f83
;; :END:

(setq eval-expression-print-length nil)
(setq eval-expression-print-level nil)

;; **** electric-pair
;; :PROPERTIES:
;; :ID: 1febf5ab-f545-4a72-97ef-892740575a3a
;; :END:


;; **** fix elisp indentation
;; :PROPERTIES:
;; :ID: aa7f846f-8802-4c75-88d8-a438e2f63ccd
;; :END:

;; A problem with elisp indentation is indents quoted lists the way functions
;; should be indented. It has been discussed in at least three stackoverflow
;; questions [[https://emacs.stackexchange.com/questions/10230/how-to-indent-keywords-aligned/10233#10233][here]], [[https://stackoverflow.com/questions/49222433/align-symbols-in-plist][here]] and [[https://stackoverflow.com/questions/22166895/customize-elisp-plist-indentation][here]]. In all these questions the solutions have not
;; been satisfactory. Some of them recommend using [[helpfn:common-lisp-indent-function][common-lisp-indent-function]] as
;; the value of [[helpvar:lisp-indent-function][lisp-indent-function]]. This works for indenting a quoted list
;; properly, but at the expense of changing the way that many other elisp forms are
;; indented. Common Lisp's indentation is different from Elisp's. Others recommend
;; using [[https://github.com/Fuco1/.emacs.d/blob/af82072196564fa57726bdbabf97f1d35c43b7f7/site-lisp/redef.el#L12-L94][Fuco1's lisp indent function hack]]. This also is not ideal. For one thing it
;; only works for quoted lists with keywords but not generic symbols. Another thing
;; is that the change should really be occurring in [[helpfn:calculate-lisp-indent][calculate-lisp-indent]].
;; ~calculate-lisp-indent~ is a function that returns what the indentation should be
;; for the line at point. Since Fuco1 did not modify ~calculate-lisp-indent~ the
;; *wrong* indentation still returned by this function and the modified
;; ~lisp-indent-function~ just cleans up the mess. Better is just fixing the source
;; of the problem. You can check out a more in-depth explanation looking at my
;; [[https://www.reddit.com/r/emacs/comments/d7x7x8/finally_fixing_indentation_of_quoted_lists/][reddit-post]] or looking at an answer I gave to [[https://emacs.stackexchange.com/questions/10230/how-to-indent-keywords-aligned][this question]].

(defadvice! properly-calculate-indent (:override calculate-lisp-indent)
  "Add better indentation for quoted and backquoted lists.
The change to this function."
  (defvar calculate-lisp-indent-last-sexp)
  (save-excursion
    (beginning-of-line)
    (let ((indent-point (point))
          state
          ;; setting this to a number inhibits calling hook
          (desired-indent nil)
          (retry t)
          calculate-lisp-indent-last-sexp containing-sexp)
      (cond ((or (markerp <parse-start>) (integerp <parse-start>))
             (goto-char <parse-start>))
            ((null <parse-start>) (beginning-of-defun))
            (t (setq state <parse-start>)))
      (unless state
        ;; Find outermost containing sexp
        (while (< (point) indent-point)
          (setq state (parse-partial-sexp (point) indent-point 0))))
      ;; Find innermost containing sexp
      (while (and retry
                  state
                  (> (elt state 0) 0))
        (setq retry nil)
        (setq calculate-lisp-indent-last-sexp (elt state 2))
        (setq containing-sexp (elt state 1))
        ;; Position following last unclosed open.
        (goto-char (1+ containing-sexp))
        ;; Is there a complete sexp since then?
        (if (and calculate-lisp-indent-last-sexp
                 (> calculate-lisp-indent-last-sexp (point)))
            ;; Yes, but is there a containing sexp after that?
            (let ((peek (parse-partial-sexp calculate-lisp-indent-last-sexp
                                            indent-point 0)))
              (if (setq retry (car (cdr peek))) (setq state peek)))))
      (if retry
          nil
        ;; Innermost containing sexp found
        (goto-char (1+ containing-sexp))
        (if (not calculate-lisp-indent-last-sexp)
            ;; indent-point immediately follows open paren.
            ;; Don't call hook.
            (setq desired-indent (current-column))
          ;; Find the start of first element of containing sexp.
          (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
          (cond ((looking-at "\\s(")
                 ;; First element of containing sexp is a list.
                 ;; Indent under that list.
                 )
                ((> (save-excursion (forward-line 1) (point))
                    calculate-lisp-indent-last-sexp)
                 ;; This is the first line to start within the containing sexp.
                 ;; It's almost certainly a function call.
                 (if (or
                      (= (point) calculate-lisp-indent-last-sexp)

                      (when-let (after (char-after (1+ containing-sexp)))
                        (char-equal after ?:))

                      (when-let (point (char-before containing-sexp))
                        (char-equal point ?'))

                      (let ((quoted-p nil)
                            (point nil)
                            (positions (nreverse (butlast (elt state 9)))))
                        (while (and positions (not quoted-p))
                          (setq point (pop positions))
                          (setq quoted-p
                                (or
                                 (and (char-before point)
                                      (char-equal (char-before point) ?'))
                                 (save-excursion
                                   (goto-char (1+ point))
                                   (looking-at-p "quote[\t\n\f\s]+(")))))
                        quoted-p))
                     ;; Containing sexp has nothing before this line
                     ;; except the first element.  Indent under that element.
                     nil
                   ;; Skip the first element, find start of second (the first
                   ;; argument of the function call) and indent under.
                   (progn (forward-sexp 1)
                          (parse-partial-sexp (point)
                                              calculate-lisp-indent-last-sexp
                                              0 t)))
                 (backward-prefix-chars))
                (t
                 ;; Indent beneath first sexp on same line as
                 ;; `calculate-lisp-indent-last-sexp'.  Again, it's
                 ;; almost certainly a function call.
                 (goto-char calculate-lisp-indent-last-sexp)
                 (beginning-of-line)
                 (parse-partial-sexp (point) calculate-lisp-indent-last-sexp
                                     0 t)
                 (backward-prefix-chars)))))
      ;; Point is at the point to indent under unless we are inside a string.
      ;; Call indentation hook except when overridden by lisp-indent-offset
      ;; or if the desired indentation has already been computed.
      (let ((normal-indent (current-column)))
        (cond ((elt state 3)
               ;; Inside a string, don't change indentation.
               nil)
              ((and (integerp lisp-indent-offset) containing-sexp)
               ;; Indent by constant offset
               (goto-char containing-sexp)
               (+ (current-column) lisp-indent-offset))
              ;; in this case calculate-lisp-indent-last-sexp is not nil
              (calculate-lisp-indent-last-sexp
               (or
                ;; try to align the parameters of a known function
                (and lisp-indent-function
                     (not retry)
                     (funcall lisp-indent-function indent-point state))
                ;; If the function has no special alignment
                ;; or it does not apply to this argument,
                ;; try to align a constant-symbol under the last
                ;; preceding constant symbol, if there is such one of
                ;; the last 2 preceding symbols, in the previous
                ;; uncommented line.
                (and (save-excursion
                       (goto-char indent-point)
                       (skip-chars-forward " \t")
                       (looking-at ":"))
                     ;; The last sexp may not be at the indentation
                     ;; where it begins, so find that one, instead.
                     (save-excursion
                       (goto-char calculate-lisp-indent-last-sexp)
                       ;; Handle prefix characters and whitespace
                       ;; following an open paren.  (Bug#1012)
                       (backward-prefix-chars)
                       (while (not (or (looking-back "^[ \t]*\\|([ \t]+"
                                                     (line-beginning-position))
                                       (and containing-sexp
                                            (>= (1+ containing-sexp) (point)))))
                         (forward-sexp -1)
                         (backward-prefix-chars))
                       (setq calculate-lisp-indent-last-sexp (point)))
                     (> calculate-lisp-indent-last-sexp
                        (save-excursion
                          (goto-char (1+ containing-sexp))
                          (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
                          (point)))
                     (let ((parse-sexp-ignore-comments t)
                           indent)
                       (goto-char calculate-lisp-indent-last-sexp)
                       (or (and (looking-at ":")
                                (setq indent (current-column)))
                           (and (< (line-beginning-position)
                                   (prog2 (backward-sexp) (point)))
                                (looking-at ":")
                                (setq indent (current-column))))
                       indent))
                ;; another symbols or constants not preceded by a constant
                ;; as defined above.
                normal-indent))
              ;; in this case calculate-lisp-indent-last-sexp is nil
              (desired-indent)
              (t
               normal-indent))))))

;; **** highlight-quoted
;; :PROPERTIES:
;; :ID: afacf700-86a9-4c1b-9062-7a28c11dcf69
;; :END:

;; [[https://github.com/Fanael/highlight-quoted][highlight-quoted]] highlights quotes, backticks and.

(use-package! highlight-quoted
  :hook emacs-lisp-mode)

;; **** buttercup
;; :PROPERTIES:
;; :ID: 228fb805-620d-4519-822f-f633540f7b58
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "bin" "buttercup-pkg.el")
;; :HOST:     github
;; :REPO:     "jorgenschaefer/emacs-buttercup"
;; :PACKAGE:  "buttercup"
;; :LOCAL-REPO: "emacs-buttercup"
;; :COMMIT:   "f6f93353405cda51ad2778ae9247f77265b7cbfb"
;; :END:

;; [[https://github.com/jorgenschaefer/emacs-buttercup][buttercup]] is an emacs debugging suite.

;; **** outorg
;; :PROPERTIES:
;; :ID: a3461ce0-8c5d-4bea-950e-b18ea6422672
;; :END:

;; Outorg adds overlays to make an org buffer look more readable. I do not want
;; these overlays.

(use-package! outorg
  ;; TODO: should be changed to `:functions'
  :commands outorg-convert-back-to-code outorg-convert-to-org)

(defadvice! dont-add-overlays (:around outorg-wrap-source-in-block)
  (cl-letf (((symbol-function #'overlay-put) #'ignore))
    (apply <orig-fn> <args>)))

;; **** outshine
;; :PROPERTIES:
;; :ID: ffeddf0d-aa29-473f-b73c-d94971d91da9
;; :END:

;; [[https://github.com/alphapapa/outshine][outshine]] is a clever package that tries to make elisp mode more like org mode.
;; It colors certain comments like org headings, and adds function for convertion
;; from elisp to org. My [[helpvar:VOID-INIT-FILE][void-init-file]] is written with =outshine= in mind.

(use-package! outshine
  :hook emacs-lisp-mode
  :config
  (general-def '(normal) emacs-lisp-mode-map
    "TAB" #'outline-toggle-children))

;; **** macrostep
;; :PROPERTIES:
;; :ID:       ecf2ab24-c3a0-4a72-8ba3-b5c1ed4a3f0a
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "joddie/macrostep"
;; :PACKAGE:  "macrostep"
;; :LOCAL-REPO: "macrostep"
;; :COMMIT:   "424e3734a1ee526a1bd7b5c3cd1d3ef19d184267"
;; :END:

;; ***** commands
;; :PROPERTIES:
;; :ID:       c6a0b556-8a8a-4abf-a920-87fff7ab078d
;; :END:

;; ***** macrostep
;; :PROPERTIES:
;; :ID: 81e59dcc-7e23-4dd1-9917-06f0ab59f2a6
;; :END:

;; [[https://github.com/joddie/macrostep][macrostep]]

(use-package! macrostep
  :commands
  macrostep-expand
  macrostep-collapse
  macrostep-collapse-all
  :init (define-localleader-key!
          :infix "m"
          :keymaps 'emacs-lisp-mode-map
          "e" (list :def #'macrostep-expand :wk "expand")
          "c" (list :def #'macrostep-collapse :wk "collapse")
          "C" (list :def #'macrostep-collapse-all :wk "collapse all")))

;; *** hy
;; :PROPERTIES:
;; :ID: 6b62fbdd-448b-4b69-82f8-1e1231a10c3e
;; :END:

(add-to-list 'auto-mode-alist '("\\.hy\\'" . hy-mode))

;; ** markdown-mode
;; :PROPERTIES:
;; :ID: 9d684855-961a-4294-8b90-44d2796526e2
;; :END:

;; I'm adding [[https://github.com/jrblevin/markdown-mode][markdown-mode]] so I can see =README= files.

(use-package! markdown-mode :mode "\\.md\\'")

;; ** org
;; :PROPERTIES:
;; :ID: 7fd3bb4f-354c-4427-914c-9de2223f5646
;; :END:

;; Org mode introduces an elegant way of dealing with different languages in one
;; file. In an org file the background language is Org's own markup language that's
;; typically composed mostly of outline headlines. In the org markup language you
;; can embed multiple different languages in [[info:org#Editing Source Code][source blocks]]. Additionally, org
;; mode provides a library of functions for dealing with these files. This includes
;; things like executing (or evaluating) source blocks, moving headlines to other
;; files, or even converting an org mode document into another format. As the name
;; =org= suggests, org is tool that's used for organization of data.

;; *** do the right thing after jumping to headline
;; :PROPERTIES:
;; :ID:       2ca61454-a0ca-47b3-8622-91d7969653da
;; :END:

;; When I search for a headline with [[helpfn:void/goto-line][void/goto-line]] or [[helpfn:void/goto-headline][void/goto-headline]] or even their
;; counsel equivalents, the proper headlines aren't automatically revealed.

;; [[screenshot:][This]] is what headline structure looks after using counsel/ivy's [[helpfn:swiper][swiper]] to find
;; the word =void/goto-line= in my emacs. You can see that only the headline that has
;; the target word is revealed but it's parents are (akwardly) hidden. I never want
;; headlines to be unfolded like this.

;; **** show branch
;; :PROPERTIES:
;; :ID:       d95fab52-7d8f-439f-9221-188490f4ad5f
;; :END:

;; This shows all headlines that make up the branch of the current headine and
;; their children. This is the typical behavior you would expect in any outlining
;; program.

(defun org:show-branch ()
  "Reveal the current org branch.
Show all of the current headine's parents and their children. This includes this
headline."
  (let (points)
    (save-excursion
      (org-back-to-heading t)
      (push (point) points)
      (while (org-up-heading-safe)
        (push (point) points))
      (--each points
        (goto-char it)
        (outline-show-children)
        (outline-show-entry)))))

;; **** show branch after jumping to point
;; :PROPERTIES:
;; :ID:       251e5df0-0a7d-4bf9-8fd9-69991d89a074
;; :END:

;; Note that I use points to store the heading points and go back to them inreverse
;; order. This is important because org does not unfold headlines properly if you
;; start from an invisible subheading.

;; Notably, I do not try to conserve the return value of =void/goto-line= or
;; =void/jump-to-headline= because these functions are and should only be used for
;; their side-effects.

(defadvice! show-current-branch-in-org-mode (:after void/goto-line org/goto-headline)
  "Properly unfold nearby headlines and reveal current headline."
  (when (eq major-mode 'org-mode)
    (org:show-branch)))

;; *** structures
;; :PROPERTIES:
;; :ID: 85ac0a35-4e44-41e6-a1f1-54698cb86212
;; :END:

;; **** todo-keywords
;; :PROPERTIES:
;; :ID: a32da379-654e-4b1a-83f4-cf9e4003d578
;; :END:

;; ***** todo keywords
;; :PROPERTIES:
;; :ID: 2f0459d4-9afd-4fd9-bdba-c0a3dc993963
;; :END:

(after! org
  (setq org-todo-keywords
        '((sequence "TODO" "NEXT" "STARTED" "|" "DONE")
          (sequence "QUESTION" "NEXT" "INVESTIGATING" "|" "ANSWERED")
          (sequence "|" "PAUSED")
          (sequence "|" "CANCELLED"))))

;; ***** return todo-keywords
;; :PROPERTIES:
;; :ID: 38385aee-1326-46d8-9eef-3bfa2e57c0cc
;; :END:

;; Knowing what the exact todo-keywords are is important so that I know exactly
;; when headline contents begin.

(defun org:todo-keywords ()
  "Return list of all TODO keywords."
  (--filter (and (stringp it) (not (string= "|" it)))
            (flatten-list org-todo-keywords)))

;; ***** heading start
;; :PROPERTIES:
;; :ID: 0ebf90e8-cd14-4364-b26a-da6676b29089
;; :END:

(defun org:heading-start-regexp ()
  "Compute regexp for heading start."
  (rx-to-string `(: bol (1+ "*") space (opt (or ,@(org:todo-keywords)) space))))

(defun org:heading-goto-start ()
  "Go to first letter of headline."
  (let (case-fold-search)
    (beginning-of-line)
    (re-search-forward (org:heading-start-regexp)
                       (line-end-position))))

;; **** return
;; :PROPERTIES:
;; :ID: c161f1b0-dbc0-4240-8102-69e95f3fd62f
;; :END:

(defun org/dwim-return ()
  "Do what I mean."
  (interactive)
  (cond
   (and (org-at-heading-p)
        (looking-at-p (rx (* (or "\s" "\t"))
                          (opt (1+ ":" (1+ letter)) ":") eol)))
   (org/insert-heading-below)
   (t
    (call-interactively #'org-return))))

;; **** org-heading-folded-p
;; :PROPERTIES:
;; :ID: 919b2b6e-2c43-4fd5-87cc-cfc62cf75405
;; :END:

(defun org:heading-folded-p ()
  "Return t if an current heading is folded."
  (outline-invisible-p (line-end-position)))

;; **** preserve point
;; :PROPERTIES:
;; :ID: 52781cc9-e1ca-4618-aa1b-6845494b5dc6
;; :END:

;; If possible org commands should preserve =point=. If this isn't possible (ie. when
;; deleting a subtree with), then should leave point at a place that is easy to
;; predict and convenient (as opposed to a random location).

;; ***** start on beginning of first heading
;; :PROPERTIES:
;; :ID: 81732dde-85f7-4336-a9fd-351d8f74671f
;; :END:

;; It looks nice if when I'm on a heading when I first enter an org file.

(defhook! goto-first-heading (org-mode-hook)
  "Go to first heading when entering an org-mode file."
  (when (org-at-heading-p)
    (beginning-of-line)
    (org:heading-goto-start)))

;; ***** fix bug with next visible heading
;; :PROPERTIES:
;; :ID: 9a3759e8-8928-47cb-97c9-9ce5ee673cba
;; :END:

;; [[helpfn:outline-next-visible-heading][outline-next-visible-heading]] continues to =EOB= after reaching the last visible
;; heading. It should just stop at the last visible heading. This advice checks to
;; see if it's gone farther than it should have and in that case goes back.

(defadvice! dont-end-at-eob (:around outline-next-visible-heading)
  "Fix bug where the next heading moves past last visible heading."
  (apply <orig-fn> <args>)
  (when (eobp) (apply #'outline-previous-visible-heading <args>)))

;; ***** go to proper point after refile
;; :PROPERTIES:
;; :ID: 591045df-8d3e-4ff7-b4bc-c949222a0717
;; :END:

(defadvice! end-at-headline-start (:after org-refile org-cut-subtree org-copy-subtree)
  "After running body end at headline start."
  (when (org-at-heading-p) (org:heading-goto-start)))

;; **** commands
;; :PROPERTIES:
;; :ID: 86f0b9be-0033-46bd-8d02-7e506fe73ead
;; :END:

;; ***** org choose capture template
;; :PROPERTIES:
;; :ID:       fc2cf818-48c4-4e52-8356-56106623ad77
;; :END:

(defun org/choose-capture-template ()
  "Select capture template."
  (interactive)
  (let (prefixes)
    (alet (mapcan (lambda (x)
                    (let ((x-keys (car x)))
                      ;; Remove prefixed keys until we get one that matches the current item.
                      (while (and prefixes
                                  (let ((p1-keys (caar prefixes)))
                                    (or
                                     (<= (length x-keys) (length p1-keys))
                                     (not (string-prefix-p p1-keys x-keys)))))
                        (pop prefixes))
                      (if (> (length x) 2)
                          (let ((desc (mapconcat #'cadr (reverse (cons x prefixes)) " | ")))
                            (list (format "%-5s %s" x-keys desc)))
                        (push x prefixes)
                        nil)))
                  (-> org-capture-templates
                      (org-capture-upgrade-templates)
                      (org-contextualize-keys org-capture-templates-contexts)))
      (funcall #'org-capture nil (car (split-string (completing-read "Capture template: " it nil t)))) )))

;; ***** org choose tags
;; :PROPERTIES:
;; :ID:       b8b0c3a2-2cdc-424f-9cd6-ef3ad3d1512c
;; :END:

(defun org/choose-tags ()
  "Select tags to add to headline."
  (interactive)
  (let* ((current (org-get-tags (point)))
         (selected (->> (org-get-buffer-tags)
                        (completing-read-multiple "Select org tag(s): "))))
    (alet (-distinct (append (-difference current selected)
                             (-difference selected current)))
      (message "%S" it)
      (org-set-tags it))))

;; ***** org outline headings
;; :PROPERTIES:
;; :ID:       143e55e1-3900-48fd-a30a-18923dc4bd98
;; :END:

;; Annoyingly, the first time you call org/goto-headline, a prompt from
;; =org-goto-location= is triggered and somehow the call to =org/goto-headline= is
;; canceled. I had a damingly difficult time figuring out where exactly this
;; happens (and I didn't actually figure it out). However, overriding
;; =org-goto-location= seems to work. If I end up having some problems with other
;; calls to =org-goto-location=, I'll advise it only within the body. Or even better
;; create a transient advice that only happens the first time the function is
;; called.

(advice-add #'org-goto-location :override
            (lambda (&rest _) (call-interactively #'org/goto-headline)))

(defun org/goto-headline ()
  "Jump to an org heading using selectrum."
  (interactive)
  (require 'org-refile)
  (let ((selectrum-should-sort-p nil)
        (org-outline-path-complete-in-steps nil)
        (org-goto-interface 'outline-path-completion))
    (org-goto)))

;; ***** dwim
;; :PROPERTIES:
;; :ID: 93a6e45c-b23b-4639-9e1c-9f1aef0fb95a
;; :END:

;; ****** insert
;; :PROPERTIES:
;; :ID: 1b8ccbb8-2614-4d2e-ab7c-e8bd23c2c02d
;; :END:

(defun org/dwim-insert-elisp-block ()
  "Insert elisp block."
  (interactive)
  (save-excursion
    (unless (org-at-heading-p)
      (org-back-to-heading))
    (org-end-of-subtree)
    (goto-char (line-end-position))
    (insert (concat "\n\n"
                    "#+begin_src emacs-lisp"
                    "\n"
                    "#+end_src"))
    (forward-line -1)))

;; ****** eval
;; :PROPERTIES:
;; :ID: e804805a-ba96-41d0-aa6f-6756c65e9abf
;; :END:

(defun org/dwim-eval-block ()
  "Eval block contents."
  (interactive)
  (unless (org-at-heading-p)
    (user-error "Not in source block"))
  (save-window-excursion
    (org-babel-execute-subtree)))

;; ****** next-line
;; :PROPERTIES:
;; :ID: d8d118a7-78e8-4602-81b3-17fd1d8ab79c
;; :END:

(defun org/dwim-next-line (&optional backward)
  "Go to the start of the next heading.
If DIR is a negative integer, go the opposite direction: the start of the
  previous heading."
  (interactive)
  (outline-next-visible-heading (if backward -1 1))
  (when (org-at-heading-p)
    (org:heading-goto-start)))

;; ****** previous-line
;; :PROPERTIES:
;; :ID: e7562921-77ca-4d90-be57-1d586ec26ee5
;; :END:

(defun org/dwim-previous-line (&optional forward)
  (interactive)
  (funcall #'org/dwim-next-line (not forward)))

;; ****** up-heading
;; :PROPERTIES:
;; :ID: 1f25d3b0-7280-4012-94b5-b0fea2f686b3
;; :END:

(defun org/dwim-up-heading ()
  ""
  (interactive)
  (condition-case nil
      (progn (outline-up-heading 1)
             (outline-hide-subtree)
             (outline-show-children)
             (org:heading-goto-start))
    (error
     (unless (outline-invisible-p (line-end-position))
       (outline-hide-subtree))
     (org:heading-goto-start))))

;; ***** jump to heading                                                      :avy:
;; :PROPERTIES:
;; :ID: 3c396b33-437c-410f-aff6-2106ade42621
;; :END:

(defun org/avy-goto-headline ()
  "Jump to the beginning of a visible heading using `avy'."
  (interactive)
  (org-back-to-heading)
  (avy-jump (rx bol (1+ "*") space (group nonl))
            :beg (window-start)
            :end (window-end)
            :pred `(lambda () (/= (1+ ,(point)) (point)))
            :action (lambda (point) (goto-char point)
                      (org:heading-goto-start))
            :group 1))

;; ***** dwim jump to heading
;; :PROPERTIES:
;; :ID: 7ad9d757-57ba-4537-821f-8beae57f39eb
;; :END:

(defun org/dwim-jump-to-heading ()
  ""
  (interactive)
  (let ((origin (point)))
    (if (and (org/avy-goto-headline)
             (org:heading-folded-p))
        (progn (outline-toggle-children)
               (org:scroll-window-to-top))
      (goto-char origin))))

;; ***** inserting
;; :PROPERTIES:
;; :ID: e99abeff-328b-48e4-aebb-00db34fa98e8
;; :END:

;; In my eyes, many Org functions are unnecessarily complicated and long. Often they
;; need to perform a simple task (like inserting a heading) but lose their
;; fundamental purpose in their inclusion of numerous obscure and opinionated
;; options. For this reason I wrote my own insert heading functions.

;; ****** newlines between headings
;; :PROPERTIES:
;; :ID: e0dcf718-120c-488d-9d37-96243132bf0b
;; :END:

(defvar org:newlines-between-headings "\n\n"
  "Number of newlines between headings.")

;; ****** heading above
;; :PROPERTIES:
;; :ID: 6c227dea-e10b-4f86-a01b-5d223d18e3a4
;; :END:

(defun org/insert-heading-above (&optional below)
  "Insert a heading above the current heading."
  (interactive)
  (funcall #'org/insert-heading-below (not below)))

;; ****** heading below
;; :PROPERTIES:
;; :ID: b059a431-e29c-4f2c-ab5e-8d2d02636405
;; :END:

(defun org/insert-heading-below (&optional above)
  "Insert heading below."
  (interactive)
  (let* ((on-heading-p (ignore-errors (org-back-to-heading)))
         (newlines org:newlines-between-headings)
         (level (or (org-current-level) 1))
         (heading (concat (make-string level ?*) "\s")))
    (cond ((not on-heading-p)
           (insert heading))
          (above
           (goto-char (line-beginning-position))
           (insert heading)
           (save-excursion (insert newlines)))
          (t ; below
           (org-end-of-subtree)
           (insert (concat newlines heading))))
    (run-hooks 'org-insert-heading-hook)))

;; ****** subheading
;; :PROPERTIES:
;; :ID: cf910dcf-6250-4b6a-80d5-63ac457d4a81
;; :END:

(defun org/insert-subheading ()
  "Insert subheading below current heading."
  (interactive)
  (org/insert-heading-below)
  (org-demote))

;; *** source blocks
;; :PROPERTIES:
;; :ID:       480f4384-b560-4a47-978d-0c8058519294
;; :END:

;; **** source blocks
;; :PROPERTIES:
;; :ID: 2bb1b8ef-f41c-4dfa-8e47-549326f7ce05
;; :END:

;; Many of these =org-src= variables are not very applicable to me anymore because I
;; use =edit-indirect= to edit source blocks.
;; :PROPERTIES:
;; :ID: 3329768f-2669-43be-ad85-da2239082cc2
;; :END:

(use-feature! org-src
  :popup ("\\*Org Src"
          (display-buffer-at-bottom)
          (window-height . 0.5))
  :setq
  (org-edit-src-persistent-message . nil)
  (org-src-window-setup . 'plain)
  (org-src-fontify-natively . t)
  (org-src-ask-before-returning-to-edit-buffer . nil)
  (org-src-preserve-indentation . t)
  (org-src-tab-acts-natively . t)
  (org-confirm-babel-evaluate . nil)
  (org-babel-default-header-args . '((:session . "none")
                                     (:results . "silent")
                                     (:exports . "code")
                                     (:cache . "no")
                                     (:initeb . "no")
                                     (:hlines . "no")
                                     (:tangle . "yes"))))

;; **** edit source blocks
;; :PROPERTIES:
;; :ID:       a0e1c9d6-9071-4c6f-abc4-d2e9f011be03
;; :END:

(defun org/dwim-edit-source-block ()
  "Edit source block in current heading.
Point does not have to be on source block."
  (interactive)
  (let ((org-src-window-setup 'plain))
    (org-back-to-heading)
    (org-next-block 1)
    (org-edit-src-code)))

;; *** org-mode
;; :PROPERTIES:
;; :ID: c1c5724e-028a-42a5-a982-28d57203b335
;; :END:

(use-package! org
  :idle-require
  calendar find-func format-spec org-macs org-compat org-faces org-entities
  org-list org-pcomplete org-src org-footnote org-macro ob org org-agenda
  org-capture
  :setq
  (org-directory . VOID-ORG-DIR)
  (org-archive-location . (concat org-directory "archive.org::"))
  (org-default-notes-file . (concat org-directory "notes.org"))
  (org-fontify-emphasized-text . t)
  (org-hide-emphasis-markers . t)
  (org-pretty-entities . t)
  (org-fontify-whole-heading-line . t)
  (org-fontify-done-headline . t)
  (org-fontify-quote-and-verse-blocks . t)
  (org-adapt-indentation . nil)
  (org-cycle-separator-lines . 2)
  (outline-blank-line . t)
  (org-enforce-todo-dependencies . t)
  (org-use-fast-tag-selection . nil)
  (org-tags-column . -80)
  (org-tag-alist . nil)
  (org-log-done . 'time))

;; *** asthetic
;; :PROPERTIES:
;; :ID: 52f5560d-6e52-4234-88d8-d326bc97525a
;; :END:

;; To be honest, org mode has some pretty ugly syntax. The asterixes at the
;; beginning of a heading are ugly, org block end and begin lines are ugly,
;; property drawers are ugly. For a nice-looking, minimal, and non-distracting
;; appearance all this needs to be improved.

;; **** visibility
;; :PROPERTIES:
;; :ID: 71462363-ddd0-4734-a074-7b00fde06e82
;; :END:

;; ***** hide lines
;; :PROPERTIES:
;; :ID: 533c108a-36d0-4686-9476-2588647402ed
;; :END:
;; =hide-lines= is a package which, as its name suggests, hides certain lines.
;; Specifically, it hides lines that match a regular expression you provide. You
;; can reveal them with [[helpfn:hide-lines-show-all][hide-lines-show-all]].

;; ****** hide lines
;; :PROPERTIES:
;; :ID: a2ea1e7e-5049-4b5e-bb06-4f31cf89ae32
;; :END:

;; Particularly in boilerplate heavy languages like Org, hiding certain lines can
;; make reading documents much easier by reducing visual distraction. This package
;; though is in need of an update. It didn't work out of the box (see [[id:b358f324-9b64-4e83-8168-231ff1ab115d][hide-lines]]
;; and [[id:a3e62e0a-452b-429c-9558-139e7b83cf80][hl overlay fix]]).

(void-autoload 'hide-lines (list #'hide-lines #'hide-lines-matching))

;; ****** =hl= overlay fix
;; :PROPERTIES:
;; :ID: a3e62e0a-452b-429c-9558-139e7b83cf80
;; :END:

;; The line ~(overlay-put overlay 'invisible 'hl)~ in [[helpfn:][hide-lines-add-overlay]] wouldn't
;; work with the argument =hl=. It works when you set it to =t= instead. Maybe =hl= is
;; depreciated.

(defadvice! fix-adding-overlay (:override hide-lines-add-overlay)
  "Add an overlay from `start' to `end' in the current buffer.
Push the overlay into `hide-lines-invisible-areas'."
  (let ((overlay (make-overlay <start> <end>)))
    (setq hide-lines-invisible-areas (cons overlay hide-lines-invisible-areas))
    (overlay-put overlay 'invisible t)))

;; ****** make sure all lines are hidden
;; :PROPERTIES:
;; :ID: b358f324-9b64-4e83-8168-231ff1ab115d
;; :END:

;; When I tried hiding property drawers [[hfn:hide-lines-matching][hide-lines-matching]] left out the start and
;; end property lines. Only the property block body was hidden. This advice fixes
;; this.

(defadvice! fix-hide-matching-lines  (:override hide-lines-matching)
  "Hide lines matching the specified regexp."
  (interactive "MHide lines matching regexp: ")
  (set (make-local-variable 'line-move-ignore-invisible) t)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward <search-text> nil t)
      (hide-lines-add-overlay (match-beginning 0) (match-end 0)))))

;; ***** toggle org properties
;; :PROPERTIES:
;; :ID: c2c54bd5-9148-45e9-a675-154bcbf13674
;; :END:

;; I want properties to exist--they are useful even if it's just to store an ID.
;; Yet, like most raw org syntax it looks ugly and takes up a lot of space.
;; Unless I explicitly ask for properties I don't want to see them.

(defun org/hide-property-drawers ()
  "Hide property drawers."
  (interactive)
  (let (selective-display-ellipses org-ellipsis)
    ;; If properties are folded, ellipsis will show.
    (org-show-all '(drawers))
    (hide-lines-matching (concat (s-chop-suffix "$" org-property-re) "\n"))))

;; ***** toggle end source lines
;; :PROPERTIES:
;; :ID: 18fdd2a0-df15-486f-97c6-594cba018a3e
;; :END:

(defun org/hide-source-block-delimiters ()
  "Hide property drawers."
  (interactive)
  (let (selective-display-ellipses org-ellipsis)
    ;; If properties are folded, ellipsis will show.
    (org-show-all)
    (hide-lines-matching (rx "#+" (or "begin" "end") "_src" (* nonl) "\n"))))

;; ***** ensure that everything is folded
;; :PROPERTIES:
;; :ID: 86437909-e4df-48ae-9e2f-bf364e92cc86
;; :END:

(setq-default org-startup-folded 'fold)

(defadvice! hide-all-property-drawers (:override org-set-startup-visibility)
  "Completely hide all text properties."
  ;; Hide property drawers on startup.
  (org/hide-property-drawers)
  (org-overview))

;; ***** ensure headings are visible
;; :PROPERTIES:
;; :ID: c0395fe0-fa69-49c1-94ed-cdbb94031868
;; :END:

;; Sometimes the heading inserted doesn't remain visible.

(defhook! ensure-heading-are-visible (org-insert-heading-hook)
  "Ensure that heading remains visible after insertion."
  (-when-let (o (cdr (get-char-property-and-overlay (point) 'invisible)))
    (move-overlay o (overlay-start o) (line-end-position 0))))

;; ***** display children in window
;; :PROPERTIES:
;; :ID: f7a9c5e7-fcf8-434a-a9b3-dbe4eadead78
;; :END:

(defun org:display-children-in-window ()
  "Scroll up window to maximize view of unfolded subtree.
If the subtree is unfolded and the end of the current subtree is outside of the
visible window, scroll up until the whole subtree is visible. If the whole
subtree can't fit on the visible window, only scroll up until the top of the
subtree is on the first line of the window (in other words, the beginning of
th subtree should always be visible)."
  (interactive)
  ;; Don't use `window-beg' and `window-end' because their values are
  ;; unreliable.
  (let ((subtree-beg
         (save-excursion (org-back-to-heading)
                         (line-beginning-position)))
        (subtree-end
         (save-excursion (org-end-of-subtree)
                         (line-end-position))))
    (save-excursion
      (while (and (pos-visible-in-window-p subtree-beg)
                  (not (pos-visible-in-window-p subtree-end)))
        (scroll-up 1))
      ;; Sometimes the line at the end is not fully visible. So I try to
      ;; scroll down an extra line.
      (unless (pos-visible-in-window-p subtree-beg)
        (scroll-down 1)))))

;; ***** ensure children are visible
;; :PROPERTIES:
;; :ID: 479455ed-a0be-4ecc-af66-559abf53c77c
;; :END:

;; If I unfold a subtree and the end of the subtree is outside of the window and
;; there's space in the window above the subtree, scroll up as much as possible.

;; Note that I don't use [[helpfn:window-start][window-start]] and [[helpfn:window-end][window-end]] because [[info:elisp#Window Start and End][their values are
;; unreliable]]. They update when [[helpfn:redisplay][redisplay]] is called; and for efficiency, I don't
;; want to call this function through every iteration of the loop. Instead I used
;; [[helpfn:pos-visible-in-window-p][pos-visible-in-window-p]] to tell me if a point is still in the visible window. In
;; hindsight, using this function is even easier than using ~window-beg~ and
;; ~window-end~ because it doesn't require any math on my part.

(defadvice! ensure-children-visible (:after outline-toggle-children)
  "Ensure children are visible after toggling."
  (unless (org:heading-folded-p)
    (org:display-children-in-window)))

;; **** fancy priorities
;; :PROPERTIES:
;; :ID: 306faaf1-fa4d-42bd-8863-ae73ca12cb61
;; :END:

;; [[package:org-fancy-priorities][org-fancy-priorities]] is a package that displays org priorities with an icon.

(void-add-hook 'org-mode-hook #'org-fancy-priorities-mode)

(after! all-the-icons
  (alet (list (all-the-icons-material "priority_high")
              (all-the-icons-octicon "arrow-up")
              (all-the-icons-octicon "arrow-down")
              (all-the-icons-material "low_priority"))
    (setq org-fancy-priorities-list it)))

;; **** org-superstar
;; :PROPERTIES:
;; :ID: c43700f5-ff24-46b2-aed5-a12f8d8bb347
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "integral-dw/org-superstar-mode"
;; :PACKAGE:  "org-superstar"
;; :LOCAL-REPO: "org-superstar-mode"
;; :END:

;; [[package:org-superstar][org-superstar]] is a an =org-bullets= remake redesigned from the ground up.

(void-add-hook 'org-mode-hook #'org-superstar-mode)

(setq org-superstar-special-todo-items t)
(setq org-superstar-leading-bullet ?\s)

;; *** links
;; :PROPERTIES:
;; :ID: dbc3d205-9831-41f0-95f8-1e8746e0be3a
;; :END:

;; To me links are one of the biggest drawing points to org-mode. The ability to
;; have documentation that can link to websites, files, info docs and even github
;; commits is too juicy to pass up. Why in the 21st century do we still have to
;; deal with such weak, plain text code documentation when we could use a more
;; powerful markup language?

;; **** ol
;; :PROPERTIES:
;; :ID: 21148ef5-0887-4560-9997-6059b3529a2d
;; :END:

(use-feature! ol
  :after org
  ;; :custom
  ;; (org-link-descriptive . t)
  ;; (org-link-use-indirect-buffer-for-internals . t)
  )

;; **** custom link types
;; :PROPERTIES:
;; :ID: 76f86439-8ee3-4688-b117-a51d18d365ce
;; :END:

;; ***** helpvar
;; :PROPERTIES:
;; :ID: 20f9629a-f145-44df-b8b4-69c5394dc773
;; :END:

;; =helpvar= I a new link type that when pressed, opens a help buffer from [[https://github.com/Wilfred/helpful][helpful]] if
;; it's installed, otherwise it defaults to bringing up an regular emacs help buffer.

(after! org
  (defun ol:helpvar-face (link)
    (if (boundp (intern link)) 'org-link 'error))

  (defun ol:helpvar-follow (link)
    (let ((var (intern link)))
      (if (require 'helpful nil :noerror)
          (helpful-variable var)
        (describe-variable var))))

  (org-link-set-parameters "helpvar" :face #'ol:helpvar:face :follow #'ol:helpvar:follow))

;; ***** helpfn
;; :PROPERTIES:
;; :ID: 449a3953-dce5-41a1-afdf-129fa6fae573
;; :END:

;; =helpfn= is the same as helpvar except with functions.

(after! org
  (defun ol:helpfn-face (link)
    (let ((fn (intern link)))
      (if (fboundp fn) 'org-link 'error)))

  (defun ol:helpfn-follow (link)
    (let ((fn (intern link)))
      (if (require 'helpful nil :no-error)
          (helpful-callable fn)
        (describe-function fn))))

  (org-link-set-parameters "helpfn" :face #'ol:helpfn-face :follow #'ol:helpfn-follow))

;; *** built in features
;; :PROPERTIES:
;; :ID:       e882f8f8-195f-4349-b766-a87a39be7e10
;; :END:

;; **** org capture
;; :PROPERTIES:
;; :ID: 81197df0-6744-4a63-a202-f7279d7b7119
;; :END:

;; Ever been in the middle of doing something when a thought in your head pops up
;; about some thing else? You can stop what you're doing but then you lose focus.
;; You can resolve to make note of it later but then you might forget. Capturing is
;; designed to confront this problem. While in the middle of a task you can quickly
;; jump into a small org buffer and write down an idea that you have, then close
;; it.

;; ***** org capture
;; :PROPERTIES:
;; :ID:       8fc5d248-ff21-45e4-a48b-57cecd57b7a3
;; :END:

(use-feature! org-capture
  :trigger org-ml ts
  :commands org-capture
  :popup ("\\`CAPTURE"
          (display-buffer-at-bottom)
          (window-height . 0.5)
          (slot . 10)))

;; ***** doct
;; :PROPERTIES:
;; :ID: 287fb9c7-110e-4758-aab2-71f74079ade2
;; :END:

;; [[https://github.com/progfolio/doct][doct]] is a package designed to ease writing and understanding capture templates
;; by allowing you to write them in a declarative style (see [[helpfn:doct][doct docstring]]).
;; In org mode, capture templates are [[info:org#Capture templates][represented as plain lists]]. This makes
;; it easy to forget what a certain element meant or to accidentally omit a capture
;; template element as you're writing it.

(use-package! doct
  :after org-capture
  :demand t)

;; ***** remove capture headerline
;; :PROPERTIES:
;; :ID: 7b8a8e1d-3c72-492f-9311-56a2428a1f1d
;; :END:

;; By default org capture templates have. This was the answer to [[https://emacs.stackexchange.com/questions/53648/eliminate-org-capture-message][my question]]. I
;; need to disable =org-capture's= header-line.

(defhook! disable-header-line (org-capture-mode-hook)
  "Turn of the header line message."
  (setq-local header-line-format nil))

;; ***** helpers
;; :PROPERTIES:
;; :ID:       e0eab71c-40e0-47bf-87b3-94bee126aff3
;; :END:

;; These functions are to help me reduce the boilerplate of defining a capture
;; template.

;; ****** org-capture-file
;; :PROPERTIES:
;; :ID:       25fdde38-86d5-4ef4-aecb-81ceebec7c27
;; :END:

;; This function is a convenience wrapper to be used as the =:file= argument for [[helpfn:doct][doct
;; declarations]]. The reason I use this function instead of passing in the file path
;; is so that if VOID-CAPTURE-FILE is modified templates will still be added to the
;; right place.

(defun org-capture:file ()
  "Return `VOID-CAPTURE-FILE'.
This is a convenience wrapper for `doct' declarations."
  VOID-CAPTURE-FILE)

;; ****** add to capture templates
;; :PROPERTIES:
;; :ID:       16c55272-f8c2-4798-9da1-2ab492769f44
;; :END:

;; [[helpfn:doct][doct]] returns the new value of capture templates. but it does not actually add
;; it. For convenience this function declare it and add it in all in one go.
;; Additionally, it removes any capture templates with the same key so that I can
;; freely re-evaluate it without cluttering my capture templates with duplicate
;; entries.

(defun org-capture:add-to-templates (declarations)
  "Set `org-capture-templates' to the result of (doct DECLARATIONS).
Before adding result, remove any members of `org-capture-templates' with the
same key as the one(s) being added."
  (cl-labels ((clean (templates)
                     (when templates
                       (cons (car templates)
                             (--remove (string= (caar templates) (car it))
                                       (clean (cdr templates)))))))
    (setq org-capture-templates
          (clean (-concat (doct declarations) org-capture-templates)))))

;; ****** schedule and deadline times
;; :PROPERTIES:
;; :ID:       e5c8996f-0d93-4a76-9b30-baf40f70d74d
;; :END:

;; For capture templates that have deadlines, I set a start and an end date.

(defun org-capture::default-planning-node (&optional days-difference)
  "Return the default planning node for `org-capture-templates'."
  (let* ((days-difference (or days-difference 7))
         (now (ts-now))
         (later (ts-adjust 'day days-difference now))
         (beg (list (ts-year now) (ts-month now) (ts-day now)))
         (end (list (ts-year later) (ts-month later) (ts-day later)))
         (days-difference (or days-difference 7)))
    (org-ml-build-planning! :scheduled beg :deadline end)))

;; ****** generic template
;; :PROPERTIES:
;; :ID:       7945bb08-cb78-4c7e-840d-3cf92b7e3677
;; :END:

;; To maximize code reusability, I create a generic template skeleton here. All of
;; my headlines should have their own UUID. And almost all of my headlines will
;; have the date created.

(defun org-capture::generic-template ()
  "Return the default `org-capture-template'."
  (->> (org-ml-build-headline! :title-text "%?")
       (org-ml-headline-set-node-property "ID" (org-id-new))
       (org-ml-headline-set-node-property "CREATED" (ts-format))))

;; ****** default template keywords
;; :PROPERTIES:
;; :ID:       b2fe70d3-cc88-40fb-a718-8dafaeb98694
;; :END:

(defvar org-capture:defaults
  '(:file #'org-capture:file
    :prepend t
    :empty-lines 1)
  "A plist of keywords that should always apply to capture templates.")

;; ****** convenience macro for defining capture templates
;; :PROPERTIES:
;; :ID:       9a3ece9d-e8e4-4b32-b65b-4a992e9d20cf
;; :END:

(defmacro! define-capture-template! (name args &rest body)
  "Define a capture template."
  (declare (indent defun))
  (-let* ((string-name (downcase (symbol-name name)))
          ((_ alist body) (void--keyword-macro-args body))
          (defaults org-capture:defaults)
          (key (downcase (substring string-name 0 1))))
    `(after! org-capture
       (defun org-capture::<string-name>-template-node ()
         "Return capture template node for <string-name>."
         ,@body)
       (defun org-capture::<string-name>-template-string ()
         "Return capture template as a string."
         (->> (org-capture::<string-name>-template-node)
              (org-ml-to-trimmed-string)))
       (org-capture:add-to-templates
        (list ,string-name
              :keys ,key
              :template #'org-capture::<string-name>-template-string
              ,@(-flatten-n 1 (-map #'-cons-to-list alist))
              ,@org-capture:defaults)))))

;; ****** capture get url
;; :PROPERTIES:
;; :ID:       a0f5b143-f48f-4c6a-a1d1-63d638b15e22
;; :END:

(defun org-capture:browser-url ()
  "Return the url of current browser."
  (cond ((and (bound-and-true-p exwm-mode))
         (exwm::firefox-url))
        (()
         (exwm::qutebrowser-url))
        ((eq major-mode 'eww-mode)
         (eww-current-url))
        ((eq major-mode 'w3m-mode)
         ))
  )

;; ****** is a browser buffer
;; :PROPERTIES:
;; :ID:       649c42af-cba2-4c0b-86a7-221ba6609592
;; :END:

(defun in-browser-buffer-p ()
  "docstring"
  (s-matches-p (buffer-name)))

;; ***** capture templates
;; :PROPERTIES:
;; :ID: aeb0bc04-84a1-4f85-89f9-c2e04cefce92
;; :END:

;; I use [[https://github.com/ndwarshuis/org-ml][org-ml]] and [[https://github.com/progfolio/doct][doct]] to generate templates dynamically. By "dynamically"
;; I mean that a template for a given key is different every time I open it. This
;; is possible with regular capture templates via [[info:org#Template expansion][org template expansion]], but I think the
;; abstractions provided by =org-ml= and =doct= are even more robust and much easier to
;; extend.

;; ****** website
;; :PROPERTIES:
;; :ID:       03d7ea80-5d55-4ecb-b0ba-c229090b1d5e
;; :END:

;; The purpose of this template is to.

;; A small note to avoid invalid filenames or wanting to create a filename but
;; inadvertently adding a file to a directory I replace any forward slashes (=/=)
;; with =~=.

(define-capture-template! Website ()
  :when #'org-capture:in-browser-buffer-p
  :file (concat VOID-ORG-DIR "websites.org")
  :immediate-finish t
  :after-finalize (lambda () (void-download-webpage-as-pdf (exwm::qutebrowser-url) exwm-title))
  (let* ((url (exwm::qutebrowser-url))
         ;; find the newest pdf added to the directory.
         (pdf-name exwm-title)
         (pdf-path (format "%s%s.pdf" VOID-SCREENSHOT-DIR (s-replace "/" "~" pdf-name)))
         (link-to-pdf (org-ml-to-trimmed-string (org-ml-build-link pdf-path pdf-name))))
    (->> (org-capture::generic-template)
         (org-ml-headline-set-title! link-to-pdf nil)
         (org-ml-headline-set-node-property "SOURCE" url))))

;; ****** question
;; :PROPERTIES:
;; :ID:       a672f3eb-43c1-4310-adcc-6d0022e50579
;; :END:

;; Sometimes I have questions that I want to record. It's kind of like a more
;; specific =TODO= because their "task" is always to be answered. I think it's
;; worth distinguishing them from tasks in which I need to perform an action that I
;; have no questions about. The purpose of this template is for problems and issues
;; I'm stumped on. This process can help me reason through as much as I can and
;; provide the perfect draft for a potential question for reddit or stackexchange.

(define-capture-template! Question ()
  (->> (org-capture::generic-template)
       (org-ml-set-property :tags '("question"))))

;; ****** idea
;; :PROPERTIES:
;; :ID:       71864105-198a-4680-ad1d-bd3f40b7f0d6
;; :END:

(define-capture-template! Idea ()
  (->> (org-capture::generic-template)
       (org-ml-set-property :tags '("idea"))))

;; ****** emacs
;; :PROPERTIES:
;; :ID: e6109a54-37af-44ba-852f-a1c34f910cb9
;; :END:

;; This capture template is for something emacs related I need to do.

(define-capture-template! Emacs ()
  (->> (org-capture::generic-template)
       (org-ml-set-property :todo-keyword "TODO")
       (org-ml-set-property :tags '("emacs"))
       (org-ml-headline-set-planning (org-capture::default-planning-node))))

;; ****** generic todo
;; :PROPERTIES:
;; :ID:       3689e969-aefe-47f4-8d54-b23f08840374
;; :END:

(define-capture-template! todo ()
  (->> (org-capture::generic-template)
       (org-ml-set-property :todo-keyword "TODO")))

;; ***** prevent capture templates from deleting windows
;; :PROPERTIES:
;; :ID:       a13e330a-33ff-4c1e-add4-00c5db4e6cd1
;; :END:

;; =org-capture= deletes all the other windows in the frame.

(defadvice! dont-delete-other-windows (:around org-capture-place-template)
  "Don't delete other windows when opening a capture template."
  (cl-letf (((symbol-function #'delete-other-windows) #'ignore))
    (apply <orig-fn> <args>)))

;; **** org agenda
;; :PROPERTIES:
;; :ID:       16c1da27-264f-47df-a9d4-3f3ad8fa460f
;; :END:

;; ***** org agenda
;; :PROPERTIES:
;; :ID: 65b2885d-aca6-42b8-a8ad-e3ae077b9aae
;; :END:

;; [[helpfn:org-agenda-list][org-agenda-list]] is the function that actually takes you to the agenda for the
;; current week.

(use-feature! org-agenda
  :after org
  :commands (org-agenda org-agenda-list)
  :setq
  (org-agenda-files list VOID-CAPTURE-FILE)
  (org-agenda-start-on-weekday . 0)
  (org-agenda-timegrid-use-ampm)
  (org-agenda-skip-unavailable-files)
  (org-agenda-time-leading-zero . t)
  (org-agenda-text-search-extra-files . '(agenda-archives))
  (org-agenda-dim-blocked-tasks)
  (org-agenda-inhibit-startup . t))

;; ***** org super agenda
;; :PROPERTIES:
;; :ID:       d4914094-9e4e-4269-a359-16c7abc6653a
;; :END:

(use-package! org-super-agenda)

;; **** org refile
;; :PROPERTIES:
;; :ID:       7cb6769d-2904-4675-b17d-f658edb5a917
;; :END:

;; ***** org refile
;; :PROPERTIES:
;; :ID: 0174a708-8043-403e-b024-8ae29868564d
;; :END:

(use-feature! org-refile
  :pre-setq
  (org-refile-targets . `((,VOID-MAIN-ORG-FILE . (:maxlevel . 10))
                          (,(concat VOID-ORG-DIR "code.org") . (:maxlevel . 10))))
  (org-refile-use-outline-path . 'file)
  (org-refile-allow-creating-parent-nodes . t)
  (org-reverse-note-order . t)
  (org-outline-path-complete-in-steps . nil))

;; **** org id
;; :PROPERTIES:
;; :ID: e7ecff83-7ba6-4620-ac05-ebac2f250b7a
;; :END:

;; =org-id= is a built-in package that creates that provides tools for creating and
;; storing universally unique IDs. This is primarily used to disguish and
;; referenance org headlines.

(use-feature! org-id
  :commands org-id-get-create
  :setq
  (org-id-locations-file . (concat VOID-DATA-DIR "org-id-locations"))
  ;; Global ID state means we can have ID links anywhere. This is required for
  ;; `org-brain', however.
  (org-id-locations-file-relative . t)
  :hook (org-insert-heading . org-id-get-create))

;; **** org clock
;; :PROPERTIES:
;; :ID:       d378471c-89df-48c9-a755-b79880f27308
;; :END:

;; =org-clock= is a built-in package that provides time logging functions for
;; tracking the time you spend on a particular task.

(use-feature! org-clock
  :commands org-clock-in
  ;; :before-call ((org-clock-in org-clock-out org-clock-in-last org-clock-goto org-clock-cancel) . (org-clock-load))
  :hook (kill-emacs . org-clock-save)
  :setq
  ;; org-clock-sound
  ;; org-show-notification-handler
  (org-clock-persist . 'history)
  (org-clock-persist-file . (concat VOID-DATA-DIR "org-clock-save.el"))
  ;; Resume when clocking into task with open clock
  (org-clock-in-resume . t)
  :config
  ;; set up hooks for persistence.
  (org-clock-persistence-insinuate))

;; **** org crypt
;; :PROPERTIES:
;; :ID:       f5278890-8b84-43df-b5dc-0ef8074bfba9
;; :END:

(use-feature! org-crypt
  :commands org-encrypt-entries org-encrypt-entry org-decrypt-entries org-decrypt-entry
  :hook (org-reveal-start . org-decrypt-entry)
  ;; :preface
  ;; ;; org-crypt falls back to CRYPTKEY property then `epa-file-encrypt-to', which
  ;; ;; is a better default than the empty string `org-crypt-key' defaults to.
  ;; (defvar org-crypt-key nil)
  ;; (after! org
  ;;   (add-to-list 'org-tags-exclude-from-inheritance "crypt")
  ;;   (add-hook! 'org-mode-hook
  ;;              (add-hook 'before-save-hook 'org-encrypt-entries nil t)))
  )

;; *** org-journal
;; :PROPERTIES:
;; :ID:       c3056303-5fa1-49f9-ae2d-294942e25f54
;; :END:

;; =org-journal= is a package that provides functions to maintain a simple
;; diary/journal using =org-mode=.

(use-package! org-journal
  :commands org-journal-new-entry
  :setq
  (org-journal-file-type . 'yearly)
  (org-journal-dir . (concat VOID-ORG-DIR "journal/"))
  (org-journal-find-file . 'find-file))

;; ** lua
;; :PROPERTIES:
;; :ID: 9f458b76-489f-45e0-b99a-ad6a9a2ae182
;; :END:

(use-package! lua-mode :mode "\\.lua\\'")

;; ** cpp
;; :PROPERTIES:
;; :ID:       2fecdcf5-f482-4672-8bc8-9e9e1e0e110b
;; :END:

;; *** modern font lock
;; :PROPERTIES:
;; :ID:       2778d03a-4ee0-4175-90e5-331140ca7faf
;; :END:

(use-package! modern-cpp-font-lock
  :hook (c++-mode . modern-c++-font-lock-mode))

;; *** demangle
;; :PROPERTIES:
;; :ID:       2cda9af3-c7e3-48b5-8b49-ec4c63d4f501
;; :END:

(use-package! demangle-mode
  :hook llvm-mode)

;; ** TODO latex
;; :PROPERTIES:
;; :ID:       03b47c17-e217-4dd5-b48d-36ae54a8349e
;; :END:

;; *** tex
;; :PROPERTIES:
;; :ID:       da68dfd0-62c5-4101-a7f3-7b13df760670
;; :END:

(use-feature! tex
  :mode ("\\.tex\\'" . LaTeX-mode)
  :hook (LaTex-mode . visual-line-mode)
  :setq
  (TeX-parse-self . t)
  (TeX-auto-save . t)
  ;; use hidden dirs for auctex files
  (TeX-auto-local . ".auctex-auto")
  (TeX-style-local . ".auctex-style")
  (TeX-source-correlate-mode . t)
  (TeX-source-correlate-method . 'synctex)
  ;; don't start the emacs server when correlating sources
  (TeX-source-correlate-start-server . nil)
  ;; automatically insert braces after sub/superscript in math mode
  (TeX-electric-sub-and-superscript . t))

;; *** auctex
;; :PROPERTIES:
;; :ID:       5d5d2e8f-3b95-4d1a-bcc0-1c4ec8f51202
;; :END:

(use-package! auctex)

;; *** adaptive wrap
;; :PROPERTIES:
;; :ID:       80c837fc-a8de-4c11-9c76-b54f58c9a157
;; :END:

(use-package! adaptive-wrap
  :hook (LaTeX-mode . adaptive-wrap-prefix-mode)
  :setq-default (adaptive-wrap-extra-indent . 0))

;; *** preview pane
;; :PROPERTIES:
;; :ID:       a1c99afc-ee73-42fd-b33d-7c61ad607e90
;; :END:

(use-package! latex-preview-pane)

;; * User Interface
;; :PROPERTIES:
;; :ID: ee57f711-9a4f-421f-b831-ab4907402e52
;; :END:

;; ** help and documentation
;; :PROPERTIES:
;; :ID:       3c01c053-fe6f-4a7a-92a5-6d4de7caac0a
;; :END:

;; *** helpful
;; :PROPERTIES:
;; :ID:       5340ddb3-92bc-42e5-bf0e-9f9650c41cd9
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Wilfred/helpful"
;; :PACKAGE:  "helpful"
;; :LOCAL-REPO: "helpful"
;; :COMMIT:   "584ecc887bb92133119f93a6716cdf7af0b51dca"
;; :END:

;; **** helpful
;; :PROPERTIES:
;; :ID: 25270809-b64e-4b9a-b0c2-95ffd047280c
;; :END:

;; [[github:wilfred/helpful][helpful]] provides a complete replacement for the built-in
;; Emacs help facility which provides much more contextual information
;; in a better format.

(use-package! helpful
  :popup
  ("\\*Help.*"
   (display-buffer-at-bottom)
   (window-width . 0.50)
   (side . bottom)
   (slot . 4))
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key))

;; *** elisp-demos
;; :PROPERTIES:
;; :ID:       81d22037-cd3e-4766-a8cc-6062e36deb1b
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "*.org" "elisp-demos-pkg.el")
;; :HOST:     github
;; :REPO:     "xuchunyang/elisp-demos"
;; :PACKAGE:  "elisp-demos"
;; :LOCAL-REPO: "elisp-demos"
;; :COMMIT:   "05047654fbd342cb2463ec8ea562e4bba53c7be2"
;; :END:

;; **** elisp demos
;; :PROPERTIES:
;; :ID: d1164fd9-bfc6-4436-a249-136a63c76e40
;; :END:

;; This package improves help further by allowing you to add examples on how to use
;; a function or macro. It seems simple but having examples can really ease the
;; understanding of a verbally terse and dry command description.

(use-package! elisp-demos
  :commands elisp-demos-add-demo
  :advice (:after (helpful-update . elisp-demos-advice-helpful-update)))

;; * Asthetic
;; :PROPERTIES:
;; :ID: bd21a69a-794c-4ff1-97d0-9e5911a26ad7
;; :END:

;; It's easy to underestimate how much of a difference having an asthetically
;; pleasing Emacs configuration can have. Ugliness really can take its toll.

;; ** which-key
;; :PROPERTIES:
;; :ID:       2ad092a3-ff63-49cd-91b9-380c91dbe9f5
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "justbur/emacs-which-key"
;; :PACKAGE:  "which-key"
;; :LOCAL-REPO: "emacs-which-key"
;; :COMMIT:   "c011b268196b8356c70f668506a1133086bc9477"
;; :END:

;; Emacs is full of so many keybindings, that it can be difficult to keep track of
;; them. Especially when you're starting out, but even when you're an Emacs-pro,
;; it's easy to forget what a particular functionality is bound to. Typically,
;; you'll remember the first few key strokes but struggle with the rest. To address
;; this [[github:][which-key]] displays key binding sequences in the minibuffer as your typing
;; them ([[][]] and [[][]] are screenshots of this in action). By doing this
;; you can "discover" the commands as you go along.

;; *** init
;; :PROPERTIES:
;; :ID:       c4aedc23-0be3-46fe-b046-32b5f0738c6b
;; :END:

;; **** hooks
;; :PROPERTIES:
;; :ID:       e6626cde-d243-4aac-a61c-2897e43b7e73
;; :END:

(void-add-hook 'emacs-startup-hook #'which-key-mode)

;; **** settings
;; :PROPERTIES:
;; :ID:       a4b5878c-1b3f-4d85-9403-7ed8cc52433f
;; :END:

(setq which-key-sort-uppercase-first nil)
(setq which-key-max-display-columns nil)
(setq which-key-add-column-padding 1)
(setq which-key-min-display-lines 6)
(setq which-key-side-window-slot -10)
(setq which-key-sort-order #'which-key-prefix-then-key-order)
(setq which-key-popup-type 'minibuffer)
(setq which-key-idle-delay 0.8)

;; *** set line spacing
;; :PROPERTIES:
;; :ID:       6abb35f4-c648-4bed-b59a-5a0636857fd8
;; :END:

(defhook! set-line-spacing (which-key-init-buffer-hook)
  (setq line-spacing 3))

;; *** leader keys
;; :PROPERTIES:
;; :ID:       1df41291-32c3-44ca-89a9-f042fb2bbd6c
;; :END:

(which-key-add-key-based-replacements void-leader-key "<leader>")
(which-key-add-key-based-replacements void-localleader-key "<localleader>")

;; ** dashboard
;; :PROPERTIES:
;; :ID: 20926522-b78b-4bca-b70e-9ef4213c4344
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "banners" "dashboard-pkg.el")
;; :HOST:     github
;; :REPO:     "emacs-dashboard/emacs-dashboard"
;; :PACKAGE:  "dashboard"
;; :LOCAL-REPO: "emacs-dashboard"
;; :COMMIT:   "2cebc69e3d4b82569daa732b9114787d7018304b"
;; :END:

;; [[https://github.com/emacs-dashboard/emacs-dashboard][dashboard]] is an extensible emacs startup screen. I love the idea of =dashboard=:
;; having an extensible, fast, nice-looking dashboard when starting emacs is
;; nice. It's not only nice asthetically, it's also strategic too. First, you can
;; use it as a launching point to get to your tasks quicker. And second, it doesn't
;; require any expensive modes. I've often been starting out with the scratch
;; buffer and I've wanted to have the scratch buffer start off with
;; =emacs-lisp-mode=, but I don't want it to trigger =company=, =yasnippet=, etc. on
;; startup. If I start my emacs with =dashboard= I can avoid this.

;; *** init
;; :PROPERTIES:
;; :ID:       de94c9a8-fc05-46ec-ac06-510f1014e02d
;; :END:

;; **** require
;; :PROPERTIES:
;; :ID:       73d00f99-4b70-44d1-8359-01bd2c94b330
;; :END:

(require 'dashboard)
(void-add-hook 'window-setup-hook #'dashboard-insert-startupify-lists)

;; **** open dashboard at startup
;; :PROPERTIES:
;; :ID:       1bcc371e-61fa-480e-bdae-4a999d3b10c9
;; :END:

(defadvice! open-dashboard-instead (:override void-initial-buffer)
  (if void-debug-p (get-buffer "*Messages*")
    (get-buffer-create "*dashboard*")))

;; **** settings
;; :PROPERTIES:
;; :ID:       f5434534-e767-4416-848a-8912bae0ede1
;; :END:

(dashboard-items . nil)
(dashboard-startup-banner . 2)
(dashboard-center-content . t)
(initial-buffer-choice . #'void-initial-buffer)

;; *** dashboard-init-info
;; :PROPERTIES:
;; :ID: 92c199ad-5862-4fe3-be04-44c94d4286b6
;; :END:

;; [[helpvar:void-init-time][void-init-time]] is more accurate than dashboard's init time measure. So I use it
;; instead.

(defadvice! show-package-load-time (:before dashboard-insert-startupify-lists)
  (setq dashboard-init-info
        (format "%d packages loaded in %.2f seconds"
                (cond ((featurep 'straight)
                       (hash-table-size straight--profile-cache))
                      ((featurep 'package) (length package-activated-list))
                      (t 0))
                (string-to-number (emacs-init-time)))))

;; *** banner path
;; :PROPERTIES:
;; :ID: 597af7c3-f5d2-4cf5-a93e-3dd3564fb34a
;; :END:

(defadvice! set-custom-banner-path (:override dashboard-get-banner-path)
  "Use the Void text banner."
  (concat VOID-LOCAL-DIR "void-banner.txt"))

;; *** navigator buttons                                                 :disabled:
;; :PROPERTIES:
;; :ID:       a4a9e0ae-ee44-4434-bcf6-b415ef348e45
;; :END:

;; **** navigator button
;; :PROPERTIES:
;; :ID:       63829df6-5ba9-477e-99e9-86aabf7f5862
;; :END:

;; This is a convenience macro that allows navigation buttons to be defined
;; declaratively and with a "defun-like" syntax. Perhaps this is overkill.

(defmacro dashboard:define-naviator-button! (name args description &rest body)
  "Define a dashboard navigator button."
  (declare (indent defun))
  (let ((dashboard-fn dashboard:name-button)
        ((&plist ))
        ((&plist ) icon))
    `(alet (list ()
                 ,name
                 ,description
                 #',dashboard-fn)
       (push it dashboard-navigator-buttons))))

;; **** github link
;; :PROPERTIES:
;; :ID:       a3c05c71-bd42-4508-8738-5c75f95b29d6
;; :END:

(dashboard:define-naviator-button! Homepage ()
                                   "Browse Homepage."
                                   :icon "mark-github"
                                   (browse-url "https://github.com/Luis-Henriquez-Perez/.emacs.d"))

;; **** go to readme
;; :PROPERTIES:
;; :ID:       1a666fec-9f7c-4153-9e9a-f0f4a74e4d31
;; :END:

(dashboard:define-naviator-button! README ()
                                   "Go to README."
                                   :icon "eye"
                                   :type faicon
                                   (browse-url "https://github.com/Luis-Henriquez-Perez/.emacs.d"))

;; ** feebleline
;; :PROPERTIES:
;; :ID:       2e3fe8bf-18d2-4a18-92c6-4fcccf6b3c28
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "tautologyclub/feebleline"
;; :PACKAGE:  "feebleline"
;; :LOCAL-REPO: "feebleline"
;; :COMMIT:   "b2f2db25cac77817bf0c49ea2cea6383556faea0"
;; :END:

;; Feebleline replaces the typical emacs modeline with text printed out to
;; echo area.

;; Why use this instead of a typical modeline (such as doom-modeline,
;; telephone-line, smart-mode-line, etc.)? The problem with typical emacs modelines
;; is that they appear in every buffer. This means they do not scale well in terms
;; of screen space because each additional vertical window means another line
;; dedicated to the modeline. Moreover, more modelines aren't even more useful,
;; it's just excess information you don't need to know unless you're visiting the
;; buffer. Better is a global modeline that displays the information from the
;; buffer displayed in the currently selected window.

;; *** init
;; :PROPERTIES:
;; :ID:       e0a819d7-1d30-4602-9539-e882f37b7bc2
;; :END:

;; **** feebleline
;; :PROPERTIES:
;; :ID:       fa4b3d96-c346-4f43-9d1e-9accf0c0e97b
;; :END:

(void-add-hook 'window-setup-hook #'feebleline-mode)

;; **** modeline display
;; :PROPERTIES:
;; :ID:       3061498c-9533-4595-a5ab-71bbf111fd87
;; :END:

;; It's really easy to add new segments to this modeline.

;; There are those who insist on the usefulness of line numbers and column number.
;; I'm not one of them. I rarely ever need to use a specific line number or column
;; number when editing text. To me they are just distracting eye-candy.

(after! feebleline
  (setq feebleline-msg-functions
        '((feebleline:mode-icon :fmt "%2s")
          (feebleline-file-or-buffer-name :face font-lock-keyword-face)
          (feebleline-git-branch :face feebleline-git-face)
          (feebleline:emms-track-status-indicator)
          (feebleline:emms-current-track)
          (feebleline:current-workgroup :align right)
          (feebleline:dwim-battery-info :align right)
          (feebleline:msg-display-time :align right))))

;; *** whether to display icons
;; :PROPERTIES:
;; :ID:       15850007-1ec3-45d0-afb9-0fd764991fca
;; :END:

(defvar void-display-icons-p t
  "Whether to display icons.")

(defun void/toggle-icon-display ()
  "Toggle the display of icons."
  (interactive)
  (toggle! void-display-icons-p))

;; *** icon displayable
;; :PROPERTIES:
;; :ID:       8f470288-9779-4bd9-95d7-b725ea3507c6
;; :END:

(defun void-icons-displayable-p ()
  "Return non-nil when icons are displayable."
  (and (display-graphic-p)
       void-display-icons-p
       (featurep 'all-the-icons)
       t))

;; *** icon generic function
;; :PROPERTIES:
;; :ID:       e32829fe-6f94-4a20-956d-85248e940f54
;; :END:

(defun all-the-icons:icon (type name &rest properties)
  "Return icon."
  (if (void-icons-displayable-p)
      (apply (void-symbol-intern 'all-the-icons- type) name properties)
    (plist-get properties :fallback)))

;; *** buffer mode
;; :PROPERTIES:
;; :ID:       666cea86-49d8-44c2-8727-e50c94963eee
;; :END:

(defun feebleline:mode-icon ()
  "Display a mode icon."
  (when (void-icons-displayable-p)
    (--> (all-the-icons-icon-for-buffer)
         (if (or (null it) (symbolp it))
             (all-the-icons-faicon "file-o")
           it)
         (propertize it 'display '(raise 0.01)))))

;; *** git branch
;; :PROPERTIES:
;; :ID:       48e08229-355d-4d4f-a003-d56781f94c80
;; :END:

;; **** branch icon                                                      :disabled:
;; :PROPERTIES:
;; :ID:       58c2d085-f377-4444-85a7-2780421f28ee
;; :END:

(defun feebleline:git-branch-icon ()
  (when (magit-git-repo-p default-directory)
    (all-the-icons-octicon "git-branch" :v-adjust 0.01)))

;; *** time
;; :PROPERTIES:
;; :ID:       f2f18c74-77e9-4334-9d4e-9044b3a69f23
;; :END:

(defun feebleline:msg-display-time ()
  (format-time-string "%T %D %a"))

;; *** saved buffer
;; :PROPERTIES:
;; :ID:       f956383b-0e7e-4d42-95fb-2cb65faf5c35
;; :END:

(defun feebleline:saved-buffer-indicator-icon ()
  "Display saved icon if buffer has been saved."
  (when (and (buffer-file-name) (buffer-modified-p))
    (all-the-icons:icon 'material "save" :v-adjust -0.01)))

;; *** battery
;; :PROPERTIES:
;; :ID:       a23d0584-e0d4-4d6e-98ac-44bd51bcc3a4
;; :END:

;; **** battery
;; :PROPERTIES:
;; :ID:       b1d5e914-3337-4426-94f7-9d618e9ffacf
;; :END:

;; ***** battery
;; :PROPERTIES:
;; :ID:       9514f9db-4937-435a-943c-27cf066e979e
;; :END:

(use-feature! battery :demand t)

;; ***** battery charging
;; :PROPERTIES:
;; :ID:       0a44e046-e78b-4681-8cad-3cec5dbb2c14
;; :END:

(defun battery:charging-p ()
  "Return non-nil if the battery is charging."
  (alet (battery-format "%B" (funcall battery-status-function))
    (string= it "Charging")))

;; ***** battery percentage
;; :PROPERTIES:
;; :ID:       5b557679-4ddd-4ed3-92b7-e5e415e47497
;; :END:

(defun battery:percentage ()
  "Return the battery percentage."
  (alet (battery-format "%p" (funcall battery-status-function))
    (string-to-number it)))

;; **** battery status
;; :PROPERTIES:
;; :ID:       212b76e2-b562-49d4-bdba-2d7a33d03981
;; :END:

(defun feebleline:battery-status-indicator ()
  "Return what's used to indicate battery status."
  (let* ((battery-fn (-rpartial #'battery-format (funcall battery-status-function)))
         (icon-fn #'all-the-icons:icon)
         (props '(:v-adjust 0.01))
         (charge (battery:percentage))
         (chargingp (battery:charging-p)))
    (alet (cond (chargingp '(alltheicon "charging"       "[++++]"))
                ((> charge 75) '(faicon "full"           "[####]"))
                ((> charge 50) '(faicon "three-quarters" "[### ]"))
                ((> charge 25) '(faicon "half"           "[##  ]"))
                ((> charge 10) '(faicon "quarter"        "[#   ]"))
                (t             '(faicon "empty"          "[    ]")))
      (apply icon-fn (car it) (concat "battery-" (cadr it)) :fallback (caddr it) props))))

;; **** percentage
;; :PROPERTIES:
;; :ID:       3a4875be-45e4-4e49-bc05-dcbf50a80eff
;; :END:

;; The battery percentage actually comes with the tens place. That's too much
;; information and I'm not even sure if it's accurate enough for that tens place to
;; mean anything. Using [[helpfn:string-to-number][string-to-number]] just takes the integer part.

(defun feebleline:battery-info ()
  "Return battery information."
  (let* ((percentage (thread-last (funcall battery-status-function)
                       (battery-format "%p")
                       (string-to-number)))
         (status-indicator (feebleline:battery-status-indicator)))
    (format "%s %%%d" status-indicator percentage)))

;; **** dwim battery info
;; :PROPERTIES:
;; :ID:       0494e978-5f28-495f-87d4-904287495e92
;; :END:

;; I don't always need to display the battery information. It's only important to
;; see it if it's running low and my laptop's not charging.

(defun feebleline:dwim-battery-info ()
  "Same as `feebleline:battery-info' but."
  (when (and (not (battery:charging-p))
             (>= 35 (battery:percentage)))
    (feebleline:battery-info)))

;; *** music track
;; :PROPERTIES:
;; :ID:       58edb392-282a-4acd-a5a2-4c248da423ec
;; :END:

;; **** track status
;; :PROPERTIES:
;; :ID:       e0ec86fe-018f-4253-af4d-5a2173da659f
;; :END:

(defun feebleline:emms-track-status-indicator ()
  "Return the indicator for track status."
  (when (bound-and-true-p emms-player-playing-p)
    (alet (cond
           (emms-player-paused-p '(material "pause" "*paused*"))
           (emms-repeat-track    '(material "repeat_one" "*repeat-one*"))
           (t                    '(material "music_note" "*playing*")))
      (funcall #'all-the-icons:icon
               (car it)
               (cadr it)
               :fallback (caddr it)))))

;; **** music
;; :PROPERTIES:
;; :ID:       b3b654bb-e789-4647-9e82-e6c04c867ff8
;; :END:

(defun feebleline:emms-current-track ()
  "Add track information if playing."
  (when (bound-and-true-p emms-player-playing-p)
    (alet (->> (emms-playlist-current-selected-track)
               (emms-track-name)
               (f-base))
      (s-truncate 25 it))))

;; ** spinner
;; :PROPERTIES:
;; :ID:       991fcc99-667a-4bdb-a3ae-a14fd6001c4f
;; :END:

;; This package provides a framework for defining progress bars or spinners. This
;; is useful whenever there's a process.

(use-package! spinner)

;; ** hide-mode-line
;; :PROPERTIES:
;; :ID: 043e3474-7b66-4e73-9e0b-3347897dbdcc
;; :END:

;; [[https://github.com/hlissner/emacs-hide-mode-line][hide-mode-line]] is another package that does exactly what it's name says: hide
;; the mode line.

(use-package! hide-mode-line
  :hook Man-mode completion-list-mode)

;; ** all-the-icons
;; :PROPERTIES:
;; :ID: 6a7c7438-42c0-4833-9398-fa9fd58515d1
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :FILES:    (:defaults "data" "all-the-icons-pkg.el")
;; :HOST:     github
;; :REPO:     "domtronn/all-the-icons.el"
;; :PACKAGE:  "all-the-icons"
;; :LOCAL-REPO: "all-the-icons.el"
;; :COMMIT:   "6917b08f64dd8487e23769433d6cb9ba11f4152f"
;; :END:

;; A little bit of decoration and spice can go a long way. As its name suggests,
;; [[all-the-icons][all-the-icons]] is a package that contains a lot of icons ([[][here]] you can see
;; a few). In practice I use these icons to (1) make things look nicer and more
;; colorful and (2) enhance readability of plain text.

;; *** init
;; :PROPERTIES:
;; :ID:       554b6b2f-45f8-422f-bf01-e6da66e1ac39
;; :END:

;; **** install all the icons if not installed
;; :PROPERTIES:
;; :ID: 1cda0692-8f42-4bb3-b11d-da52e2004a55
;; :END:

;; This will install the icons if they're not already installed. Unless somehow the
;; fonts are deleted, this code should only take effect the first time installing
;; void. This helps achieve the goal to automate as much as possible on a fresh
;; VOID install. For writing this code I referenced the body of
;; [[helpfn:all-the-icons-install-fonts][all-the-icons-install-fonts]].

(defhook! install-icons-maybe (window-setup-hook)
  "Install icons if not installed."
  (let ((font-dir
         (cl-case window-system
           (x (concat (or (getenv "XDG_DATA_HOME")
                          (concat (getenv "HOME") "/.local/share"))
                      "/fonts/"))
           (mac (concat (getenv "HOME") "/Library/Fonts/" ))
           (ns (concat (getenv "HOME") "/Library/Fonts/" )))))
    (unless (--all-p (file-exists-p (concat font-dir it))
                     '("all-the-icons.ttf"
                       "file-icons.ttf"
                       "fontawesome.ttf"
                       "material-design-icons.ttf"
                       "octicons.ttf"
                       "weathericons.ttf"))
      (when (yes-or-no-p "No icons installed. Install?")
        (all-the-icons-install-fonts :ignore-prompt)))))

;; **** boostrap
;; :PROPERTIES:
;; :ID: a13cf0ec-14e2-4d4b-b313-65fe68f0655b
;; :END:

(use-package! all-the-icons
  :commands (all-the-icons-octicon
             all-the-icons-faicon
             all-the-icons-fileicon
             all-the-icons-wicon
             all-the-icons-material
             all-the-icons-alltheicon))

;; *** disable in tty
;; :PROPERTIES:
;; :ID: fce313d3-aa5a-4ea8-b994-1f9a8e33ab9d
;; :END:

;; In terminals these icons will not display correctly. I usually use emacs as a
;; graphical interface but.

(defun void--disable-icons-in-tty-advice ()
  ""
  (if (display-graphic-p) (apply <orig-fn> <args>) ""))

(alet ()
  all-the-icons-octicon
  all-the-icons-material
  all-the-icons-faicon
  all-the-icons-fileicon
  all-the-icons-wicon
  all-the-icons-alltheicon
  (void-add-advice it #'void--disable-icons-in-tty-advice))

;; ** zone
;; :PROPERTIES:
;; :ID:       6fd9cfb6-9500-4446-a530-46d6f7a78a4a
;; :TYPE:     built-in
;; :END:

;; *** init
;; :PROPERTIES:
;; :ID:       a570f63a-3ec0-4571-81ed-767801d2b49a
;; :END:


;; * Keybindings
;; :PROPERTIES:
;; :ID: 226e2c5b-2b81-483a-9942-d0ca0fc80f1f
;; :END:

;; *** bindings
;; :PROPERTIES:
;; :ID: 6b7e8206-24aa-485f-87e0-98a997936205
;; :END:

(general-def 'normal mu4e-headers-mode-map
  "q" #'kill-buffer-and-window
  "i" #'ignore
  "I" #'ignore
  "D" #'mu4e-headers-mark-for-delete
  "F" #'mu4e-headers-mark-for-flag
  "u" #'mu4e-headers-mark-for-unmark
  "x" #'mu4e-mark-execute-all
  "t" #'mu4e-headers-mark-for-trash
  "c" #'mu4e-compose
  "o" #'org-mu4e-compose-org-mode
  "s" #'mu4e-headers-search
  "r" #'mu4e-compose-reply
  "RET" #'mu4e-headers-view-message)

(general-def 'normal mu4e-view-mode-map
  "q" #'kill-buffer-and-window)

(define-localleader-key! mu4e-compose-mode-map
  "s" (list :def #'message-send-and-exit :which-key "send and exit")
  "d" (list :def #'message-kill-buffer :which-key "kill buffer")
  "S" (list :def #'message-dont-send :which-key "save draft")
  "a" (list #'mail-add-attachment :which-key "attach"))

;; *** keybindings
;; :PROPERTIES:
;; :ID: 293bc7c5-1320-4f3f-af2b-198d56694f71
;; :END:

(after! exwm
  (funcall (get 'exwm-input-global-keys 'custom-set)
           'exwm-input-global-keys
           `((,(kbd "s-R") . exwm-reset)
             (,(kbd "s-x") . exwm-input-toggle-keyboard)
             (,(kbd "s-h") . windmove-left)
             (,(kbd "s-j") . windmove-down)
             (,(kbd "s-k") . windmove-up)
             (,(kbd "s-l") . windmove-right)
             (,(kbd "s-t") . transpose-frame)
             (,(kbd "s-D") . kill-this-buffer)
             (,(kbd "s-b") . switch-to-buffer)
             (,(kbd "s-f") . find-file)
             (,(kbd "s-O") . exwm-layout-toggle-fullscreen)
             (,(kbd "s-p") . previous-buffer)
             (,(kbd "s-n") . next-buffer)
             (,(kbd "s-q") . void/open-qutebrowser)
             (,(kbd "s-e") . void/open-emacs-instance))))

(general-def
  "s-R" #'exwm-reset
  "s-x" #'exwm-input-toggle-keyboard
  "s-h" #'windmove-left
  "s-j" #'windmove-down
  "s-k" #'windmove-up
  "s-l" #'windmove-right
  "s-t" #'transpose-frame
  "s-D" #'kill-this-buffer
  "s-b" #'switch-to-buffer
  "s-f" #'find-file
  "s-O" #'exwm-layout-toggle-fullscreen
  "s-p" #'previous-buffer
  "s-n" #'next-buffer
  "s-q" #'void/open-qutebrowser
  "s-e" #'void/open-emacs-instance)

;; *** bindings
;; :PROPERTIES:
;; :ID: a8febb0e-768b-412d-9d86-1f1439eced0e
;; :END:

(general-def 'normal
  "f" #'avy-goto-char
  ;; "w" #'void/evil-beginning-of-word
  ;; "W" #'void/evil-beginning-of-WORD
  ;; "e" #'void/evil-end-of-word
  ;; "E" #'void/evil-end-of-WORD
  )

;; *** replace evil folding commands to outline folding
;; :PROPERTIES:
;; :ID: b3a4908d-538e-4d4c-acc9-fbd822220f03
;; :END:

;; By default evil binds =za= to [[helpfn:evil-open-folds][evil-open-folds]] and =zb= to [[helpfn:evil-close-folds][evil-close-folds]]. They do
;; work in =org-mode= but I'd rather use the folding commands provided by =outline.el.=
;; The outline api actually seems pretty solid; better coded and simpler than the
;; org api it seems.

(general-def 'normal org-mode-map
  [tab] #'outline-toggle-children
  "TAB" #'outline-toggle-children)

(defun outline:hide-all-sublevels ()
  (interactive)
  (outline-hide-sublevels 1))

;; *** generic org bindings
;; :PROPERTIES:
;; :ID:       583bd7ac-64e0-48ea-bd75-5b6a20f2deae
;; :END:

(general-def 'normal org-mode-map
  "j" #'org/dwim-next-line
  "k" #'org/dwim-previous-line
  "b" #'org/dwim-insert-elisp-block
  "o" #'org/insert-heading-below
  "O" #'org/insert-heading-above
  "l" #'org-do-demote
  "h" #'org-promote-subtree
  "L" #'org-demote-subtree
  "t" #'org-set-tags-command
  "r" #'org/choose-capture-template
  "s" #'org-schedule
  "S" #'org-deadline
  "R" #'org-refile
  "T" #'org-todo
  "D" #'org-cut-subtree
  "Y" #'org-copy-subtree
  "K" #'org-metaup
  "J" #'org-metadown)

;; *** execute extended command
;; :PROPERTIES:
;; :ID: d8071a32-e58c-41ab-8fd7-7d7732708ee8
;; :END:

;; One of the most common--if not the most common--command you use in Emacs is
;; [[helpfn:execute-extended-command][execute-extended-command]]. This command let's you search any other command and
;; upon pressing enter, then you execute the command. The fact that this command is
;; invoked so frequently demands it have one of the shortest, easiest to press
;; bindings. I chose to give it =SPC SPC= and =;=. =SPC SPC= is short and quick to
;; type as well as consistent with other =SPC= bindings. While =;= is super fast to
;; press as well and even faster than =SPC SPC=.

(define-leader-key! "SPC"
  (list :def #'execute-extended-command :wk "M-x"))

(general-def 'normal
  ";" #'execute-extended-command)

(general-def
  "A-x" #'execute-extended-command
  "M-x" #'execute-extended-command)

;; *** kill window
;; :PROPERTIES:
;; :ID:       74ba2105-d7a3-4e57-aca9-c5471beb635f
;; :END:

;; I replace the key used by evil to record keyboard macros with deleting windows.
;; Deleting windows is something that I do much more than recording macros.

(general-def '(normal) "q" #'delete-window)

;; *** scrolling pages

;; The commands [[helpfn:text-scale-increase][text-scale-increase]] and [[helpfn:text-scale-decrease][text-scale-decrease]] increase and decrease
;; the size of buffer text respectively. I play with text scale very often.

(general-def '(emacs normal)
  "M--" #'text-scale-decrease
  "M-=" #'text-scale-increase)

;; *** minibuffer
;; :PROPERTIES:
;; :ID:       d56ec4ce-f891-4e47-897a-e97699f19c43
;; :END:

;; **** selectrum
;; :PROPERTIES:
;; :ID:       6b6db3fa-6e6b-480f-ba57-3493b876a077
;; :END:

(general-def '(insert emacs) selectrum-minibuffer-map
  "TAB" #'selectrum-next-candidate
  "C-k" #'selectrum-previous-candidate
  "C-j" #'selectrum-next-candidate
  "C-;" #'selectrum-insert-current-candidate
  "C-l" #'selectrum/mark-candidate
  [backtab] #'selectrum-previous-candidate)

;; *** org mode
;; :PROPERTIES:
;; :ID:       6939399a-8737-447b-94d8-a4bbd2d6febf
;; :END:

;; **** org mode local bindings
;; :PROPERTIES:
;; :ID:       a950d732-b0d2-46b9-82ce-1b9a474e7d76
;; :END:

(define-localleader-key!
  :keymaps 'org-mode-map
  "w" (list :def #'widen                      :wk "widen")
  "n" (list :def #'org-narrow-to-subtree      :wk "narrow")
  "k" (list :def #'org-cut-subtree            :wk "cut subtree")
  "c" (list :def #'org-copy-subtree           :wk "copy subtree")
  "r" (list :def #'org-refile                 :wk "refile")
  "j" (list :def #'org/avy-goto-headline      :wk "jump to headline")
  "E" (list :def #'org-babel-execute-subtree  :wk "execute subtree")
  "e" (list :def #'org/dwim-edit-source-block :wk "edit source block")
  "," (list :def #'org/dwim-edit-source-block :wk "edit source block"))

;; **** bindings in source block
;; :PROPERTIES:
;; :ID:       df270638-f6a7-4f0e-abe7-dd0c4e7df7ce
;; :END:

;; Note that you should have bindings that are different for entering and exiting
;; source blocks.

(defhook! enable-org-exit-src-bindings (org-src-mode-hook)
  (define-localleader-key!
    "," (list :def #'org-edit-src-exit  :wk "exit source block")
    "a" (list :def #'org-edit-src-abort :wk "abort source block")
    "c" (list :def #'org-edit-src-exit  :wk "exit source block")))

;; *** windows
;; :PROPERTIES:
;; :ID: 784956e2-3696-4f92-80ca-41b7e30e5b2b
;; :END:

;; Efficient window management in Emacs crucial for success. These keys all pertain
;; to window/workspace actions.

(define-leader-key!
  :infix "w"
  ""  (list :ignore nil                              :wk "window")
  "w" (list :def #'display-buffer :wk "display buffer")
  "o" (list :def #'other-window                      :wk "other window")
  "S" (list :def #'void/window-split-below-and-focus :wk "split below and focus")
  "V" (list :def #'void/window-split-right-and-focus :wk "split right and focus")
  "s" (list :def #'split-window-below                :wk "split below")
  "v" (list :def #'split-window-right                :wk "split right")
  "M" (list :def #'maximize-window                   :wk "maximize")
  "m" (list :def #'minimize-window                   :wk "minimize")
  "b" (list :def #'balance-windows                   :wk "move left")
  "d" (list :def #'delete-window                     :wk "delete current")
  "D" (list :def #'delete-other-windows              :wk "delete others")
  "h" (list :def #'windmove-left                     :wk "move left")
  "j" (list :def #'windmove-down                     :wk "move down")
  "k" (list :def #'windmove-up                       :wk "move up")
  "l" (list :def #'windmove-right                    :wk "move right")
  "x" (list :def #'ace-swap-window                   :wk "swap windows")
  "t" (list :def #'transpose-frame                   :wk "transpose")
  ;; workgroups
  "n" (list :def #'wg-create-workgroup    :wk "save window config")
  )

;; *** buffer
;; :PROPERTIES:
;; :ID: e3eec4f8-88d8-4010-adb5-2f8e05f14677
;; :END:

;; In emacs, we change the buffer a window's displaying pretty often. That's why
;; efficient buffer navigation is a must. There are particular buffers which I
;; visit so often that it's worth having keybindings just for them.

(define-leader-key!
  :infix "b"
  ""  (list :def nil                            :wk "buffer")
  "e" (list :def #'buffer-expose                :wk "expose")
  "p" (list :def #'previous-buffer              :wk "previous")
  "n" (list :def #'next-buffer                  :wk "next")
  "s" (list :def #'switch-to-buffer             :wk "switch")
  "b" (list :def #'void/switch-buffer             :wk "display")
  "d" (list :def #'display-buffer               :wk "display")
  "t" (list :def #'void/switch-to-todo-file     :wk "Void TODO")
  "S" (list :def #'void/open-scratch            :wk "*scratch*")
  "i" (list :def #'void/switch-to-init-org-file :wk "fallback")
  "I" (list :def #'void/switch-to-main-elisp    :wk "main.el")
  "m" (list :def #'void/switch-to-main-org-file :wk "main.org")
  "M" (list :def #'void/switch-to-messages      :wk "*messages*"))

(define-leader-key!
  :infix "b k"
  ""  (list :ignore t             :wk "kill")
  "c" (list #'kill-current-buffer :wk "current"))

;; *** app
;; :PROPERTIES:
;; :ID: 3f09a41a-03b8-4d5c-85c5-d7adeb7dd328
;; :END:

;; These are keybindings I use most frequently.

(define-leader-key! "a" (list :ignore t :wk "app"))

(define-leader-key!
  :infix "a"
  "a" (list :def #'void/open-org-agenda      :wk "agenda")
  "m" (list :def #'mu4e                      :wk "mu4e")
  "l" (list :def #'org-store-link                    :wk "store link")
  "f" (list :def #'elfeed                    :wk "elfeed")
  "d" (list :def #'deer                      :wk "deer")
  "r" (list :def #'ranger                    :wk "ranger")
  "e" (list :def #'void/open-emacs-instance  :wk "emacs")
  "q" (list :def #'engine/search-qwant :wk "browse web")
  "j" (list :def #'org/avy-goto-headline :wk "heading jump")
  "c" (list :def #'org/choose-capture-template               :wk "capture"))

(define-leader-key! "as" (list :ignore nil :wk "screenshot"))

(define-leader-key!
  :infix "as"
  "s" (list :def #'escr-window-screenshot :wk "screenshot")
  "w" (list :def #'escr-window-screenshot :wk "window")
  "f" (list :def #'escr-frame-screenshot  :wk "frame"))

;; *** file
;; :PROPERTIES:
;; :ID: 2231147b-88c9-4c63-9c75-488cd1465807
;; :END:

(define-leader-key!
  :infix "f"
  ""  (list :ignore t          :wk "file")
  "S" (list :def #'sudo-edit   :wk "sudo")
  "s" (list :def #'save-buffer :wk "save buffer")
  "f" (list :def #'find-file   :wk "find file")
  "r" (list :def #'ranger      :wk "ranger")
  "d" (list :def #'deer        :wk "deer"))

;; *** eval
;; :PROPERTIES:
;; :ID: afa6be08-a38c-45f1-867a-5620fc290aac
;; :END:

(define-leader-key! "e" (list :ignore t :wk "eval"))

(define-leader-key!
  :infix "e"
  "r" (list :def #'eval-region          :wk "region")
  "d" (list :def #'eval-defun           :wk "defun")
  "l" (list :def #'eval-print-last-sexp :wk "sexp")
  "B" (list :def #'eval-buffer          :wk "buffer"))

(define-leader-key!
  :infix "e"
  :keymaps 'org-mode-map
  "b" (list :def #'org-babel-execute-src-block :wk "source block")
  "s" (list :def #'org-babel-execute-subtree :wk "subtree"))

;; *** code
;; :PROPERTIES:
;; :ID: 661f77fb-3435-4e4f-8adb-c4d6390ea6b8
;; :END:

;; These bindings are for generally working with code.

(define-leader-key! "c" (list :ignore t :wk "code"))

(define-leader-key!
  :infix "c"
  "a" (list :def #'ialign                               :wk "align")
  "l" (list :def #'lispyville-comment-or-uncomment-line :wk "toggle comment")
  "y" (list :def #'lispyvile-comment-and-cone-dwim      :wk "copy comment"))

;; *** toggle
;; :PROPERTIES:
;; :ID: 10d6851b-6af6-4185-8976-0ad65b3d1d28
;; :END:

(define-leader-key! "t" (list :ignore t :wk "toggle/set"))

(define-leader-key!
  :infix "t"
  "r" (list :def #'read-only-mode        :wk "read-only")
  "t" (list :def #'load-theme            :wk "load theme")
  "c" (list :def #'caps-lock-mode        :wk "caps lock")
  "d" (list :def #'toggle-debug-on-error :wk "debug")
  "F" (list :def #'void/set-font-face         :wk "set font")
  "f" (list :def #'void/set-font-size    :wk "font size"))

(define-leader-key!
  :infix "t"
  :keymaps 'org-mode-map
  "l" (list :def #'org-toggle-link-display :wk "link display"))

;; *** help
;; :PROPERTIES:
;; :ID: c7f3b699-7cf9-480b-a88c-10bdae4c165e
;; :END:

;; There's a lot of documentation finding and information searching involved in
;; Emacs and for that we need all the help we can get.

(define-leader-key!
  :infix "h"
  ""  (list :ignore t                      :wk "help")
  "h" (list :def #'describe-function       :wk "function")
  "v" (list :def #'describe-variable       :wk "variable")
  "c" (list :def #'describe-char           :wk "char")
  "k" (list :def #'describe-key            :wk "key")
  "f" (list :def #'describe-function       :wk "function")
  "l" (list :def #'global-command-log-mode :wk "command log")
  "a" (list :def #'apropos                 :wk "apropos"))

;; *** quit
;; :PROPERTIES:
;; :ID: d4828ea9-5ee1-4424-8ff0-f700876d34fd
;; :END:

;; There's many ways to quit Emacs. Sometimes I'd like to save all the buffers I
;; had been working on. Sometimes, when I'm testing something and I mess up
;; [[helpvar:kill-emacs-hook][kill-emacs-hook]] I want Emacs to just quit even if it means ignoring that hook.
;; Most of the time, I know what I'm doing when I quit Emacs, so I don't want a
;; prompt asking me if I'm sure.

(define-leader-key!
  :infix "q"
  ""  (list :ignore t                        :wk "quit")
  "q" (list :def #'evil-quit-all             :wk "normally")
  "s" (list :def #'void/quit-emacs-no-prompt :wk "with no prompt")
  "Q" (list :def #'evil-save-and-quit        :wk "and save")
  "x" (list :def #'void/kill-emacs-no-hook   :wk "with no hook")
  "e" (list :def #'void/kill-emacs-processes :wk "emacs processes")
  "b" (list :def #'void/kill-emacs-brutally  :wk "brutally")
  "r" (list :def #'restart-emacs             :wk "and restart"))

;; *** packages
;; :PROPERTIES:
;; :ID: d3286920-ead4-4f7c-bf9d-8a6ed3d7ba46
;; :END:

(define-leader-key!
  :infix "p"
  ""  (list :ignore t                       :wk "package")
  "i" (list :def #'straight-use-package     :wk "install")
  "r" (list :def #'straight-rebuild-package :wk "rebuild")
  "p" (list :def #'straight-pull-package    :wk "pull")
  "s" (list :def #'straight/search-package  :wk "search"))

;; *** search
;; :PROPERTIES:
;; :ID: b50ed0da-652d-4d20-8a4e-e0cf053548a6
;; :END:

(define-leader-key!
  :infix "s"
  ""  (list :ignore t :wk "search")
  "s" (list :def #'void/goto-line :wk "swiper")
  "w" (list :def #'search-web/default-engine :wk "web"))

(define-leader-key!
  :infix "s"
  :keymaps 'org-mode-map
  "h" (list :def #'org/goto-headline :wk "headlines"))

;; *** git
;; :PROPERTIES:
;; :ID: 87ba6613-6606-423c-84ec-f7c9ae10c9a6
;; :END:

(define-leader-key!
  :infix "g"
  ""  (list :ignore t           :wk "git")
  "c" (list :def #'magit-commit :wk "commit")
  "s" (list :def #'magit-status :wk "status"))
