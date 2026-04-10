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
  image: public.ecr.aws/aws-cli/aws-cli:2.34.29@sha256:a21c9fdf2ae8427b79d93d5a618aea12068da4864bd58072fa5436fd0ca9539d
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
