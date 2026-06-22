{{- define "credential-volumes" -}}
- name: secret
  secret:
    secretName: "{{ .Values.secret }}"
- name: sts
  emptyDir: {}
{{- end -}}

{{- define "container-resources" -}}
resources:
  requests:
    cpu: 100m
    memory: 100Mi
  limits:
    cpu: 100m
    memory: 100Mi
{{- end -}}

{{- define "container-security-context" -}}
securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - NET_RAW
      - ALL
{{- end -}}

{{- define "pod-security-context" -}}
securityContext:
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
{{- end -}}

{{- define "aws-sts-init-container" -}}
- name: aws-sts
  image: public.ecr.aws/aws-cli/aws-cli:2.35.9@sha256:01be46681e0bd75da54c2ca7c4edad9ecd29499f664cac5f6cbf0a189d67d0f3
  {{- include "container-resources" . | nindent 2 }}
  {{- include "container-security-context" . | nindent 2 }}
  env:
    - name: AWS_SHARED_CREDENTIALS_FILE
      value: /opt/hypershift/secret/aws-credentials
  volumeMounts:
    - name: secret
      mountPath: /opt/hypershift/secret
    - name: sts
      mountPath: /opt/hypershift/sts
  command: ["/bin/sh"]
  args:
    - -ec
    - |
      aws sts get-session-token --output json > /opt/hypershift/sts/token.json
      echo "STS token acquired successfully"
{{- end -}}
