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
  image: public.ecr.aws/aws-cli/aws-cli:2.35.12@sha256:e5c861dac19d206285d9ced92bc0951352941b1a058fc6b0a884abfd51c7950c
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
