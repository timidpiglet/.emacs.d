;; -*- lexical-binding: t -*-

;; * Core
;; :PROPERTIES:
;; :ID:       d68434bf-be6a-471f-ab65-e151f4f1c111
;; :END:

;; ** Init
;; :PROPERTIES:
;; :ID:       71dbf82e-cf4f-4e8a-b14d-df78bea5b20f
;; :END:

;; *** don't garbage collect during initialization
;; :PROPERTIES:
;; :ID:       4913461b-8421-4a64-b09a-18c54673d7d7
;; :END:

;; [[id:86653a5a-f273-4ce4-b89b-f288d5d46d44][gcmh]] will take care of setting the gc-cons-threshold back to normal.

(setq gc-cons-threshold most-positive-fixnum)

;; *** directories
;; :PROPERTIES:
;; :ID: 93cc2db1-44c7-45ec-af98-5a4eb7145f61
;; :END:

;; I store certain important directories in variables so that I can easily
;; reference them in the future.

;; **** core directories and files
;; :PROPERTIES:
;; :ID: ad18ebcb-803a-4fd6-adcb-c71cf54f3432
;; :END:

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

;; ** Package Management
;; :PROPERTIES:
;; :ID: 0397db22-91be-4311-beef-aeda4cd3a7f3
;; :END:

;; The purpose of this headline is to set up the package manager and install all of
;; my packages so the rest of the file can assume the packages are already
;; installed. The idea is to separate package installation and package configuration.

;; *** straight.el
;; :PROPERTIES:
;; :ID: a086d616-b90d-4826-b61f-93eb0b7efc8e
;; :END:

;; [[straight][straight.el]] is a package manager that installs packages by cloning their git
;; repositories from online and building them from source. A consequence of this is
;; that you have the history of every installed emacs package locally. Another
;; consequence is that you can completely reproduce the state of your emacs on
;; another machine by installing the same packages with the same versions.

;; **** variables
;; :PROPERTIES:
;; :ID:       9dff9894-667c-4e74-9624-8aee533f8f70
;; :END:

(setq straight-base-dir VOID-PACKAGES-DIR)
(setq straight-use-package-version 'straight)
(setq straight-use-package-by-default t)
(setq straight-enable-package-integration t)
(setq straight-disable-autoloads t)
(setq straight-cache-autoloads nil)
(setq straight-check-for-modifications nil)
(setq straight-enable-package-integration nil)
(setq straight-recipes-emacsmirror-use-mirror t)

;; **** bootstrap code
;; :PROPERTIES:
;; :ID: 7816be80-4db8-4219-b7d1-9a6b1ea96035
;; :END:

;; This code is available from the [[https://github.com/raxod502/straight.el/blob/master/README.md][straight's README]]. Straight can't install itself
;; (chicken-egg problem), so this it's what's used to get it.

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

;; Straight is very minimal. It lacks some utility functions.

;; ***** package homepage
;; :PROPERTIES:
;; :ID:       0edcf34d-a368-4e86-9365-1402f23befbb
;; :END:

;; Very often you'll want to go visit the homepage of a package you've installed.
;; Either you'll want to checkout the readme, see new changes firsthand, or create
;; an issue about a bug, or even suggest a feature. That's why having a function to
;; quickly access a package homepage is a must.

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
  (when-let ((local-repo (plist-get (cdr recipe) :local-repo))
             (commit (plist-get (cdr recipe) :commit)))
    (when (file-exists-p (straight--repos-dir local-repo))
      (unless (straight-vc-commit-present-p (cdr recipe) commit)
        (straight-vc-fetch-from-remote recipe))
      (straight-vc-check-out-commit recipe commit))))

;; *** package installation
;; :PROPERTIES:
;; :ID:       5ca4b13a-14ab-4e7a-ab27-aab08b4f4994
;; :END:

;; This headline is about installing all of the packages I use. I do this by
;; searching through my init file for heading properties that correspond to emacs
;; packages. Then, I convert the properties to recipes. This is rather unorthodox.
;; However, I reason that storing package information as well would make it clear
;; when a headline denotes the configuration of a package. And, it would put all
;; that configuration in one place, allowing me to focus on the maintenance of only
;; one file as opposed to two. Finally, doing this would fascillitate installing
;; all my packages at once; and doing that, allows me to easizly optimize package
;; installation via caching and evaling during compilation.

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
  (let* ((regexp (rx (or ";; " "\n" (seq eow ":" (1+ white)))))
         (i 0)
         (parts (split-string string regexp t)))
    (mapcar
     (lambda (elt)
       (prog1 (if (zerop (% i 2))
                  (intern (downcase elt))
                (car (read-from-string elt)))
         (setq i (1+ i))))
     parts)))

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

(defvar void-package-load-paths
  (let ((file-name-handler-alist nil)
        (old-load-path load-path)
        (load-path load-path))
    (straight:initialize)
    (mapc #'straight:install-fn (void-get-package-recipes))
    (require 'dash)
    (-difference load-path old-load-path))
  "Package load-paths.")

(setq load-path (append void-package-load-paths load-path))

;; ** Library
;; :PROPERTIES:
;; :ID: 3e9e5e7a-9f9b-4e92-b569-b5e8ba93820f
;; :END:

;; This headline contains all the the helper functions and macros I defined for
;; customizing emacs.

;; *** essential libraries
;; :PROPERTIES:
;; :ID:       18602d49-dcc3-47c3-8579-62f7a7b7a83a
;; :END:

;; These are packages that I use to make writing lisp code more convenient. Emacs
;; Lisp is a full-featured, turing-complete language. However, for some data
;; structures like hash-tables and alists it is missing consistently named
;; functions for performing operations on these data structures. This is improving
;; slowly with the introduction of libraries like =seq.el= and =map.el= but still
;; leaves much to be desired.

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

;; This package provides a macro named =shut-up= that as its name suggests, silences
;; output of any forms within it. Emacs itself and many emacs packages spew
;; messages. While these messages can be nice to know, more often than not I get it
;; now and I don't want to see them again.

(require 'shut-up)
(defalias 'shut-up! 'shut-up)

(defun void--silence-output-advice (orig-fn &rest args)
  "Silence output."
  (shut-up (apply orig-fn args)))

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

;; Dash is rich list manipulation library. Many of the functions it has are already
;; found in some form or another in emacs in features such as =cl-lib= and =seq= and
;; =subr=, but dash has some very convenient functions and macros over emacs (such as
;; =-let)=. Moreover, a lot of work has been put into making it's functions efficient;
;; some are even more efficient than built-in cl functions. Additionally, it's
;; already used as a dependency of very many packages so I'll likely end up loading
;; it anyway.

(require 'dash)

;; **** dash-functional
;; :PROPERTIES:
;; :ID:       704fc35f-0ad0-4eb3-9eb5-d8335465dbd8
;; :FLAVOR:   melpa
;; :FILES:    ("dash-functional.el" "dash-functional-pkg.el")
;; :PACKAGE:  "dash-functional"
;; :LOCAL-REPO: "dash.el"
;; :TYPE:     git
;; :REPO:     "magnars/dash.el"
;; :HOST:     github
;; :END:

;; =dash-functional= provides "function combinators". These are functions that take
;; one or more functions as arguments and return a function. One example of this is
;; emacs's [[helpfn:apply-partially][apply-partially]]. These functions can help.

(require 'dash-functional)

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

;; =s= is an api for strings inspired by [[id:704fc35f-0ad0-4eb3-9eb5-d8335465dbd8][dash]].

(require 's)

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

;; It's common to want to refer to the thing you're operating on in lisp and in
;; many other languages. In lisp this often requires assigning the variable a name.
;; But if you're only.

(require 'anaphora)

;; *** loopy
;; :PROPERTIES:
;; :ID:       3102adee-0474-4cf4-847a-011c2f8f48cd
;; :HOST:     github
;; :TYPE:     git
;; :REPO:     "okamsn/loopy"
;; :PACKAGE:  "loopy"
;; :LOCAL-REPO: "loopy"
;; :END:

;; =loopy= is an alternative to =cl-loop= that preserves lisp structure. It is akin to
;; [[][Common Lisp's iter]]. dash's functions and macros are good for most
;; cases. But they are not as good in my opinion when you're dealing with a complex loop
;; that involves accumulating several variables or atypical control-flow (as in, break
;; statements or return statements).

;; *** macro writing tools
;; :PROPERTIES:
;; :ID:       ea5d3295-d8f9-4f3a-a1f6-25811696aa29
;; :END:

;; These are tools that are specifically designed to help me write macros.

;; **** macro keyword arguments
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

;; Sometimes I want to create a keyword by interning a string or a symbol. This
;; commands saves me having to add the colon at the beginning before interning.

(defun void-keyword-intern (&rest args)
  "Return ARGS as a keyword."
  (declare (pure t) (side-effect-free t))
  (apply #'void-symbol-intern ":" args))

;; ***** keyword name
;; :PROPERTIES:
;; :ID: fb867938-d62b-42fc-bf07-092f10b64f22
;; :END:

;; Calling [[helpfn:symbol-name][symbol-name]] on a keyword returns the keyword as a string. However often we
;; don't want the prepended colon on they keyword. This function is for that
;; occasion.

(defun void-keyword-name (keyword)
  "Return the name of the KEYWORD without the prepended `:'."
  (declare (pure t) (side-effect-free t))
  (substring-no-properties (void-to-string keyword) 1))

;; ***** convert to string
;; :PROPERTIES:
;; :ID: 4ef52875-4ce6-4940-8b7e-13c96bedcb3d
;; :END:

;; This function is for converting something to a string, no questions asked. I use
;; it when I don't want to be bothered with details and just want a string.

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
      (alet (void-expire-advice hook expire-fn t)
        (advice-add new-hook :around it)))))

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
       ,@(mapcar (lambda (hook)
                   `(aprog1 (defun ,hook-name (&rest _) ,docstring ,@body)
                      (void-add-hook ',hook it ,depth ,local)))
                 hooks))))

;; *** advice
;; :PROPERTIES:
;; :ID:       19b9021d-f310-485b-9258-4df19423c082
;; :END:

;; [[info:elisp#Advising Functions][Advising]] is one of the most powerful ways to customize emacs's behavior.

;; I want to name advices so that they can be distinguished from other functions. I
;; also want to be able to deduce the function being advised from the name.

;;  In this
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
  (->> (symbol-name fn)
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
      (alet (void-expire-advice new-advice expire-fn t)
        (advice-add new-advice :around it)))))

;; ***** adding advice
;; :PROPERTIES:
;; :ID:       1298ea9d-870c-45da-9424-9cf8c66f7403
;; :END:

(defun void-add-advice (symbols where advices &optional props expire-fn)
  "Advise TARGETS with Void ADVICES."
  (dolist (symbol (-list symbols))
    (dolist (advice (-list advices))
      (void--add-advice symbol where advice props expire-fn))))

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
        (expire-fn (or expire-fn t)))
    (fset expire-advice
          `(lambda (orig-fn &rest args)
             (aprog1 (apply orig-fn args)
               (when (or (eq t #',expire-fn) (funcall #',expire-fn))
                 (when (void-advice-p #',fn)
                   (void-remove-advice #',fn))
                 (when (void-hook-p #',fn)
                   (void-remove-hook #',fn))
                 (advice-remove #',fn #',expire-advice)
                 (when ,unbind (fmakunbound #',expire-advice))
                 (void-log "%s has expired." #',fn)
                 (when ,unbind (fmakunbound #',fn))))))))

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
       (cl-progv
           (->> (alet (help-function-arglist #',target t)
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

;; *** message logging
;; :PROPERTIES:
;; :ID:       4d4f4b4a-4fc3-47fe-bed7-acc8e8103933
;; :END:

;; Messages shown in the echo area are the. Its not uncommon for the *Messages*
;; buffer to become full of messages.

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

;; **** advice for using =void-log= instead of =message=
;; :PROPERTIES:
;; :ID:       adab4d98-ac13-4916-8349-99aa014d8f5c
;; :END:

;; Many packages produce their own messages. Sometimes I want to shut their
;; messages up entirely, for which I use [[71681f9f-2760-4cee-95a0-4aeb71191a42][shut-up]]. Other times though, I want to see
;; their messages when I'm debugging. This is what this device is for.

(defun void--use-void-log-advice (orign-fn &rest args)
  "Make ORIGN-FN use `void-log' instead of `message'."
  (cl-letf ((symbol-function 'message) (symbol-function 'void-log))
    (apply orign-fn args)))

;; **** don't show messages in echo area
;; ;; :PROPERTIES:
;; ;; :ID:       cf3d1f23-aa4c-4740-9413-edadd98ec142
;; ;; :END:

;; ;; =inhibit-message= prevents messages from being displayed in the [[][]]. However,
;; ;; they are still logged to the =*Messages*= buffer. The [[helpvar:inhibit-message][documentation for
;; ;; inhibit-message]] says not to enable this globally because it is "necessary" for
;; ;; isearch and other emacs functionality. I am skeptical though. I prefer not to
;; ;; have [[id:][feebleline]] distracted with constant messages.

;; (setq-default inhibit-message t)

;; **** control which messages are logged
;; ;; :PROPERTIES:
;; ;; :ID:       8be3c981-cf1c-4416-95b9-4dde2e203b6c
;; ;; :END:

;; ;; This is based on [[][message-log]]. This package is really old.

;; ;; ***** dont log regexp
;; ;; :PROPERTIES:
;; ;; :ID:       6ab7cc41-c900-4168-a33e-c326fae8ab8a
;; ;; :END:

;; (defvar void-message-blacklist
;;   '("Mark set"
;;     "Beginning of buffer"
;;     "End of buffer"
;;     "Quit")
;;   "*A list of regular expressions that describe messages that should never be
;; saved in the message log buffer.  A message is saved unless one of the regular
;; expressions in this list matches the ENTIRE message.")

;; ;; ***** advice to message
;; ;; :PROPERTIES:
;; ;; :ID:       d2e66bf9-c025-4d44-810e-5b66f154f43c
;; ;; :END:

;; (defadvice! maybe-ignore-message (:around (orig-fn &rest args) message)
;;   (when (--none-p (string-match-p it (car args)) void-message-blacklist)
;;     (apply orig-fn args)))

;; *** eval-after-load!
;; :PROPERTIES:
;; :ID:       8d831084-539b-4072-a86a-b55afb09bf02
;; :END:

;; =eval-after-load= is a macro that evaluates a lisp form after a file or feature
;; has been loaded. It's syntax is a bit terse because you need to quote the
;; feature as well as the form to be evaluated.

;; Also, if an =eval-after-load= block contains an error and it is triggered by a
;; feature, the error will happening. I think it might be that because the form was
;; not successfully evaluated =eval-after-load= does not realize it should stop
;; loading it. To remedy this I wrap the block with [[][condition-case]].

(defmacro eval-after-load! (feature &rest body)
  "A wrapper around `eval-after-load!' with error catching."
  (declare (indent defun))
  `(eval-after-load ',feature
     '(condition-case error
          (progn ,@body)
        (error
         (message "Error in `eval-after-load': %S" error)))))

;; *** after!
;; :PROPERTIES:
;; :ID: b31cd42d-cc57-492d-afae-d7d5e353e931
;; :END:

;; =after!= is yet another wrapper around == that can accept multiple features or
;; even a specification of features using =and= or =or=.

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

;; =system-packages= provides an api for installing system packages. This api strives
;; to abstract package installation on different operating systems. Unfortunately,
;; it does not include an interactive function that uses [[helpfn:completing-read][completing-read]] to list
;; packages

;; **** settings
;; :PROPERTIES:
;; :ID:       e43a8862-4e3a-4050-a15e-d39fd25dfccb
;; :END:

(setq system-packages-noconfirm t)

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
      (push `(yay (default-sudo . nil)
                  ,@(-map (-lambda ((action . command))
			    (cons action (s-replace "pacman" "yay" command)))
                          (cdr it)))
            system-packages-supported-package-managers))
    (setq system-packages-package-manager 'yay)))

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

;; *** ignore!
;; :PROPERTIES:
;; :ID: 0597956f-d40c-4c2b-9adf-5ece8c5b38de
;; :END:

(defmacro ignore! (&rest _)
  "Do nothing and return nil."
  nil)

;; *** list mutation
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

(defun void--load-on-call (package where functions &optional enable)
  "Load packages FUNCTIONS are called."
  (alet (void-symbol-intern 'void--load- package '-advice)
    (fset it `(lambda (&rest _)
                (void-log "Loading %s" ',package)
                (require ',package)
                (when ,enable
                  (funcall-interactively #',(void-symbol-intern package '-mode) 1))))
    (void-add-advice functions where it nil t)))

;; **** load before call
;; :PROPERTIES:
;; :ID:       cc0e92bc-cd6d-4994-82ea-eb065fc3ad89
;; :END:

(defun void-load-before-call (package functions &optional enable)
  (void--load-on-call package :before functions enable))

;; **** load after call
;; :PROPERTIES:
;; :ID:       b0b294d0-15ac-42d9-9e4c-fd9da8a95206
;; :END:

(defun void-load-after-call (package functions &optional enable)
  (void--load-on-call package :after functions enable))


;; ** Keybindings
;; :PROPERTIES:
;; :ID:       b0680fe6-23eb-412f-a357-bfa5e5bb7af7
;; :END:

;; *** prefix bindings
;; :PROPERTIES:
;; :ID: b0b5b51c-155e-46fc-a80a-0d45a32440ba
;; :END:

;; A popular strategy to mitigate the mental load of remembering many keybindings
;; is to bind them in a tree-like fashion (see [[https://github.com/syl20bnr/spacemacs][spacemacs]]).

;; **** leader Keys
;; :PROPERTIES:
;; :ID: 143211d6-b868-4ffb-a5d0-25a77dee401f
;; :END:

(defconst VOID-LEADER-KEY "SPC"
  "The evil leader prefix key.")

(defconst VOID-LEADER-ALT-KEY "M-SPC"
  "The leader prefix key used for Insert and Emacs states.")

;; **** localleader keys
;; :PROPERTIES:
;; :ID: 45941bcb-209f-4aa3-829a-dee4e3ef2464
;; :END:

(defconst VOID-LOCALLEADER-KEY "SPC m"
  "The localleader prefix key for major-mode specific commands.")

(defconst VOID-LOCALLEADER-ALT-KEY "C-SPC m"
  "The localleader prefix key for major-mode specific commands.")

(defconst VOID-LOCALLEADER-SHORT-KEY ","
  "A shorter alternative `void-localleader-key'.")

(defconst VOID-LOCALLEADER-SHORT-ALT-KEY "M-,"
  "A short non-normal  `void-localleader-key'.")

;; *** general
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
;; [[helpfn:evil-define-key][evil-define-key]]. [[https://github.com/noctuid/general.el.git][general]] provides a function that you can use for all bindings
;; ([[helpfn:general-define-key][general-define-key]]).

;; **** general
;; :PROPERTIES:
;; :ID: f1ad5258-17cb-4424-a161-b856ee6dc5ab
;; :END:

(require 'general)

;; **** unbind keys
;; :PROPERTIES:
;; :ID:       ffff6e7c-35c7-45e2-b2ad-6bca21bf8c1d
;; :END:

;; One error you'll often get when defining keys is.

(general-auto-unbind-keys)

;; **** definers
;; :PROPERTIES:
;; :ID: 6444d218-1627-48bd-9b5c-7bfffb17d912
;; :END:

;; As I've mentioned =general= uses the function =general-define-key= as a generic
;; do-all key binder. Sometimes though we have keys that we want to bind with
;; specific arguments to =general-define-key= pretty often. A typical example of
;; this is binding =leader= or =localleader= keys like [[https://github.com/syl20bnr/spacemacs][spacemacs]].

;; This form creates a macro =define-leader-key!= that.

(general-create-definer define-leader-key!
  :prefix VOID-LEADER-KEY
  :non-normal-prefix VOID-LEADER-ALT-KEY
  :keymaps 'override
  :states '(normal motion insert emacs))

;; **** localleader
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
  (alet `(:keymaps 'override
	  :states '(normal motion insert emacs)
	  ,@args)
    `(progn (general-def
              :prefix VOID-LOCALLEADER-KEY
              :non-normal-prefix VOID-LOCALLEADER-ALT-KEY
              ,@it)
            (general-def
              :prefix VOID-LOCALLEADER-SHORT-KEY
              :non-normal-prefix VOID-LOCALLEADER-SHORT-ALT-KEY
              ,@it))))

;; **** aliases
;; :PROPERTIES:
;; :ID:       81031f16-179e-4da7-9d83-7da5459fbdbd
;; :END:

;; In addition to providing keybinding stuff, =general= also provides.

(defalias 'define-key! 'general-def)

(defalias 'set! 'general-setq)
(defalias 'set-default! 'gsetq-default)

(defalias 'gsetq 'general-setq)
(defalias 'gsetq-default 'general-setq-default)


;; ** Packages
;; :PROPERTIES:
;; :ID:       d5c0d112-319d-4271-a819-eb786a64bfc6
;; :END:

;; *** calc
;; :PROPERTIES:
;; :ID:       98c0a8c7-2dc1-4285-9b7b-146bbc2867ae
;; :END:

;; *** vc-hook
;; :PROPERTIES:
;; :ID:       a8dcb1f6-05a0-46cb-95b5-1d0cd0ad4467
;; :END:

(setq vc-follow-link t)
(setq vc-follow-symlinks t)

;; *** subr-x
;; :PROPERTIES:
;; :ID:       ee3ad1b5-920a-4337-9874-79e066ed53fe
;; :END:

(require 'subr-x)

;; *** startup
;; :PROPERTIES:
;; :ID: 9725b7e0-54b8-4ab4-aa00-d950345d0aea
;; :TYPE:     built-in
;; :END:

(setq inhibit-startup-screen t)
(setq inhibit-default-init t)
(setq inhibit-startup-buffer-menu t)
(setq initial-major-mode 'fundamental-mode)
(setq initial-scratch-message nil)
(setq initial-buffer-choice #'void-initial-buffer)

;; *** paren
;; :PROPERTIES:
;; :ID: 8ba80d6f-292e-4d44-acfe-d7b7ba939fa4
;; :TYPE:     built-in
;; :END:

(setq show-paren-delay 0)
(void-add-hook 'prog-mode-hook #'show-paren-mode)

;; *** clipboard
;; :PROPERTIES:
;; :ID: 60abb076-89b1-439b-8198-831b2df47782
;; :TYPE:     built-in
;; :END:

(setq selection-coding-system 'utf-8)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; *** simple
;; :PROPERTIES:
;; :ID: 89df102a-a2c9-4ece-9acc-ed90e8064ed8
;; :TYPE:     built-in
;; :END:

(push '("\\*Messages"
        (display-buffer-at-bottom)
        (window-height . 0.5))
      display-buffer-alist)

(setq idle-update-delay 1)
(setq blink-matching-paren t)
(setq delete-trailing-lines nil)

(setq mail-user-agent 'mu4e-user-agent)

;; *** loaddefs
;; :PROPERTIES:
;; :ID:       5af4faf8-47e3-4db2-9d13-47fc828b8fca
;; :TYPE:     built-in
;; :END:

;; These are *extremely* important lines if you use an external program as I do
;; ([[https://wiki.archlinux.org/index.php/Msmtp][msmtp]]) to send your email. If you don't set these variables, emacs will
;; think you want to use =smtp=.

(setq disabled-command-function nil)

;; *** files
;; :PROPERTIES:
;; :ID: 2a7862da-c863-416b-a976-4cf7840a8712
;; :TYPE:     built-in
;; :END:

;; Disable second, case-insensitive pass over `auto-mode-alist'.
(setq auto-mode-case-fold nil)
;; Whether to add a newline automatically at the end of the file.
;; Whether confirmation is requested before visiting a new file or buffer.
(setq confirm-nonexistent-file-or-buffer nil)
;; How to ask for confirmation when leaving Emacs.
(setq confirm-kill-emacs #'y-or-n-p)
(setq require-final-newline nil)
(setq trash-directory (expand-file-name "Trash" "~"))
(setq auto-save-default nil)
(setq auto-save-interval 300)
(setq auto-save-timeout 30)
(setq backup-directory-alist (list (cons ".*" (concat VOID-DATA-DIR "backup/"))))
(setq make-backup-files nil)
(setq version-control nil)
(setq kept-old-versions 2)
(setq kept-new-versions 2)
(setq delete-old-versions t)
(setq backup-by-copying t)
(setq backup-by-copying-when-linked t)

;; *** subr-x
;; :PROPERTIES:
;; :ID:       1ed0ba00-e5a1-4642-9ed5-a52f4b917a4d
;; :END:

(require 'subr-x)

;; *** ffap
;; :PROPERTIES:
;; :ID: b1229201-a5ac-45c7-91fa-7a6b39bbb879
;; :END:

;; Don't ping things that look like domain names.

(after! ffap
  (setq ffap-machine-p-known 'reject))

;; *** server
;; :PROPERTIES:
;; :ID: 3ddeb65c-9df6-4ede-9644-eb106b3ba1dd
;; :END:

(after! server
  (setq server-auth-dir (concat VOID-DATA-DIR "server/")))

;; *** tramp
;; :PROPERTIES:
;; :ID: 3af0a4d6-bd08-4fe2-bc5c-79b1b811fc6b
;; :END:

(after! tramp
  (setq tramp-backup-directory-alist backup-directory-alist)
  (setq tramp-auto-save-directory (concat VOID-DATA-DIR "tramp-auto-save/"))
  (setq tramp-persistency-file-name (concat VOID-DATA-DIR "tramp-persistency.el")))

;; *** desktop
;; :PROPERTIES:
;; :ID: 3a6b72e7-57c8-42f0-a8d7-1bbde72de9bd
;; :END:

(after! desktop
  (setq desktop-dirname (concat VOID-DATA-DIR "desktop"))
  (setq desktop-base-file-name "autosave")
  (setq desktop-base-lock-name "autosave-lock"))

;; *** cus-edit
;; :PROPERTIES:
;; :ID: 8bd5683d-91e1-4c1b-a8a5-3b39921e995d
;; :END:

(setq custom-file null-device)
(setq custom-theme-directory (concat VOID-LOCAL-DIR "themes/"))

;; *** url
;; :PROPERTIES:
;; :ID: e4b5bfce-1111-48b2-bfee-da754974aa46
;; :END:

(setq url-cache-directory (concat VOID-DATA-DIR "url/cache/"))
(setq url-configuration-directory (concat VOID-DATA-DIR "url/configuration/"))

;; *** bytecomp
;; :PROPERTIES:
;; :ID:       6b375bfb-a8c3-473c-8dbd-530e692a15ab
;; :END:

(setq byte-compile-verbose void-debug-p)
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

;; *** compile
;; :PROPERTIES:
;; :ID:       913aa4f2-e42b-4b74-a2d4-e87b1738a5bd
;; :END:

(setq compilation-always-kill t)
(setq compilation-ask-about-save nil)
(setq compilation-scroll-output 'first-error)

;; *** uniquify
;; :PROPERTIES:
;; :ID:       9ba2726b-3fef-4e9b-9387-a80ab09bdb7d
;; :END:

(after! uniquify
  (setq uniquify-buffer-name-style 'forward))

;; *** ansi-color
;; :PROPERTIES:
;; :ID:       5feaab76-e5c1-450c-94a6-8fdfb95ddb94
;; :END:

(after! ansi-color
  (setq ansi-color-for-comint-mode t))

;; *** image mode
;; :PROPERTIES:
;; :ID:       32e2118a-c92b-4e8d-b2db-048428462783
;; :END:

;; Non-nil means animated images loop forever, rather than playing once.

(setq image-animate-loop t)

;; *** window
;; :PROPERTIES:
;; :ID:       af27cd7e-2096-4f6d-a749-63e4c38d136c
;; :END:

(after! window
  (setq split-width-threshold 160))

;; *** indent
;; :PROPERTIES:
;; :ID:       a5d97d4d-3af9-4fde-ae14-953ad4d28edd
;; :END:

(after! indent
  (setq tab-always-indent t))

;; *** mouse
;; :PROPERTIES:
;; :ID:       d0d6de11-50fa-4ae2-ad4b-69712f3e2c54
;; :END:


(setq mouse-yank-at-point t)

;; *** calendar
;; ;; :PROPERTIES:
;; ;; :ID:       4ad7e704-f490-40e4-b2bc-8a30a10a7bb7
;; ;; :END:

;; (setq diary-file (concat VOID-DATA-DIR "diary"))

;; (after! calendar
;;   (require 'f)
;;   (unless (f-exists-p diary-file)
;;     (f-touch diary-file)))

;; *** mule-cmds
;; :PROPERTIES:
;; :ID:       e48e925e-1f1e-4c79-8652-c92aafe06290
;; :END:

;; (setq prefer-coding-system VOID-DEFAULT-CODING-SYSTEM)

;; *** gv
;; :PROPERTIES:
;; :ID:       84cc5883-a303-453e-af91-644d4544e3f9
;; :END:

;; =gv= is what contains the code for the =setf= macro.
;; https://emacs.stackexchange.com/questions/59314/how-can-i-make-setf-work-with-plist-get

(after! gv
  (gv-define-simple-setter plist-get plist-put))

;; *** nsm
;; :PROPERTIES:
;; :ID:       0ca7fc66-5312-4c69-a87d-7607292c7a2a
;; :END:

(setq nsm-settings-file (concat VOID-DATA-DIR "network-settings.data"))


;; ** Miscellaneous
;; :PROPERTIES:
;; :ID: c21a5946-38b1-40dd-b6c3-da41fb5c4a5c
;; :END:

;; *** recursive minibuffers
;; :PROPERTIES:
;; :ID:       7eb20f6d-75b4-4eec-8878-e7232c1a153d
;; :END:

(setq-default enable-recursive-minibuffers t)

;; *** stop initial echo message
;; :PROPERTIES:
;; :ID:       c619e1ee-1109-4f1b-b1ba-53fcb8ceae4e
;; :END:

;; If you just set [[helpvar:inhibit-startup-echo-area-message][inhibit-startup-echo-area-message]] to =t= the word =nil= is messaged.
;; So it's best just to override the function entirely.

(void-add-advice #'display-startup-echo-area-message :override #'ignore)

;; *** use yes or no
;; :PROPERTIES:
;; :ID:       82a84315-2018-42e0-bd1a-74af7b722593
;; :END:

(void-add-advice #'yes-or-no-p :override #'y-or-n-p)

;; *** utf-8 text encoding
;; :PROPERTIES:
;; :ID:       26344072-c145-40bd-9ade-8c7f2eef54c8
;; :END:

(defconst VOID-DEFAULT-CODING-SYSTEM 'utf-8 "Default text encoding.")
(setq-default locale-coding-system VOID-DEFAULT-CODING-SYSTEM)
(setq-default buffer-file-coding-system VOID-DEFAULT-CODING-SYSTEM)

;; *** os specific
;; :PROPERTIES:
;; :ID:       e7a9bef7-3df5-4160-bff1-666c6e579981
;; :END:

;; **** linux
;; :PROPERTIES:
;; :ID:       6572e618-e5ef-445b-90d6-14dc2c24f1a4
;; :END:

(with-os! linux
  (setq x-underline-at-descent-line t)
  (setq x-gtk-use-system-tooltips nil))

;; *** disable bi-directional text
;; :PROPERTIES:
;; :ID:       6c12f14c-75c7-4b30-9bb4-ca6e8d3cae47
;; :END:

;; Disabling bidirectional text provides a small performance boost. Bidirectional
;; text is useful for languages that read right to left.

(setq-default bidi-display-reordering 'left-to-right)
(setq-default bidi-paragraph-direction 'left-to-right)

;; *** scrolling
;; :PROPERTIES:
;; :ID:       c91bcd0f-da83-44a3-9d9e-e1f55dcdb642
;; :END:

(gsetq-default hscroll-margin 2)
(gsetq-default hscroll-step 1)
(gsetq-default scroll-conservatively 1001)
(gsetq-default scroll-margin 0)
(gsetq-default scroll-preserve-screen-position t)

;; *** fast scrolling
;; :PROPERTIES:
;; :ID:       964a8b3e-37b4-4d6b-9298-3a1be3cfe6aa
;; :END:

;; "More performant rapid scrolling over unfontified regions. May cause brief
;; spells of inaccurate fontification immediately after scrolling."

(gsetq fast-but-imprecise-scrolling t)

;; *** resize pixelwise
;; :PROPERTIES:
;; :ID:       02daff3d-e532-4cfa-a217-81e27627e7a7
;; :END:

;; ;; https://github.com/baskerville/bspwm/issues/551#issuecomment-574975395

(gsetq window-resize-pixelwise t)
(gsetq frame-resize-pixelwise t)

;; *** inhibit startup messages
;; :PROPERTIES:
;; :ID:       e1ae4527-547e-46b8-b040-d9779bfe53ad
;; :END:

;; When emacs starts up it displays a message.

(gsetq inhibit-startup-message t)
(gsetq inhibit-splash-screen t)
(void-add-advice 'startup-echo-area-message :override #'ignore)

;; *** disable cursor blinking
;; :PROPERTIES:
;; :ID:       fe8a259b-12e6-4e58-a324-eab831283a86
;; :END:

;; By default the cursor blinks.

(blink-cursor-mode -1)

;; *** stop beeping
;; :PROPERTIES:
;; :ID:       2a83cb3a-ca2e-4d9c-a296-340d33855614
;; :END:

(setq-default ring-bell-function #'ignore)

;; *** garbage collection
;; :PROPERTIES:
;; :ID: 27ad0de3-620d-48f3-aa32-dfdd0324a979
;; :END:

;; Emacs garbage collects too frequently for most modern machines. This makes emacs
;; less performant especially when performing a large number of calculations,
;; because it spends resources garbage collecting when it doesn't have to. Indeed,
;; increasing the value of [[helpvar:gc-cons-threshold][gc-cons-threshold]], the number of bytes of consing
;; between garbage collections, is known to make a notable difference in user
;; startup time. By default it is only 800 KB.

;; **** gc cons threshold
;; :PROPERTIES:
;; :ID: e15d257f-1b0f-421e-8b34-076b1d20e493
;; :END:

;; I define three levels on frequency with which emacs should perform garbage
;; collection.

(defconst VOID-GC-CONS-THRESHOLD-MAX most-positive-fixnum
  "The upper limit for `gc-cons-threshold'.
When VOID is performing computationally intensive operations,
`gc-cons-threshold' is set to this value.")

(defconst VOID-GC-CONS-THRESHOLD (eval-when-compile (* 16 1024 1024))
  "The default value for `gc-cons-threshold'.
This is the value of `gc-cons-threshold' that should be used in typical usages.")

(defconst VOID-GC-CONS-THRESHOLD-MIN (eval-when-compile (* 4 1024 1024))
  "The value for `gc-cons-threshold'.")

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

;; =gcmh= does three things. It reduces garbage collection by setting, it adds a hook
;; telling Emacs to gargbage collect during idle time, and it tells Emacs to
;; garbage collect more frequently when it's idle.

(setq gcmh-idle-delay 5)
(setq gcmh-verbose void-debug-p)
(setq gcmh-high-cons-threshold VOID-GC-CONS-THRESHOLD)
(setq gcmh-low-cons-threshold VOID-GC-CONS-THRESHOLD-MIN)

(autoload #'gcmh-mode "gcmh" nil t nil)
(void-add-hook 'emacs-startup-hook #'gcmh-mode)

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
  (setq gc-cons-threshold VOID-GC-CONS-THRESHOLD))

;; **** boost gc-cons-threshold
;; :PROPERTIES:
;; :ID:       41e763bd-215f-4176-95c1-f41261864671
;; :END:

(defun void--reduce-garbage-collection-advice (orign-fn &rest args)
  "Boost garbage collection for the duration of ORIGN-FN."
  (let ((gc-cons-threshold VOID-GC-CONS-THRESHOLD-MAX))
    (apply orign-fn args)))

;; *** theme
;; :PROPERTIES:
;; :ID: 2ac7c2fe-a2ba-4e55-a467-ff4af8850331
;; :END:

;; **** don't prompt me when loading theme
;; :PROPERTIES:
;; :ID:       eaa6531c-1188-41c7-a645-a82d9f482449
;; :END:

;; If you don't enable =custom-save-themes=.

(setq custom-safe-themes t)

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

;; **** boost gc when loading theme
;; :PROPERTIES:
;; :ID:       447c9bc9-5aa8-40f9-8373-e8626183aef7
;; :END:

;; Loading a theme qualifies as an intensive operation as all the faces on the
;; screen need to be redisplayed.

(void-add-advice #'load-theme :around #'void--reduce-garbage-collection-advice)


;; *** disable terminal initialization
;; :PROPERTIES:
;; :ID: 63e351ad-9ef6-4034-9fca-861881c74d6a
;; :END:

;; When running emacs in terminal tty is *tremendously* slow.

(unless (display-graphic-p)
  (void-add-advice #'tty-run-terminal-initialization :override #'ignore)
  (defhook! init-tty (window-setup-hook)
    (advice-remove #'tty-run-terminal-initialization #'ignore)
    (tty-run-terminal-initialization (selected-frame) nil t)))

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

;; *** UTF-8
;; :PROPERTIES:
;; :ID: dd0fc702-67a7-404c-849e-22804663308d
;; :END:

;; I set =utf-8= as the default encoding for everything except the clipboard on
;; windows. Window clipboard encoding could be wider than =utf-8=, so we let
;; Emacs/the OS decide what encoding to use.

(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

;; *** aliases
;; :PROPERTIES:
;; :ID:       da7229b6-27a4-41b6-aa3a-07935b97d181
;; :END:

;; **** atom predicate
;; :PROPERTIES:
;; :ID:       d6e83bfb-aaac-4dcb-89e9-8f9b4ca92db7
;; :END:

;; =atom= is perhaps the only type predicate not to end in =p=.

(defalias 'atom 'atomp)

;; **** prefixed-core
;; :PROPERTIES:
;; :ID:       14b63dc9-1d95-4bd7-8b29-8b2b33bd1e69
;; :TYPE:     git
;; :HOST:     github
;; :REPO:     "emacs-straight/prefixed-core"
;; :FILES:    ("*" (:exclude ".git"))
;; :PACKAGE:  "prefixed-core"
;; :LOCAL-REPO: "prefixed-core"
;; :END:

;; This package defines numerous aliases to existing commands in an attempt to make
;; commands more discoverable and naming schemes more consistent.

(require 'prefixed-core)

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

;; =keyfreq= records the frequency of key strokes.

(void-add-hook 'emacs-startup-hook #'keyfreq-mode)
(autoload #'keyfreq-mode "keyfreq" nil t nil)

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

;; **** settings
;; :PROPERTIES:
;; :ID:       d16db762-9c50-4b00-9f2d-b4b5d15855cf
;; :END:

;; When emacs goes idle for [[helpvar:idle-require-idle-delay][idle-require-idle-delay]] seconds, the features will
;; start loading. [[helpvar:idle-require-load-break][idle-require-load-break]] is the break between features idle
;; require loads.

(setq idle-require-load-break 2)
(setq idle-require-idle-delay 10)

;; **** make idle require use void-log
;; :PROPERTIES:
;; :ID:       109011ee-ab24-4f3e-867f-21d6f6f534a8
;; :END:

;; =idle-require= messages us to tell us when a package is being idle required and
;; when it has finished idle-requiring packages. I don't want to see the message
;; unless I'm debugging.

(void-add-advice #'idle-require-mode :around #'void--use-void-log-advice)
(void-add-advice #'idle-require-load-next :around #'void--use-void-log-advice)

;; **** increase gc-cons-threshold during idle loading
;; :PROPERTIES:
;; :ID:       275c3488-8192-476c-97b8-6c6643f54d2e
;; :END:

;; Since we're evaluating a good amount of lisp expressions, we should boost
;; garbage collection during this time.

(void-add-advice #'idle-require-load-next :around #'void--reduce-garbage-collection-advice)


;; ** Commands
;; :PROPERTIES:
;; :ID:       14fd249d-b972-472c-b57e-4e53a80b22dc
;; :END:

;; *** consult
;; :PROPERTIES:
;; :ID:       44120178-95c3-44f1-a3a2-bd69b0d03e70
;; :HOST:     github
;; :REPO:     "minad/consult"
;; :PACKAGE:  "consult"
;; :TYPE:     git
;; :LOCAL-REPO: "consult"
;; :END:

;; Consult is a package that provides several generic utility functions.

;; **** don't preview anything

;; Many consult consult commands have a preview by default. Typically previews are
;; expensive. This is especially true for [[][]], which switches the theme every
;; time you move from one candidate to another.

(setq consult-preview-theme nil)
(setq consult-preview-outline nil)
(setq consult-preview-buffer nil)
(setq consult-preview-line nil)

;; **** autoload commands
;; :PROPERTIES:
;; :ID:       f78a7e71-b70a-4067-b821-f581cf76fb84
;; :END:

(--each (list #'consult-theme #'consult-line #'consult-yank-pop
              #'consult-outline #'consult-apropos #'consult-buffer)
  (autoload it "consult" nil t nil))

;; **** bindings
;; :PROPERTIES:
;; :ID:       c08a6f82-0408-4899-8e91-e1c5a062a7b2
;; :END:

(define-key!
  [remap switch-to-buffer] #'consult-buffer
  [remap apropos] #'consult-apropos
  [remap load-theme] #'consult-theme)

;; *** set font
;; :PROPERTIES:
;; :ID:       f24d97b6-7c74-491a-a77c-ba3ec22a2b68
;; :END:

(defun void/set-font-face ()
  "Apply an existing xfont to all graphical frames."
  (interactive)
  (set-frame-font (completing-read "Choose font: " (x-list-fonts "*")) nil t))

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

;; **** quit emacs no prompt
;; :PROPERTIES:
;; :ID: d530718a-2b42-4e9b-8d7d-7813e0ae6381
;; :END:

(defun void/quit-emacs-no-prompt ()
  "Quit emacs without prompting."
  (interactive)
  (let (confirm-kill-emacs)
    (kill-emacs)))

;; *** switch to scratch buffer
;; :PROPERTIES:
;; :ID:       7d9af4b6-7744-437f-b088-ec9397056113
;; :END:

(defun void/open-scratch ()
  "Pop scratch."
  (interactive)
  (pop-to-buffer "*scratch*"))


;; * Completion
;; :PROPERTIES:
;; :ID:       744ac652-aebc-4f5b-883a-4464dd7b07cd
;; :END:

;; Completion has certainly become an integral part of any efficient workflow. One
;; commonality among things like searching emails, code-completing a word, surfing
;; the web is that in one way or another all of these things involve the suggestion
;; of likely candidates from a population that is too time consuming to look
;; through on our own. It's not much different in Emacs. We're constantly sifting
;; though files, buffers, commands, words--all to try to get through to the subset
;; of things that we actually want at this moment.

;; ** company
;; :PROPERTIES:
;; :ID:       5c0ed97e-da66-42ab-a033-381ac9dd8972
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

;; *** bindings
;; :PROPERTIES:
;; :ID:       ba170d95-7d86-4827-af6b-dc5fd4c1b7e5
;; :END:

(define-key! company-active-map
  [tab]     #'company-select-next
  [backtab] #'company-select-previous
  "C-k"     #'company-select-previous
  "C-j"     #'company-select-next)

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

;; Selectrum is another completion framework. It distinguishes itself from the rest
;; by striving to work with the built-in emacs [[helpfn:completing-read][completing-read]] instead of
;; replacing it like [[https://github.com/emacs-helm/helm][helm]] and [[https://github.com/emacs-helm/helm][ivy]] do.

;; Because helm and ivy replace the existing framework, it means that whenever you
;; want a command be capable of using all of helm or ivy's features, you need to
;; define it their way. Otherwise, there's no guarantee their features will work at
;; least any features besides the basic choosing of a single candidate. That's a
;; big reason why there are [[][so many]] helm and ivy packages: many of those
;; packages are just ivy and helm wrappers around existing commands.

;; In contrast, any command defined via completing-read should work consistently with
;; selectrum and its provided features.

;; *** init
;; :PROPERTIES:
;; :ID:       6e670980-7794-4505-a285-184416a5b377
;; :END:

(void-add-hook 'emacs-startup-hook #'selectrum-mode)
(autoload #'selectrum-mode "selectrum" nil t nil)

(setq selectrum-fix-minibuffer-height t)
(setq selectrum-should-sort-p t)
(setq selectrum-count-style nil)
(setq selectrum-num-candidates-displayed 15)

;; *** minibuffer bindings
;; :PROPERTIES:
;; :ID:       f9bc79b9-ec16-4311-aa4c-8fef5add8b55
;; :END:

(define-key! '(insert emacs) selectrum-minibuffer-map
  "TAB" #'selectrum-next-candidate
  "C-k" #'selectrum-previous-candidate
  "C-j" #'selectrum-next-candidate
  "C-;" #'selectrum-insert-current-candidate
  "C-l" #'selectrum/mark-candidate
  [backtab] #'selectrum-previous-candidate)

;; *** advice for disable
;; :PROPERTIES:
;; :ID:       1e39a4d2-8d4a-4413-a86e-3f92547cff14
;; :END:

;; For most functions, sorting their candidates is good. This is advice
;; specifically designed to disable selectrum sorting.

(defun selectrum::disable-selectrum-sorting-advice (orig-fn &rest args)
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

;; Prescient.

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

(void-add-hook 'selectrum-mode-hook #'selectrum-prescient-mode)
(autoload #'selectrum-prescient-mode "selectrum-prescient" nil t nil)

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

(--each (list #'orderless-filter #'orderless-highlight-matches)
  (autoload it "orderless" nil t nil))

;; **** use orderless filters
;; :PROPERTIES:
;; :ID:       02b92dca-f879-43ad-89a5-fcf8902ff0b6
;; :END:

(after! selectrum
  (setq selectrum-refine-candidates-function #'orderless-filter)
  (setq selectrum-highlight-candidates-function #'orderless-highlight-matches))

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

;; * Utility

;; ** file browsing
;; :PROPERTIES:
;; :ID:       324ede5f-4606-40f2-a424-1cdf0c974853
;; :END:

;; *** dired
;; :PROPERTIES:
;; :ID:       877b66c0-7952-4b37-839a-4a9aa5af164a
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

;; **** create non-existent directory
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

(--each (list #'deer #'ranger)
  (autoload it "ranger" nil t nil))

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
(setq ranger-dont-show-binary t)

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

;; ** persistence
;; :PROPERTIES:
;; :ID:       c73a2fc2-5c43-4f99-9336-3bb2154852b7
;; :END:

;; Packages and features that involve saving to external files.

;; *** saveplace
;; :PROPERTIES:
;; :ID:       41cb3357-9b4b-4205-987d-ff72f9a35df3
;; :TYPE:     built-in
;; :END:

;; This package takes you to the last point you were at when you visited a file.

;; **** recenter cursor
;; :PROPERTIES:
;; :ID:       dda57b64-b645-4eda-be54-9dda4af35404
;; :END:

(defadvice! recenter-on-load (:after-while save-place-find-file-hook)
  "Recenter on cursor when loading a saved place."
  (when buffer-file-name (ignore-errors (recenter))))

;; **** saveplace
;; :PROPERTIES:
;; :ID: 6da42724-3137-4d70-9aed-9a978357679f
;; :END:

;; As its name suggests, =save-place= is a built-in package that stores the buffer
;; location you left off at in a particular buffer. When you visit that buffer
;; again, you are taken to the location you left off. This is very convenient.

(void-load-after-call #'after-find-file #'saveplace t)

(setq save-place-file (concat VOID-DATA-DIR "saveplace"))
(setq save-place-limit nil)

;; *** recentf
;; :PROPERTIES:
;; :ID: f26bedb3-a172-4543-afd0-4c47f5872d15
;; :TYPE:     built-in
;; :END:

;; =recentf= is a built-in program that tracks the files you've opened recently
;; persistently. This is a great idea because these are the files you'll likely
;; revisit. In practice, I look at this list of files in addition to the buffers I
;; already have open using a [[id:f26bedb3-a172-4543-afd0-4c47f5872d15][completion-framework]]. Because of this I rarely
;; have to set out to look for a file with =dired=.

;; **** init
;; :PROPERTIES:
;; :ID:       3e25c6a3-6a0f-47a4-a63f-ceca6476cc59
;; :END:

(-each '(easymenu tree-widget timer) #'idle-require)
(void-load-before-call 'recentf #'find-file t)
(after! consult (void-load-before-call 'recentf #'consult-buffer t))

;; **** settings
;; :PROPERTIES:
;; :ID:       3b9ab738-de00-40d4-93be-b2c84bfaac5c
;; :END:

(setq recentf-max-menu-items 0)
(setq recentf-max-saved-items 700)

(setq recentf-exclude
      (list #'file-remote-p
            "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\)$"
	    ;; ignore private Void temp files (but not all of them)
            #'(lambda (file)
                (-some-p (apply-partially #'file-in-directory-p file)
		         (list VOID-DATA-DIR)))))

(gsetq recentf-save-file (concat VOID-DATA-DIR "recentf"))
(gsetq recentf-auto-cleanup 'never)
(gsetq recentf-filename-handlers '(file-truename abbreviate-file-name))

;; **** cleanup before saving
;; :PROPERTIES:
;; :ID:       8b682202-b948-4e6a-ac64-089726f7d84e
;; :END:

(void-add-advice #'recentf-save-list :before #'recentf-cleanup)

;; **** silence recentf
;; :PROPERTIES:
;; :ID: 15a971c4-b43a-4539-846e-70fe4e90d84a
;; :END:

;; [[][recentf-mode]] as well as [[][recentf-cleanup]] output to the messages buffer.

(void-add-advice #'recentf-mode :around #'void--silence-output-advice)
(void-add-advice #'recentf-cleanup :around #'void--silence-output-advice)

;; *** savehist
;; :PROPERTIES:
;; :ID:       dd4b9da7-e54d-4d62-bb70-aa8f7f4a016f
;; :END:

;; =savehist= is a built-in feature for saving the minibuffer-history to a file--the
;; [[helpvar:savehist][savehist]] file. Additionally, it provides the ability to save additional
;; variables which may or may not be related to minibuffer history. You add the
;; ones you want to save to [[helpvar:savehist-additional-variables][savehist-additional-variables]].

;; **** init
;; :PROPERTIES:
;; :ID:       54183df6-b4f5-4b01-9ddb-4054ef0583b0
;; :END:

(setq savehist-save-minibuffer-history t)
(setq savehist-autosave-interval nil)
(setq savehist-file (concat VOID-DATA-DIR "savehist"))

(idle-require 'custom)
(void-add-hook 'emacs-startup-hook #'savehist-mode)

(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

;; **** unpropertize kill ring
;; :PROPERTIES:
;; :ID:       da2b6c31-d251-48aa-a6ed-8f01b9fa0b8d
;; :END:

;; #+begin_src elisp
;; (defhook! unpropertize-kill-ring (kill-emacs-hook :append t)
;;   "Remove text properties from `kill-ring'."
;;   (setq kill-ring
;;         (--map (when (stringp it) (substring-no-properties it))
;;                (-non-nil kill-ring))))
;; #+end_src

;; *** desktop
;; :PROPERTIES:
;; :ID:       902a11fc-b9aa-4875-ba92-8d2561a12a50
;; :END:

;; =desktop= is a built-in emacs package for saving window configuration setup.

;; **** some settings
;; :PROPERTIES:
;; :ID:       e4c30275-db62-4e6d-890c-6199b0594fd8
;; :END:

(setq desktop-save t) ; what should happen when desktop is killed.
(setq desktop-auto-save-timeout auto-save-timeout)
(setq desktop-base-file-name "emacs.desktop")
(setq desktop-base-lock-name "emacs.desktop.lock")
(setq desktop-path (list VOID-DATA-DIR))
(setq desktop-missing-file-warning nil)


;; * Window management
;; :PROPERTIES:
;; :ID:       f8f186bd-a701-4bd4-a249-86ec4faff83b
;; :END:

;; ** zoom
;; :PROPERTIES:
;; :ID:       4caedc4f-c973-4e81-ba13-751f7b8297b2
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "cyrus-and/zoom"
;; :PACKAGE:  "zoom"
;; :LOCAL-REPO: "zoom"
;; :END:

;; Resize windows according to the [[https://en.wikipedia.org/wiki/Golden_ratio][golden ratio]].

(autoload #'zoom-mode "zoom" nil t nil)

(gsetq zoom-size '(0.618 . 0.618))

(gsetq zoom-ignored-major-modes '(dired-mode markdown-mode))
(gsetq zoom-ignored-buffer-names '("zoom.el" "init.el"))
(gsetq zoom-ignored-buffer-name-regexps '("^*calc"))
(gsetq zoom-ignore-predicates '((lambda () (> (count-lines (point-min) (point-max)) 20))))

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

;; *** workgroups

(autoload #'wg-switch-workgroup "workgroup" nil)

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

;; * Text Editing
;; :PROPERTIES:
;; :ID:       40fb1b29-b772-456f-aac6-cf4a3b5cde3f
;; :END:

;; ** expand-region
;; :PROPERTIES:
;; :ID:       7e873fba-33ea-4720-ad79-bd8d557cc4b3
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "magnars/expand-region.el"
;; :PACKAGE:  "expand-region"
;; :LOCAL-REPO: "expand-region.el"
;; :END:

;; [[https://github.com/magnars/expand-region.el][expand-region]] allows me to toggle a key ("v" in my case) to select progressively
;; larger text objects. It's saves me keystrokes.

;; *** init
;; :PROPERTIES:
;; :ID:       41a1cebc-8da8-4e5c-8258-2ce440f1af50
;; :END:

(--each (list #'er/expand-region #'er/contract-region #'er/mark-symbol)
  (autoload it "expand-region" nil t nil))

;; *** quit expand region
;; :PROPERTIES:
;; :ID:       639824e1-0dcf-46bc-98b4-c70b9c7cb2a6
;; :END:

(defadvice! quit-expand-region (:before evil-escape)
  "Properly abort an expand-region region."
  (when (memq last-command '(er/expand-region er/contract-region))
    (er/contract-region 0)))

;; *** expand-region
;; :PROPERTIES:
;; :ID: 417c9c53-a776-4779-9afc-1eaa35a145c6
;; :END:

(define-key! 'visual
  "V" #'er/contract-region
  "v" #'er/expand-region)

;; ** writing
;; :PROPERTIES:
;; :ID:       98b567f1-00ad-4c99-aace-0a12f4d1b353
;; :END:

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

(autoload #'plural-make-plural "plural" nil t nil)

(after! plural
  (push (cons (rx bos "is" eos) "are") plural-knowledge)
  (push (cons (rx bos "thas" eos) "those") plural-knowledge)
  (push (cons (rx bos "this" eos) "these") plural-knowledge))

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
(autoload #'auto-capitalize-mode "auto-capitalize" nil t nil)
(setq auto-capitalize-words '("I" "English"))

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

(autoload #'xr "xr" nil nil nil)

;; ** saving & backups
;; :PROPERTIES:
;; :ID:       58228a67-3f7f-4654-8452-81194e75da07
;; :END:

;; *** super-save
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

(void-load-before-call 'super-save #'find-file t)

(setq super-save-idle-duration 5)
(setq super-save-auto-save-when-idle t)

;; ** spacing & indentation
;; :PROPERTIES:
;; :ID:       ae5416cd-ffa2-456a-9c56-afcfc65a33f8
;; :END:

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

(autoload #'aggressive-indent-mode "aggressive-indent" nil t nil)
(void-add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)

;; ** parentheses
;; :PROPERTIES:
;; :ID:       e82d2b4e-659e-4c7d-8071-c413b8e540f7
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

(alet '(prog-mode-hook eshell-mode-hook ielm-mode-hook)
  (void-add-hook it #'smartparens-strict-mode))

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
(setq sp-escape-quotes-after-insert nil)

;; **** config
;; :PROPERTIES:
;; :ID: f1c64411-ad51-4c24-8dad-b4aa7b8fc3b5
;; :END:

(after! smartparens
  (sp-local-pair 'emacs-lisp-mode "<" ">")
  (require 'smartparens-config)
  (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil))

;; **** disable =smartparens-navigate-skip-match=
;; :PROPERTIES:
;; :ID: fda1875b-b3f7-4f43-83b1-873f3db3ae77
;; :END:

(after! smartparens
  (defhook! disable-smartparens-navigate-skip-match (after-change-major-mode-hook)
    "Disable smartparents skip match feature."
    (setq sp-navigate-skip-match nil)
    (setq sp-navigate-consider-sgml-tags nil)))

;; **** autopairing
;; :PROPERTIES:
;; :ID: e860ce7e-aaac-477b-a373-a8b01957481d
;; :END:

(void-load-before-call 'smartparens (list #'evil-expression #'evil-ex))

(after! smartparens
  (defhook! enable-smartparens-maybe (minibuffer-setup-hook)
    "Enable `smartparens-mode' in the minibuffer, during `eval-expression' or
`evil-ex'."
    (when (memq this-command '(eval-expression evil-ex))
      (smartparens-mode 1))))

;; *** rainbow-delimiters
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

;; [[https://github.com/Fanael/rainbow-delimiters][rainbow-delimiters]] colors parentheses different colors based on level. This is a
;; great idea! It makes it really easy to see which parentheses go together.

(void-add-hook '(prog-mode-hook reb-mode-hook) #'rainbow-delimiters-mode)
(autoload #'rainbow-delimiters-mode "rainbow-delimiters" nil t nil)

(setq rainbow-delimiters-max-face-count 9)

;; ** outshine
;; :PROPERTIES:
;; :ID:       6aeccc22-2ebe-43c0-a245-5535b5bd6f6c
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "alphapapa/outshine"
;; :PACKAGE:  "outshine"
;; :LOCAL-REPO: "outshine"
;; :END:

(autoload #'outshine-mode "outshine" nil t nil)

;; ** modal editing
;; :PROPERTIES:
;; :ID:       175ad5b9-3f0e-445e-b0ae-da3bce144929
;; :END:

;; Modal editing is widely accepted to be more efficient than modeless editing.

;; *** evil
;; :PROPERTIES:
;; :ID:       9639633f-ec3d-4499-9615-db0dcc9650c9
;; :END:

;; **** evil-visualstar
;; :PROPERTIES:
;; :ID: 6ebca72d-f90a-4423-9ecd-706f9d426002
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "bling/evil-visualstar"
;; :PACKAGE:  "evil-visualstar"
;; :LOCAL-REPO: "evil-visualstar"
;; :END:

;; [[https://github.com/bling/evil-visualstar][evil-visualstar]]

(--each (list #'evil-visualstar/begin-search-backward
              #'evil-visualstar/begin-search-forward)
  (autoload it "evil-visualstar" nil t nil))

(define-key! evil-visual-state-map
  "#" #'evil-visualstar/begin-search-backward
  "*" #'evil-visualstar/begin-search-forward)

;; **** evil-surround
;; :PROPERTIES:
;; :ID:       9ab88644-3c33-463c-8f24-3b048209e082
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "emacs-evil/evil-surround"
;; :PACKAGE:  "evil-surround"
;; :LOCAL-REPO: "evil-surround"
;; :END:

(autoload #'evil-surround-mode "evil-surround" nil t nil)
(void-add-hook '(prog-mode-hook text-mode-hook) #'evil-surround-mode)

;; **** evil
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

;; ***** init
;; :PROPERTIES:
;; :ID:       af3a9791-76ac-4fd5-96fe-d361cef3b5b3
;; :END:

(autoload #'evil-mode "evil" nil t nil)
(void-add-hook 'window-setup-hook #'evil-mode)

;; ***** custom
;; :PROPERTIES:
;; :ID:       f7ece898-25e2-4b2c-94f3-e832a687114c
;; :END:

(custom-set-default 'evil-want-C-u-scroll t)

;; ***** settings
;; :PROPERTIES:
;; :ID:       9f184a21-ef04-4b3d-a1b7-88a16eaa7b97
;; :END:

(setq evil-want-C-w-in-emacs-state nil)
(setq evil-want-visual-char-semi-exclusive t)
(setq evil-move-beyond-eol nil)
(setq evil-magic t)
(setq evil-echo-state nil)
(setq evil-indent-convert-tabs t)
(setq evil-ex-search-vim-style-regexp t)
(setq evil-ex-substitute-global t)
(setq evil-ex-visual-char-range t)
(setq evil-insert-skip-empty-lines t)
(setq evil-mode-line-format nil)
(setq evil-respect-visual-line-mode t)
(setq evil-symbol-word-search t)

;; ***** cursors
;; :PROPERTIES:
;; :ID: a5f558fb-221c-4b33-a7cd-29308ef74b0d
;; :END:

;; It's nice to have cursors change colors (and sometimes shape) depending on the
;; current evil state. It makes it easy to tell which state you're in. I define
;; some colors here. Evil has a cursor variable for each state. The cursor variable
;; for insert state, for example, is [[helpvar:evil-insert-state-cursor][evil-insert-state-cursor]]. Its value is of the
;; form: ~((CURSOR-SHAPE . CURSOR-WIDTH) COLOR)~.

;; ****** colors and shapes
;; :PROPERTIES:
;; :ID: 3f3cd5c9-1f6d-4c3b-b73f-82c9ee00395e
;; :END:

;; Changing the cursor shape and color depending on the state is a convenient and
;; asthetically pleasing way of determining which state you're in. Some add some
;; modeline indicator for this but I find that the cursor suffices.

(defhook! setup-cursor (evil-mode-hook)
  "Initialize the default cursor shape and size."
  (setq evil-insert-state-cursor   '((bar . 3)   "chartreuse3"))
  (setq evil-emacs-state-cursor    '((bar . 3)   "SkyBlue2"))
  (setq evil-normal-state-cursor   '( box        "DarkGoldenrod2"))
  (setq evil-visual-state-cursor   '((hollow)    "dark gray"))
  (setq evil-operator-state-cursor '((hbar . 10) "hot pink"))
  (setq evil-replace-state-cursor  '( box        "chocolate"))
  (setq evil-motion-state-cursor   '( box        "plum3")))

;; ****** updating cursors
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

;; ***** normal state everywhere
;; :PROPERTIES:
;; :ID:       e6126bd7-94b8-4ce0-b547-0536b59437ea
;; :END:

;; Noctuid pointed out

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

;; ***** insert state in minibuffer
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

;; ***** escape
;; :PROPERTIES:
;; :ID:       e4b9d33d-c64d-47ef-9bff-baa80d1b34b2
;; :END:

;; ****** silence keyboard quit
;; :PROPERTIES:
;; :ID:       33f2010f-df3d-4b2b-8b4b-488cc037c6fc
;; :END:

(void-add-advice #'keyboard-quit :around #'void--silence-output-advice)

;; ****** escape
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

;; ****** key-chord
;; :PROPERTIES:
;; :ID:       8fd1bcdc-c4b3-4fee-b91b-dcdf96167582
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "emacsorphanage/key-chord"
;; :PACKAGE:  "key-chord"
;; :LOCAL-REPO: "key-chord"
;; :END:

;; Sometimes we don't have access to a convenient escape key--I mean that caps-lock
;; is not bound to escape. Or, perhaps, we might find it faster or preferable to
;; press =jk= really quickly to invoke escape.

;; This is better than evil escape as it only binds in insert.

;; ******* init
;; :PROPERTIES:
;; :ID:       6d02f80a-6d77-4a02-911e-98b7f4004048
;; :END:

(autoload #'key-chord-mode "key-chord" nil t nil)

(alet (list #'evil-insert-state #'evil-emacs-state)
  (void-load-before-call 'key-chord it t))

;; ******* be quiet when turning on
;; :PROPERTIES:
;; :ID:       1e1cff0d-3a2b-45cf-ab32-30379a86023c
;; :END:

(void-add-advice #'key-chord-mode :around 'void--silence-output-advice)

;; ******* keychord bindings
;; :PROPERTIES:
;; :ID:       738065e2-d607-4672-b44e-1fff5ed249bc
;; :END:

(general-def :states '(visual insert)
  (general-chord "jk") 'evil-force-normal-state
  (general-chord "kj") 'evil-force-normal-state)


;; * Languages
;; :PROPERTIES:
;; :ID:       fa8dc2fc-96f4-4820-b368-4d61d1db0ee5
;; :END:

;; ** lisp
;; :PROPERTIES:
;; :ID:       2b7db121-f807-4274-9347-70c996d3c6f7
;; :END:

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
;; :ID:       fad4cb7c-ff1e-485d-99d1-f55384c26402
;; :END:

(void-add-hook 'emacs-lisp-mode-hook #'lispyville-mode)

;; **** remappings
;; :PROPERTIES:
;; :ID: 5567b70d-60f2-4161-9a19-d6098f45cd95
;; :END:

(define-key! lipsyville-mode-map
  [remap evil-yank]                 #'lispyville-yank
  [remap evil-delete]               #'lispyville-delete
  [remap evil-change]               #'lispyville-change
  [remap evil-yank-line]            #'lispyville-yank-line
  [remap evil-delete-line]          #'lispyville-delete-line
  [remap evil-change-line]          #'lispyville-change-line
  [remap evil-delete-char]          #'lispyville-delete-char-or-splice
  [remap evil-delete-backward-char] #'lispyville-delete-char-or-splice-backwards
  [remap evil-substitute]           #'lispyville-substitute
  [remap evil-change-whole-line]    #'lispyville-change-whole-line
  [remap evil-join]                 #'lispyville-join)

;; **** inner text objects
;; :PROPERTIES:
;; :ID:       f9f82ebe-5749-452f-ba49-269e60526b04
;; :END:

(define-key! evil-inner-text-objects-map
  "a" #'lispyville-inner-atom
  "l" #'lispyville-inner-list
  "x" #'lispyville-inner-sexp
  "c" #'lispyville-inner-comment
  "s" #'lispyville-inner-string)

;; **** outer text objects
;; :PROPERTIES:
;; :ID:       9dda9a1b-c76f-4537-9554-45ad3c77977a
;; :END:

(define-key! evil-outer-text-objects-map
  "a" #'lispyville-a-atom
  "l" #'lispyville-a-list
  "x" #'lispyville-a-sexp
  "c" #'lispyville-a-comment
  "s" #'lispyville-a-string)

;; **** slurp/barf
;; :PROPERTIES:
;; :ID: 21626641-98e3-4134-958d-03227e4da6b5
;; :END:

(define-key! 'normal lispyville-mode-map
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

(define-key! '(emacs insert) lispyville-mode-map [escape] #'lispyville-normal-state)

;; **** additional
;; :PROPERTIES:
;; :ID: 1fbafa78-87a0-45ee-9c7c-0c703df2ac66
;; :END:

(define-key! '(emacs insert) lispyville-mode-map
  "SPC" #'lispy-space
  ";"   #'lispy-comment)

(define-key! '(normal visual) lispyville-mode-map
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

(autoload #'lispy-mode "lispy" nil t nil)
(void-add-hook 'emacs-lisp-mode-hook #'lispy-mode)

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
;; ;; :PROPERTIES:
;; ;; :ID:       a73ff9be-1a3d-4007-ad40-5a34c38767f6
;; ;; :END:

;; ;; You'll get void variable if you don't do this.

;; (after! (avy lispy) (setq lispy-avy-keys avy-keys))

;; *** highlight-quoted
;; :PROPERTIES:
;; :ID:       d0973dce-693b-45ca-88e3-27da1bb217f7
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "Fanael/highlight-quoted"
;; :PACKAGE:  "highlight-quoted"
;; :LOCAL-REPO: "highlight-quoted"
;; :END:

;; [[https://github.com/Fanael/highlight-quoted][highlight-quoted]] highlights quotes, backticks and.

(autoload #'highlight-quoted-mode "highlight-quoted" nil t nil)
(void-add-hook 'emacs-lisp-mode-hook #'highlight-quoted-mode)

;; *** fix elisp indentation
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

;; ** org
;; :PROPERTIES:
;; :ID:       63748940-c1b9-47ea-b1ce-d6519453ad03
;; :END:

;; *** initialize
;; :PROPERTIES:
;; :ID:       6d08d180-5b96-4f1f-98f9-53086c13561a
;; :END:

;; **** directories
;; :PROPERTIES:
;; :ID:       42e759b0-c676-4b87-ac84-20796500da5a
;; :END:

(setq org-directory VOID-ORG-DIR)
(setq org-archive-location (concat org-directory "archive.org::"))
(setq org-default-notes-file (concat org-directory "notes.org"))

;; **** general settings
;; :PROPERTIES:
;; :ID:       b0aa3f0b-876a-4527-b8ba-4fdac5e7ebe8
;; :END:

(setq org-fontify-emphasized-text t)
(setq org-hide-emphasis-markers t)
(setq org-pretty-entities t)
(setq org-fontify-whole-heading-line t)
(setq org-fontify-done-headline t)
(setq org-fontify-quote-and-verse-blocks t)
(setq org-adapt-indentation nil)
(setq org-cycle-separator-lines 2)
(setq outline-blank-line t)
(setq org-enforce-todo-dependencies t)
(setq org-use-fast-tag-selection nil)
(setq org-tags-column -80)
(setq org-tag-alist nil)
(setq org-log-done 'time)

;; **** required packages
;; :PROPERTIES:
;; :ID:       939d4fd6-85df-4ba2-8a67-23343d484bf9
;; :END:

(alet '(calendar find-func format-spec org-macs org-compat org-faces org-entities
	org-list org-pcomplete org-src org-footnote org-macro ob org org-agenda
	org-capture)
  (-each it #'idle-require))

;; *** customization
;; :PROPERTIES:
;; :ID:       3f0570f0-436b-4a53-92c4-52b06ae26a15
;; :END:

;; **** bindings
;; :PROPERTIES:
;; :ID:       4ca3fe54-54b1-47ca-90f1-a14b3df1cc59
;; :END:

;; Org mode demands its own editing.

;; ***** navigation
;; :PROPERTIES:
;; :ID:       25a91495-073d-4557-8407-49ea63f13383
;; :END:

(define-key! 'normal org-mode-map
  "j" #'org/dwim-next-line
  "k" #'org/dwim-previous-line)

;; ***** org mode local bindings
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

;; ***** generic org bindings
;; :PROPERTIES:
;; :ID:       583bd7ac-64e0-48ea-bd75-5b6a20f2deae
;; :END:

;; Org mode just does not lend itself to typical evil bindings. These bindings are
;; much more useful considering the specific structure of org mode documents.

(general-def 'normal org-mode-map
  "E" #'org/dwim-eval-block
  "e" #'org/dwim-eval-block
  "b" #'org/dwim-insert-elisp-block
  "o" #'org/insert-heading-below
  "O" #'org/insert-heading-above
  "h" #'org-up-heading-safe
  "l" #'org-do-demote
  "H" #'org-promote-subtree
  "S" #'org-demote-subtree
  ">" #'org-shiftmetaright
  "<" #'org-shiftmetaleft
  "t" #'org-set-tags-command
  "r" #'org/choose-capture-template
  "s" #'org/dwim-edit-source-block
  "R" #'org-refile
  "T" #'org-todo
  "D" #'org-cut-subtree
  "Y" #'org-copy-subtree
  "K" #'org-metaup
  "J" #'org-metadown)

;; ***** bindings
;; :PROPERTIES:
;; :ID:       3f4144ee-a780-478e-a1ad-47591f181ff3
;; :END:

(define-key! '(normal) org-mode-map
  ;; Doesn't work for some reason -> "TAB" #'outline-toggle-children
  "D" #'org-cut-subtree
  "P" #'org-paste-subtree)

(define-key! [remap org-cycle] #'outline-toggle-children)

;; **** custom commands
;; :PROPERTIES:
;; :ID:       4dfeccc9-f12e-4449-a5fe-17541070b40e
;; :END:

;; ***** do the right thing after jumping to headline
;; :PROPERTIES:
;; :ID:       2ca61454-a0ca-47b3-8622-91d7969653da
;; :END:

;; When I search for a headline with [[helpfn:void/goto-line][void/goto-line]] or [[helpfn:void/goto-headline][void/goto-headline]] or even their
;; counsel equivalents, the proper headlines aren't automatically revealed.

;; [[screenshot:][This]] is what headline structure looks after using counsel/ivy's [[helpfn:swiper][swiper]] to find
;; the word =void/goto-line= in my emacs. You can see that only the headline that has
;; the target word is revealed but it's parents are (akwardly) hidden. I never want
;; headlines to be unfolded like this.

;; ****** show branch
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

;; ****** show branch after jumping to point
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

;; ***** edit source blocks
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

;; ***** return
;; :PROPERTIES:
;; :ID:       8314f2e0-da63-4f2f-ad89-b97987ca5843
;; :END:

(defun org/dwim-return ()
  "Do what I mean."
  (interactive)
  (cond ((org-at-heading-p)
         (org/insert-heading-below))
        (t
         (call-interactively #'org-return))))

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

;; ***** navigation
;; :PROPERTIES:
;; :ID:       3d9ea885-e679-46e5-9541-dea0436d05ec
;; :END:

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
      (org-set-tags it))))

;; ***** eval
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

;; *** org-link-minor-mode
;; :PROPERTIES:
;; :ID:       25b93a1f-b105-47aa-9647-5015d23a4ac3
;; :END:
;; This is a minor mode for displaying links in non-org buffers.

(autoload #'org-link-minor-mode "org-link-minor-mode" nil t nil)
(void-add-hook 'outshine-mode-hook #'org-link-minor-mode)

;; *** org-journal
;; :PROPERTIES:
;; :ID:       c3056303-5fa1-49f9-ae2d-294942e25f54
;; :END:

;; =org-journal= is a package that provides functions to maintain a simple
;; diary/journal using =org-mode=.

(autoload #'org-journal-new-entry "org-journal" nil t nil)

(setq org-journal-file-type 'yearly)
(setq org-journal-dir (concat VOID-ORG-DIR "journal/"))
(setq org-journal-find-file 'find-file)

;; *** org-src
;; :PROPERTIES:
;; :ID:       e00378a1-adcf-4e83-8533-b6b442b5f362
;; :TYPE:     built-in
;; :END:

;; **** control org src popup
;; :PROPERTIES:
;; :ID:       f0f6ad72-b7bc-4894-86fe-32851698c319
;; :END:

;; #+begin_src elisp
;; (push '("\\*Org Src"
;; 	(display-buffer-at-bottom)
;; 	(window-height . 0.5))
;;       display-buffer-alist)
;; #+end_src

;; **** settings
;; :PROPERTIES:
;; :ID:       0f51ce73-d54e-4e89-8977-56c769940c5f
;; :END:

(setq org-edit-src-persistent-message nil)
(setq org-src-window-setup 'plain)
(setq org-src-fontify-natively t)
(setq org-src-ask-before-returning-to-edit-buffer nil)
(setq org-src-preserve-indentation t)
(setq org-src-tab-acts-natively t)
(setq org-confirm-babel-evaluate nil)

(setq org-babel-default-header-args
      '((:session . "none")
        (:results . "silent")
        (:exports . "code")
        (:cache . "no")
        (:initeb . "no")
        (:hlines . "no")
        (:tangle . "yes")))

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

;; *** org-capture
;; :PROPERTIES:
;; :ID:       3225bbc4-9685-4e7b-ae32-41a26780d191
;; :TYPE:     built-in
;; :END:

;; **** org capture
;; :PROPERTIES:
;; :ID:       8fc5d248-ff21-45e4-a48b-57cecd57b7a3
;; :END:

(autoload #'org-capture "org-capture" nil t nil)

;; **** control popup windows
;; :PROPERTIES:
;; :ID:       33c99055-ea4a-4df2-b9fc-934ac3f06ce1
;; :END:

(push '("\\`CAPTURE"
        (display-buffer-at-bottom)
        (window-height . 0.5)
        (slot . 10))
      display-buffer-alist)

;; **** remove capture headerline
;; :PROPERTIES:
;; :ID: 7b8a8e1d-3c72-492f-9311-56a2428a1f1d
;; :END:

;; By default org capture templates have. This was the answer to [[https://emacs.stackexchange.com/questions/53648/eliminate-org-capture-message][my question]]. I
;; need to disable =org-capture's= header-line.

(defhook! disable-header-line (org-capture-mode-hook)
  "Turn of the header line message."
  (setq-local header-line-format nil))

;; **** prevent capture templates from deleting windows
;; :PROPERTIES:
;; :ID:       a13e330a-33ff-4c1e-add4-00c5db4e6cd1
;; :END:

;; =org-capture= deletes all the other windows in the frame.

(defadvice! dont-delete-other-windows (:around org-capture-place-template)
  "Don't delete other windows when opening a capture template."
  (cl-letf (((symbol-function #'delete-other-windows) #'ignore))
    (apply <orig-fn> <args>)))

;; **** doct
;; :PROPERTIES:
;; :ID:       fa37f618-b58c-449b-a216-9d2f80ed12c6
;; :END:

;; [[https://github.com/progfolio/doct][doct]] is a package designed to ease writing and understanding capture templates
;; by allowing you to write them in a declarative style (see [[helpfn:doct][doct docstring]]).
;; In org mode, capture templates are [[info:org#Capture templates][represented as plain lists]]. This makes
;; it easy to forget what a certain element meant or to accidentally omit a capture
;; template element as you're writing it.

;; ***** doct
;; :PROPERTIES:
;; :ID:       0118ba87-219b-4611-9743-19228accaa2c
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "progfolio/doct"
;; :PACKAGE:  "doct"
;; :LOCAL-REPO: "doct"
;; :END:

(void-load-before-call 'doct #'org-capture)

;; ***** add to capture templates
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

;; **** capture templates
;; :PROPERTIES:
;; :ID:       a2a3f682-322a-450f-91bf-169d90f040c0
;; :END:

;; ***** emacs
;; :PROPERTIES:
;; :ID:       2682910c-9620-4cbf-ab71-371ed29e25a1
;; :END:

(list "emacs"
      :keys "e"
      :template (function org-capture::emacs-template-string)
      :file (function org-capture:file)
      :prepend t
      :empty-lines 1)


;; *** org-clock
;; :PROPERTIES:
;; :ID:       d378471c-89df-48c9-a755-b79880f27308
;; :TYPE:     built-in
;; :END:

;; =org-clock= is a built-in package that provides time logging functions for
;; tracking the time you spend on a particular task.

;; :before-call (( org-clock-out org-clock-in-last  org-clock-cancel) . (org-clock-load))
(--each (list #'org-clock-in #'org-clock-goto)
  (autoload it "org-clock" nil t nil))

(setq org-clock-persist 'history)
(setq org-clock-persist-file (concat VOID-DATA-DIR "org-clock-save.el"))
;; Resume when clocking into task with open clock
(setq org-clock-in-resume t)

;; set up hooks for persistence.
(after! org-clock
  (void-add-hook 'kill-emacs-hook #'org-clock-save)
  (org-clock-persistence-insinuate))

;; *** org-agenda
;; :PROPERTIES:
;; :ID: 65b2885d-aca6-42b8-a8ad-e3ae077b9aae
;; :TYPE:     built-in
;; :END:

;; [[helpfn:org-agenda-list][org-agenda-list]] is the function that actually takes you to the agenda for the
;; current week.

(--each (list #'org-agenda #'org-agenda-list)
  (autoload it "org-agenda" nil t nil))

(setq org-agenda-files nil)
(setq org-agenda-start-on-weekday 0)
(setq org-agenda-timegrid-use-ampm nil)
(setq org-agenda-skip-unavailable-files t)
(setq org-agenda-time-leading-zero t)
(setq org-agenda-text-search-extra-files '(agenda-archives))
(setq org-agenda-dim-blocked-tasks t)
(setq org-agenda-inhibit-startup t)

;; *** org-refile
;; :PROPERTIES:
;; :ID:       6dfc0415-2945-4259-a782-b569fcb397ea
;; :TYPE:     built-in
;; :END:

;; **** org refile
;; :PROPERTIES:
;; :ID: 0174a708-8043-403e-b024-8ae29868564d
;; :END:

(setq org-refile-targets nil)
(setq org-refile-use-outline-path 'file)
(setq org-refile-allow-creating-parent-nodes t)
(setq org-reverse-note-order t)
(setq org-outline-path-complete-in-steps nil)

;; **** refile to org buffers
;; :PROPERTIES:
;; :ID:       c6194791-8ac6-40a8-adb0-35041faaaa5a
;; :END:

(defun org/refile-to-other-buffer (arg)
  (interactive)
  (let ((org-refile-keep arg)
        org-refile-targets
        current-prefix-arg)
    (dolist (buf (delq (current-buffer)
                       (doom-buffers-in-mode 'org-mode)))
      (with-current-buffer buf
        (and buffer-file-name
             (cl-pushnew (cons buffer-file-name (cons :maxlevel 10))
                         org-refile-targets))))
    (call-interactively #'org-refile)))

;; *** org-id
;; :PROPERTIES:
;; :ID: e7ecff83-7ba6-4620-ac05-ebac2f250b7a
;; :TYPE:     built-in
;; :END:

;; =org-id= is a built-in package that creates that provides tools for creating and
;; storing universally unique IDs. This is primarily used to disguish and
;; referenance org headlines.

(autoload #'org-id-get-create "org-id")

(setq org-id-locations-file (concat VOID-DATA-DIR "org-id-locations"))

(setq org-id-locations-file-relative t)

(void-add-hook 'org-insert-heading-hook #'org-id-get-create)

;; *** org-superstar
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
(autoload #'org-superstar-mode "org-superstar" nil t nil)

(setq org-superstar-special-todo-items t)
(setq org-superstar-leading-bullet ?\s)

;; * Asthetic
;; :PROPERTIES:
;; :ID: bd21a69a-794c-4ff1-97d0-9e5911a26ad7
;; :END:

;; It's easy to underestimate how much of a difference having an asthetically
;; pleasing Emacs configuration can have. Ugliness really can take its toll.

;; ** mini-modeline
;; :PROPERTIES:
;; :ID:       51768ba1-170f-497b-9479-541e7c6aadd6
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "kiennq/emacs-mini-modeline"
;; :PACKAGE:  "mini-modeline"
;; :LOCAL-REPO: "emacs-mini-modeline"
;; :END:

;; *** setup
;; :PROPERTIES:
;; :ID:       d9acb47b-089f-4b18-8fdd-94ffefb2ef86
;; :END:

;; These variables do stuff with displaying lines and separators to make the
;; modeline more visible. I do that myself with =window-divider= so I don't need
;; this.

(setq mini-modeline-enhance-visual nil)
(setq mini-modeline-display-gui-line nil)

(require 'mini-modeline)
(void-add-hook 'emacs-startup-hook #'mini-modeline-mode)

;; *** default face
;; :PROPERTIES:
;; :ID:       1aab03cd-83b2-4d3a-bf3b-71f52dc6158d
;; :END:

;; If you don't set this, mini-modeline's background color won't
;; update with the theme. This is probably what the default value of this
;; variable should be anyway.

(setq mini-modeline-face-attr '(:inherit default))

;; *** set the modeline display
;; :PROPERTIES:
;; :ID:       37f062a8-b9d9-4533-ba8e-d675a1d5f10a
;; :END:

(setq mini-modeline-r-format
      '("%e" (:eval (format-time-string "%a %m/%d %T"))))

(setq mini-modeline-l-format
      '("%e" mode-line-buffer-identification))

;; *** dont redisplay
;; :PROPERTIES:
;; :ID:       b3afd056-7b0a-485f-8691-5cc7e4765ca1
;; :END:

;; Enabling =mini-modeline-mode= triggers a call to [[helpfn:redisplay][redisplay]]. During startup, this
;; takes a long time and makes emacs unresponsive for a few seconds. This redisplay
;; does not seem to be needed (feebleline doesn't do it and it works fine).

(defadvice! dont-redisplay (:around mini-modeline-mode)
  (cl-letf (((symbol-function #'redisplay) #'ignore))
    (apply <orig-fn> <args>)))

;; ** helpful
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

;; *** helpful
;; :PROPERTIES:
;; :ID: 25270809-b64e-4b9a-b0c2-95ffd047280c
;; :END:

;; [[github:wilfred/helpful][helpful]] provides a complete replacement for the built-in
;; Emacs help facility which provides much more contextual information
;; in a better format.

(general-def
  :package 'helpful
  [remap describe-function] #'helpful-callable
  [remap describe-command]  #'helpful-command
  [remap describe-variable] #'helpful-variable
  [remap describe-key]      #'helpful-key)

(push '("\\*Help.*"
	(display-buffer-at-bottom)
	(window-width . 0.50)
	(side . bottom)
	(slot . 4))
      display-buffer-alist)

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
(autoload #'which-key-mode "which-key" nil t nil)

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

;; (which-key-add-key-based-replacements void-leader-key "<leader>")
;; (which-key-add-key-based-replacements void-localleader-key "<localleader>")

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

(setq dashboard-items nil)
(setq dashboard-startup-banner 2)
(setq dashboard-center-content t)
(setq initial-buffer-choice #'void-initial-buffer)

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

(custom-set-default 'window-divider-default-places t)
(custom-set-default 'window-divider-default-bottom-width 7)
(custom-set-default 'window-divider-default-right-width  7)

;; *** window divider face
;; :PROPERTIES:
;; :ID:       61157149-dcce-40a9-8bfa-76a6af24838a
;; :END:

(defhook! set-window-divider-face (load-theme)
  (set-face-foreground 'window-divider "black"))

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

;; ** themes
;; :PROPERTIES:
;; :ID:       ee63aedb-beb7-4857-9af6-0b52afc2672e
;; :END:

;; *** one-themes
;; :PROPERTIES:
;; :ID:       b3b03192-be43-45fa-8086-1bb572af9499
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "balajisivaraman/emacs-one-themes"
;; :PACKAGE:  "one-themes"
;; :LOCAL-REPO: "emacs-one-themes"
;; :END:

(setq emacs-one-use-variable-pitch nil)

;; *** solarized-theme
;; :PROPERTIES:
;; :ID:       f1a6119b-edba-4478-a726-ddb9c7530318
;; :TYPE:     git
;; :FLAVOR:   melpa
;; :HOST:     github
;; :REPO:     "bbatsov/solarized-emacs"
;; :PACKAGE:  "solarized-theme"
;; :LOCAL-REPO: "solarized-emacs"
;; :END:

(setq solarized-use-variable-pitch nil)

;; *** gruvbox-theme
;; :PROPERTIES:
;; :ID:       b10fe46a-390a-436d-876e-7a62de335fa6
;; :END:


;; * Keybindings
;; :PROPERTIES:
;; :ID:       e4605d42-4d57-40d9-8594-15b06f6196a4
;; :END:

;; ** execute extended command
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

;; ** bindings that should be available everywhere
;; :PROPERTIES:
;; :ID:       cfb08f5e-9e6e-4e9f-ab85-92f9cc26f1bd
;; :END:

(define-localleader-key!
  "a" (list :def #'org-agenda :wk "agenda")
  "s" (list :def #'void/open-scratch :wk "scratch")
  "f" (list :def #'void/set-font-size    :wk "font size")
  "c" (list :def #'org-capture  :wk "capture"))

(define-leader-key!
  :infix "t"
  :keymaps 'org-mode-map
  "l" (list :def #'org-toggle-link-display :wk "link display"))

;; ** space bindings
;; :PROPERTIES:
;; :ID:       8f00f10d-0ace-4531-a3f4-2508a6592e06
;; :END:

;; *** eval
;; :PROPERTIES:
;; :ID: afa6be08-a38c-45f1-867a-5620fc290aac
;; :END:

(define-leader-key! "e" (list :ignore t :wk "eval"))

(define-leader-key!
  :infix "e"
  "e" (list :def #'eval-expression :wk "expression")
  "r" (list :def #'eval-region          :wk "region")
  "d" (list :def #'eval-defun           :wk "defun")
  "l" (list :def #'eval-print-last-sexp :wk "sexp")
  "B" (list :def #'eval-buffer          :wk "buffer"))

(define-leader-key!
  :infix "e"
  :keymaps 'org-mode-map
  "b" (list :def #'org-babel-execute-src-block :wk "source block")
  "s" (list :def #'org-babel-execute-subtree :wk "subtree"))

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
  "a" (list :def #'apropos                 :wk "apropos"))

;; *** quit
;; :PROPERTIES:
;; :ID:       ae435361-79e7-41c8-b490-8ec0f8d23a59
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
  ;; "r" (list :def #'restart-emacs             :wk "and restart")
  )

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
  "t" (list :def #'transpose-frame                   :wk "transpose"))

;; *** buffer
;; :PROPERTIES:
;; :ID: e3eec4f8-88d8-4010-adb5-2f8e05f14677
;; :END:

(define-leader-key!
  :infix "b"
  ""  (list :def nil                :wk "buffer")
  "p" (list :def #'previous-buffer  :wk "previous")
  "n" (list :def #'next-buffer      :wk "next")
  "s" (list :def #'switch-to-buffer :wk "switch")
  "b" (list :def #'switch-to-buffer :wk "switch")
  "M" (list :def #'void/open-messages :wk "open *Messages*")
  "d" (list :def #'display-buffer   :wk "display"))

(define-leader-key!
  :infix "b k"
  ""  (list :ignore t             :wk "kill")
  "c" (list #'kill-current-buffer :wk "current"))

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

;; ** search
;; :PROPERTIES:
;; :ID: b50ed0da-652d-4d20-8a4e-e0cf053548a6
;; :END:

(define-leader-key!
  :infix "s"
  ""  (list :ignore t :wk "search")
  "s" (list :def #'consult-line :wk "jump to line")
  "w" (list :def #'search-web/default-engine :wk "web")
  "h" (list :def #'consult-outline :wk "jump to outline heading"))
