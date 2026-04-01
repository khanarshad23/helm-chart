{{- $fullName := include "chart.fullname" . -}}
{{- $labels := include "chart.labels" . -}}
{{- $selectorLabels := include "chart.selectorLabels" . -}}
{{- if and .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ $fullName }}
  labels:
    {{- $labels | nindent 4 }}
spec:
{{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
{{- end }}
{{- if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
{{- end }}
{{- with .Values.podDisruptionBudget.unhealthyPodEvictionPolicy }}
  unhealthyPodEvictionPolicy: {{ . }}
{{- end }}
  selector:
    matchLabels:
      {{- $selectorLabels | nindent 8 }}
{{- end }}
