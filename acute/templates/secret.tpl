{{- $fullName := include "chart.fullname" . -}}
{{- $labels := include "chart.labels" . -}}

{{- if and .Values.secretEnv ( .Values.secretEnv.enabled | default false ) }}
---
apiVersion: v1
kind: Secret
metadata:
  name:  {{ $fullName }}-secret-env
  labels:
    {{- $labels | nindent 4 }}
  {{- with .Values.secretEnv.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
type: Opaque
stringData:
  {{- .Values.secretEnv.data | nindent 2 }}
{{- end }}
