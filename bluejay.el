(require 'xterm-color)
(require 'magit-section)

(defgroup jj nil
  "Interface to Jujutsu version control system."
  :group 'tools)

(defcustom jj-buffer-name "*jj-status*"
  "Name of the Jujutsu status buffer."
  :type 'string
  :group 'jj)

(defun jj-find-repo-root ()
  "Find the root directory of the Jujutsu repository."
  (locate-dominating-file default-directory ".jj"))

(defclass jj-status-section (magit-section) ()
  "Section for Jujutsu status output.")

(defun jj-insert-status-section ()
  "Insert the Jujutsu status section."
  (magit-insert-section (root nil)
  (magit-insert-section (status nil)
    (magit-insert-heading "Status")
    (let ((content (with-temp-buffer
                    (let ((process-environment 
                           (cons "FORCE_COLOR=1" process-environment)))
                      ;; (call-process "jj" nil t nil "st")
                      (call-process "jj" nil t nil "--config" "ui.color=\"always\"" "st")                      
                      (buffer-string)))))
      (insert content)
      (ansi-color-apply-on-region (point-min) (point-max))))

  (magit-insert-section (status nil)
    (magit-insert-heading "Log")
    (let ((content (with-temp-buffer
                    (let ((process-environment 
                           (cons "FORCE_COLOR=1" process-environment)))
                      ;; (call-process "jj" nil t nil "st")
                      (call-process "jj" nil t nil "--config" "ui.color=\"always\"")
                      (buffer-string)))))
      (insert content)
      (ansi-color-apply-on-region (point-min) (point-max))))))

(defun jj-status ()
  "Show Jujutsu status in a new buffer."
  (interactive)
  (let ((buffer (get-buffer-create "*jj-status*")))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (magit-section-mode)
        ;; Disable section body highlighting
        (setq-local magit-section-highlight-force-update t)
        ;; (setq-local magit-section-highlight-overlays nil)
        (add-hook 'magit-section-highlight-hook
                  (lambda ()
                    (magit-section-highlight-heading t))
                  nil t)
        (jj-insert-status-section))
      (goto-char (point-min)))
    (switch-to-buffer buffer)))

(provide 'jj)

